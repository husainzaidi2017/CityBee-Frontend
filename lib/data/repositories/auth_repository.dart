/// How an OTP was delivered (email).
enum OtpChannel { email }

/// Contract for authentication.
///
/// The mock implementation simulates flows in memory; the Supabase
/// implementation maps OTP flows onto `signInWithOtp` / `verifyOtp` and
/// Google sign-in onto the native picker + `signInWithIdToken` without any
/// UI changes.
abstract class AuthRepository {
  /// Sends a one-time password to [email].
  Future<void> sendOtp(String email, {OtpChannel channel});

  /// Verifies the OTP and completes sign-in. Throws [AuthException] on a
  /// wrong code.
  Future<void> verifyOtp(String email, String otp);

  /// Native Google sign-in: account picker → Google ID token → Supabase
  /// session (see SupabaseAuthRepository for the full flow).
  Future<void> signInWithGoogle();

  /// Clears the session (Supabase + Google). Browsing continues as guest.
  Future<void> signOut();

  /// Whether a session is currently active.
  bool get isSignedIn;

  /// Current access token for API calls (null when browsing as guest).
  String? get accessToken => null;
}

/// Authentication failures with user-friendly messages.
class AuthException implements Exception {
  const AuthException(this.userMessage);

  final String userMessage;
}

class MockAuthRepository implements AuthRepository {
  static const _demoOtp = '123456';

  bool _signedIn = false;

  @override
  String? get accessToken => null;

  @override
  Future<void> sendOtp(String email, {OtpChannel channel = OtpChannel.email}) async {
    // Simulates the network round-trip; the channel is surfaced by the UI
    // that triggered it, so nothing needs to be stored here.
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<void> verifyOtp(String email, String otp) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (otp.trim() != _demoOtp) {
      throw const AuthException('Incorrect code. Please try again.');
    }
    _signedIn = true;
  }

  @override
  Future<void> signInWithGoogle() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _signedIn = true;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _signedIn = false;
  }

  @override
  bool get isSignedIn => _signedIn;
}
