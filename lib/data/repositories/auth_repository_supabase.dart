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
        emailRedirectTo: AppConfig.appUrl,
      );
    } on AuthException catch (e) {
      throw contract.AuthException(e.message);
    } catch (_) {
      throw const contract.AuthException('Could not send the code. Check your email and try again.');
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
      throw contract.AuthException(e.message);
    } catch (_) {
      throw const contract.AuthException('Sign-in failed. Please try again.');
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;

    // 1. Native Google account picker → Google ID token.
    //    (initialize is idempotent; serverClientId must match the OAuth web
    //    client id configured on the Supabase Google provider.)
    final GoogleSignInAccount googleUser;
    try {
      await googleSignIn.initialize(serverClientId: _serverClientId.isEmpty ? null : _serverClientId);
      googleUser = await googleSignIn.authenticate();
    } on GoogleSignInException catch (e) {
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
    } catch (_) {
      throw const contract.AuthException('Google sign-in was cancelled.');
    }

    // 2. Google ID token → Supabase session. Supabase creates/reuses the
    //    auth user (email identity linking applies) and returns the access
    //    token used for all CityBee API calls.
    final idToken = googleUser.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      // Missing ID token almost always means the OAuth client
      // configuration (server client id / SHA-1) is wrong.
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
    } catch (_) {
      throw const contract.AuthException('Unable to sign in with Google. Please try again.');
    }
  }

  static String get _serverClientId => AppConfig.googleServerClientId;

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (_) {
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
}
