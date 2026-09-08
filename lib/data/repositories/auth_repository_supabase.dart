import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_config.dart';
import 'auth_repository.dart' as contract;

/// Supabase Auth implementation of the app's auth contract.
///
/// The UI talks to this through the [contract.AuthRepository] interface; OTP
/// flows map 1:1 onto `signInWithOtp` / `verifyOtp` and Google sign-in onto
/// the OAuth provider. The resulting session token is attached to API calls
/// by the ApiClient. Failures are rethrown as the app's [contract
/// .AuthException] so existing error handling keeps working.
class SupabaseAuthRepository implements contract.AuthRepository {
  SupabaseAuthRepository() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  /// Current access token for API calls (null when browsing as guest).
  @override
  String? get accessToken => _client.auth.currentSession?.accessToken;

  @override
  Future<void> sendOtp(String phone, {contract.OtpChannel channel = contract.OtpChannel.sms}) async {
    try {
      await _client.auth.signInWithOtp(
        phone: phone,
        shouldCreateUser: true,
      );
    } on AuthException catch (e) {
      throw contract.AuthException(e.message);
    } catch (_) {
      throw const contract.AuthException('Could not send the code. Check your number and try again.');
    }
  }

  @override
  Future<void> verifyOtp(String phone, String otp) async {
    try {
      await _client.auth.verifyOTP(
        phone: phone,
        token: otp.trim(),
        type: OtpType.sms,
      );
    } on AuthException catch (e) {
      throw contract.AuthException(e.message);
    } catch (_) {
      throw const contract.AuthException('Sign-in failed. Please try again.');
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: AppConfig.appUrl,
      );
    } on AuthException catch (e) {
      throw contract.AuthException(e.message);
    } catch (_) {
      throw const contract.AuthException('Google sign-in failed. Please try again.');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (_) {
      // Signing out locally is enough when the network call fails.
    }
  }

  @override
  bool get isSignedIn => _client.auth.currentSession != null;
}
