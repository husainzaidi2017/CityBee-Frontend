import 'dart:developer' as developer;

import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_config.dart';
import 'auth_repository.dart' as contract;

/// Supabase Auth implementation of the app's auth contract.
///
/// The UI talks to this through the [contract.AuthRepository] interface; OTP
/// flows map 1:1 onto `signInWithOtp` / `verifyOtp`. Google sign-in uses the
/// NATIVE account picker (google_sign_in) and exchanges the Google ID token
/// for a Supabase session via `signInWithIdToken` — no web view. The
/// resulting session token is attached to API calls by the ApiClient.
/// Failures are rethrown as the app's [contract.AuthException] so existing
/// error handling keeps working.
///
/// Diagnostics: real error codes/messages are logged via `dart:developer`
/// (visible in flutter run console / DevTools) with NO tokens or secrets.
class SupabaseAuthRepository implements contract.AuthRepository {
  SupabaseAuthRepository() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  /// Current access token for API calls (null when browsing as guest).
  @override
  String? get accessToken => _client.auth.currentSession?.accessToken;

  @override
  Future<void> sendOtp(String email, {contract.OtpChannel channel = contract.OtpChannel.email}) async {
    try {
      await _client.auth.signInWithOtp(
        email: email.trim(),
        shouldCreateUser: true,
        // Deep link (allow-listed in Supabase URL Configuration) so any
        // link-based email opens the app, never localhost.
        emailRedirectTo: AppConfig.authCallbackUrl,
      );
    } on AuthException catch (e) {
      developer.log(
        'sendOtp failed: code=${e.statusCode} message="${e.message}"',
        name: 'CityBeeAuth',
      );
      final m = e.message.toLowerCase();
      if (m.contains('rate') || m.contains('over')) {
        throw const contract.AuthException('Too many requests. Please wait a moment and try again.');
      }
      if (m.contains('network') || m.contains('fetch')) {
        throw const contract.AuthException('Please check your internet connection.');
      }
      if (m.contains('smtp') || m.contains('email provider') || m.contains('not configured')) {
        throw const contract.AuthException(
          'Email delivery is not configured on the server yet.',
        );
      }
      throw const contract.AuthException('Could not send the code. Please try again.');
    } catch (e) {
      _logTransport('sendOtp', e);
      throw const contract.AuthException('Please check your internet connection.');
    }
  }

  @override
  Future<void> verifyOtp(String email, String otp) async {
    try {
      await _client.auth.verifyOTP(
        email: email.trim(),
        token: otp.trim(),
        type: OtpType.email,
      );
    } on AuthException catch (e) {
      developer.log(
        'verifyOtp failed: code=${e.statusCode} message="${e.message}"',
        name: 'CityBeeAuth',
      );
      final m = e.message.toLowerCase();
      if (m.contains('expire')) {
        throw const contract.AuthException('That code has expired. Request a new one.');
      }
      if (m.contains('invalid') || m.contains('token')) {
        throw const contract.AuthException('Incorrect code. Please check and try again.');
      }
      if (m.contains('rate') || m.contains('over')) {
        throw const contract.AuthException('Too many attempts. Please wait a moment.');
      }
      throw contract.AuthException(e.message);
    } catch (e) {
      _logTransport('verifyOtp', e);
      throw const contract.AuthException('Sign-in failed. Please try again.');
    }
  }

