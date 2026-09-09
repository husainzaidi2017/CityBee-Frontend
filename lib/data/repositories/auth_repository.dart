/// Contract for authentication.
///
/// The mock implementation simulates flows in memory; the Supabase
/// implementation maps Google sign-in onto the native picker +
/// `signInWithIdToken`, and account creation onto signUp + email OTP
/// verification, without any UI changes.
abstract class AuthRepository {
  /// Native Google sign-in: account picker → Google ID token → Supabase
  /// session (see SupabaseAuthRepository for the full flow).
  Future<void> signInWithGoogle();

  /// Email+password sign-in for existing accounts.
  Future<void> signInWithPassword(String email, String password);

  /// CREATE ACCOUNT (step 1): registers name/email/password and sends a
  /// 6-digit OTP to the email. No session is established yet — the account
  /// only becomes usable after [verifyOtp].
  Future<void> createAccount(String name, String email, String password);

  /// Re-sends the account-creation OTP (subject to Supabase rate limits).
  Future<void> resendOtp(String email);

  /// CREATE ACCOUNT (step 2): verifies the 6-digit code and establishes the
  /// session. The account is only active after this succeeds.
  Future<void> verifyOtp(String email, String otp);

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
  Future<void> createAccount(String name, String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<void> resendOtp(String email) async {
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
  Future<void> signInWithPassword(String email, String password) async {
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