  @override
  Future<void> signInWithPassword(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } on AuthException catch (e) {
      developer.log(
        'signInWithPassword failed: code=${e.statusCode} message="${e.message}"',
        name: 'CityBeeAuth',
      );
      final m = e.message.toLowerCase();
      if (m.contains('invalid login credentials')) {
        throw const contract.AuthException(
          'Wrong email or password. Or create an account below.',
        );
      }
      if (m.contains('email not confirmed')) {
        throw const contract.AuthException(
          'Please confirm your email first (check your inbox).',
        );
      }
      if (m.contains('network') || m.contains('fetch')) {
        throw const contract.AuthException('Please check your internet connection.');
      }
      throw contract.AuthException(e.message);
    }
  }

  @override
  Future<void> signUp(String email, String password) async {
    AuthResponse response;
    try {
      response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        emailRedirectTo: AppConfig.authCallbackUrl,
      );
    } on AuthException catch (e) {
      developer.log(
        'signUp failed: code=${e.statusCode} message="${e.message}"',
        name: 'CityBeeAuth',
      );
      final m = e.message.toLowerCase();
      if (m.contains('rate') || m.contains('over')) {
        throw const contract.AuthException(
          'Too many sign-ups from this network. Please wait an hour.',
        );
      }
      if (m.contains('already registered')) {
        throw const contract.AuthException(
          'An account with this email already exists — use Sign In.',
        );
      }
      if (m.contains('password')) {
        throw const contract.AuthException(
          'Password must be at least 6 characters.',
        );
      }
      throw contract.AuthException(e.message);
    }
    // With email confirmation enabled the account is created but NO session
    // exists yet — the user must confirm via email first. Never report
    // success without a live session (that produced phantom "logged in"
    // states with no profile record).
    if (response.session == null) {
      developer.log(
        'signUp: user created but session is null (email confirmation pending)',
        name: 'CityBeeAuth',
      );
      throw const contract.AuthException(
        'Account created — please confirm via the email we sent you, then sign in.',
      );
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;

    if (_serverClientId.isEmpty) {
      developer.log(
        'GoogleSignIn: serverClientId (web OAuth client id) is MISSING in the app build. '
        'Pass it via --dart-define=GOOGLE_SERVER_CLIENT_ID=<web-client-id>. '
        'Also verify the Supabase Google provider is enabled with the same client id.',
        name: 'CityBeeAuth',
      );
    }

    // 1. Native Google account picker → Google ID token.
    final GoogleSignInAccount googleUser;
    try {
      await googleSignIn.initialize(
        serverClientId: _serverClientId.isEmpty ? null : _serverClientId,
      );
      googleUser = await googleSignIn.authenticate();
    } on GoogleSignInException catch (e) {
      developer.log(
        'GoogleSignIn failed: code=${e.code} description="${e.description}"',
        name: 'CityBeeAuth',
      );
      switch (e.code) {
        case GoogleSignInExceptionCode.canceled:
        case GoogleSignInExceptionCode.interrupted:
          throw const contract.AuthException('Google sign-in was cancelled.');
        case GoogleSignInExceptionCode.clientConfigurationError:
        case GoogleSignInExceptionCode.providerConfigurationError:
          throw const contract.AuthException(
            'Google sign-in is not configured correctly. Please contact support.',
          );
        default:
          throw const contract.AuthException('Unable to sign in with Google. Please try again.');
      }
    } catch (e) {
      // Non-GoogleSignInException errors from the platform channel: log the
      // real error and surface a distinctive message — never silently call
      // it "cancelled" (that hid real configuration failures before).
      _logTransport('GoogleSignIn.authenticate', e);
      final raw = e.toString().toLowerCase();
      if (raw.contains('cancel')) {
        throw const contract.AuthException('Google sign-in was cancelled.');
      }
      if (raw.contains('network') || raw.contains('timeout')) {
        throw const contract.AuthException('Please check your internet connection.');
      }
      throw contract.AuthException(
        'Google sign-in could not be completed (${e.runtimeType}). Please try again.',
      );
    }

    // 2. Google ID token → Supabase session. Supabase creates/reuses the
    //    auth user (email identity linking applies) and returns the access
    //    token used for all CityBee API calls.
    final idToken = googleUser.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      developer.log(
        'GoogleSignIn returned NO idToken — almost always means the OAuth '
        'client configuration is wrong: (a) serverClientId (web client id) '
        'missing/mismatched, or (b) the Android OAuth client (package + SHA-1) '
        'not registered in Google Cloud Console. '
        'Package: com.localgo.localgo; debug SHA-1: $_debugSha1',
        name: 'CityBeeAuth',
      );
      throw const contract.AuthException(
        'Google sign-in is not configured correctly. Please contact support.',
      );
    }

    try {
      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
    } on AuthException catch (e) {
      developer.log(
        'Supabase signInWithIdToken(google) failed: code=${e.statusCode} message="${e.message}" '
        '(common causes: Google provider disabled in Supabase, web client id mismatch, wrong audience)',
        name: 'CityBeeAuth',
      );
      final message = e.message.toLowerCase();
      if (message.contains('network') || message.contains('fetch')) {
        throw const contract.AuthException('Please check your internet connection.');
      }
      if (message.contains('invalid') && message.contains('token')) {
        throw const contract.AuthException(
          'Google sign-in is not configured correctly. Please contact support.',
        );
      }
      throw contract.AuthException(e.message);
    } catch (e) {
      // Surface the real exchange error (with runtimeType) instead of a
      // generic message that hides the actual failure cause.
      _logTransport('signInWithIdToken', e);
      final raw = e.toString().toLowerCase();
      if (raw.contains('network') || raw.contains('fetch') || raw.contains('timeout')) {
        throw const contract.AuthException('Please check your internet connection.');
      }
      throw contract.AuthException(
        'Google sign-in could not be completed (${e.runtimeType}). Please try again.',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      developer.log('Supabase signOut error: $e', name: 'CityBeeAuth');
      // Signing out locally is enough when the network call fails.
    }
    // Also disconnect the Google account so the next sign-in shows the
    // account picker again (rather than silently reusing the account).
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Local Google sign-out failure must not block Supabase sign-out.
    }
  }

  @override
  bool get isSignedIn => _client.auth.currentSession != null;

  static String get _serverClientId => AppConfig.googleServerClientId;

  static const _debugSha1 = '08:E3:88:EB:20:C3:02:1E:2A:0C:6F:0B:AC:75:77:C0:25:8D:57:8E';

  void _logTransport(String stage, Object error) {
    developer.log(
      '$stage transport error: ${error.runtimeType}: $error',
      name: 'CityBeeAuth',
    );
  }
}
