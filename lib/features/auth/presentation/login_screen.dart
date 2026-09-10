import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/pressable.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../providers/app_providers.dart';

/// CityBee login — Google first, email OTP second, guest browsing always
/// available. Login is never mandatory: guests can browse everything.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _emailError;
  bool _googleBusy = false;
  bool _emailBusy = false;
  bool _isSignUp = false;
  bool _showPassword = false;

  static final _emailRegex = RegExp(r'^[\w.\-+]+@([\w\-]+\.)+[a-zA-Z]{2,}$');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isEmailValid => _emailRegex.hasMatch(_emailController.text.trim());

  /// Email card action. SIGN IN: password login. CREATE ACCOUNT:
  /// validates name/email/password, registers the account (no session),
  /// then opens the OTP sheet — the account only activates on correct OTP.
  Future<void> _handleEmailPassword() async {
    final email = _emailController.text.trim();
    if (!_isEmailValid) {
      setState(() => _emailError = 'Enter a valid email address');
      return;
    }
    final password = _passwordController.text;
    if (password.length < 6) {
      setState(() => _emailError = 'Password must be at least 6 characters');
      return;
    }
    if (_isSignUp && _nameController.text.trim().length < 2) {
      setState(() => _emailError = 'Please enter your full name');
      return;
    }
    setState(() {
      _emailError = null;
      _emailBusy = true;
    });
    try {
      if (_isSignUp) {
        await ref
            .read(authStateProvider.notifier)
            .createAccount(_nameController.text.trim(), email, password);
        if (!mounted) return;
        await _showOtpSheet(email);
      } else {
        await ref
            .read(authStateProvider.notifier)
            .signInWithPassword(email, password);
        if (!mounted) return;
        _greetAndGoHome();
      }
    } on AuthException catch (e) {
      final m = e.userMessage.toLowerCase();
      if (!_isSignUp && m.contains('wrong email or password')) {
        setState(() => _isSignUp = true);
        _showError('No password found for this email — create one below.');
      } else {
        _showError(e.userMessage);
      }
    } finally {
      if (mounted) setState(() => _emailBusy = false);
    }
  }

  Future<void> _handleGoogle() async {
    if (_googleBusy) return;
    setState(() => _googleBusy = true);
    try {
      await ref.read(authStateProvider.notifier).signInWithGoogle();
      if (!mounted) return;
      _greetAndGoHome();
    } on AuthException catch (e) {
      if (mounted) _showError(e.userMessage);
    } catch (_) {
      if (mounted) _showError('Unable to sign in with Google. Please try again.');
    } finally {
      if (mounted) setState(() => _googleBusy = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _greetAndGoHome() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Welcome to CityBee!')),
    );
    context.go('/');
  }

  Future<void> _showOtpSheet(String email) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _OtpSheet(
        email: email,
        onVerified: () {
          Navigator.of(context).pop();
          _greetAndGoHome();
        },
      ),
    );
  }

  void _openBusinessListing() {
    // In-app List Your Business wizard.
    context.push('/list-business');
  }

  @override
  Widget build(BuildContext context) {
    final busy = _googleBusy || _emailBusy;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 44),

              // ── Brand ───────────────────────────────────────────
              const Center(child: BrandMark(markSize: 64, wordmarkSize: 38)),
              const SizedBox(height: 26),
              Text(
                'Welcome to CityBee',
                textAlign: TextAlign.center,
                style: AppTypography.headline,
              ),
              const SizedBox(height: 6),
              Text(
                'Sign in to save favorites and get\npersonalized deals near you.',
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(fontSize: 12.5, height: 1.5),
              ),
              const SizedBox(height: 30),

              // ── Google (primary) ────────────────────────────────
              _GoogleButton(
                busy: _googleBusy,
                onPressed: busy ? null : _handleGoogle,
              ),
              const SizedBox(height: 18),

              // ── Divider ─────────────────────────────────────────
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('OR', style: AppTypography.label),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 18),

              // ── Email card (secondary: password sign-in) ─────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Continue with Email', style: AppTypography.label),
                    const SizedBox(height: 8),
                    if (_isSignUp) ...[
                      TextField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        autocorrect: false,
                        style: AppTypography.body.copyWith(fontSize: 14.5),
                        decoration: const InputDecoration(
                          hintText: 'Your full name',
                          isDense: true,
                          prefixIcon: Icon(Icons.person_outline_rounded,
                              size: 18, color: AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      style: AppTypography.body.copyWith(fontSize: 14.5),
                      decoration: InputDecoration(
                        hintText: 'you@example.com',
                        errorText: _emailError,
                        isDense: true,
                        prefixIcon: const Icon(Icons.alternate_email_rounded,
                            size: 18, color: AppColors.textSecondary),
                      ),
                      onChanged: (_) {
                        if (_emailError != null) {
                          setState(() => _emailError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      autocorrect: false,
                      style: AppTypography.body.copyWith(fontSize: 14.5),
                      decoration: InputDecoration(
                        hintText: _isSignUp ? 'Choose a password (6+ chars)' : 'Password',
                        isDense: true,
                        prefixIcon: const Icon(Icons.lock_outline_rounded,
                            size: 18, color: AppColors.textSecondary),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () =>
                              setState(() => _showPassword = !_showPassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Pressable(
                      onTap: busy ? null : _handleEmailPassword,
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: _emailBusy
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                _isSignUp ? 'Create Account' : 'Sign In',
                                style: AppTypography.bodyStrong.copyWith(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: busy
                            ? null
                            : () => setState(() {
                                  _isSignUp = !_isSignUp;
                                  _emailError = null;
                                }),
                        child: Text(
                          _isSignUp
                              ? 'Have an account? Sign in'
                              : 'New here? Create an account',
                          style: AppTypography.label
                              .copyWith(color: AppColors.primary, fontSize: 11.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Guest ───────────────────────────────────────────
              TextButton(
                onPressed: () => context.go('/'),
                child: Text(
                  'Browse as Guest →',
                  style: AppTypography.bodyStrong
                      .copyWith(color: AppColors.primary, fontSize: 13.5),
                ),
              ),
              const SizedBox(height: 20),

              // ── Business / merchant section ─────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.bannerOrangeTop, AppColors.bannerOrangeBottom],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(Icons.storefront, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Own a business?',
                            style: AppTypography.bodyStrong.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'List it free on CityBee & reach locals nearby',
                            style: AppTypography.label.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _openBusinessListing,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'List Now',
                          style: AppTypography.bodyStrong.copyWith(
                            color: AppColors.primaryDark,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Terms ───────────────────────────────────────────
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('By continuing you agree to our ',
                      style: AppTypography.label.copyWith(fontSize: 10.5)),
                  GestureDetector(
                    onTap: () => context.push('/terms'),
                    child: Text(
                      'Terms',
                      style: AppTypography.label
                          .copyWith(color: AppColors.primary, fontSize: 10.5),
                    ),
                  ),
                  Text(' & ', style: AppTypography.label.copyWith(fontSize: 10.5)),
                  GestureDetector(
                    onTap: () => context.push('/privacy'),
                    child: Text(
                      'Privacy Policy',
                      style: AppTypography.label
                          .copyWith(color: AppColors.primary, fontSize: 10.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Email OTP verification sheet.
class _OtpSheet extends ConsumerStatefulWidget {
  const _OtpSheet({
    required this.email,
    required this.onVerified,
  });

  final String email;
  final VoidCallback onVerified;

  @override
  ConsumerState<_OtpSheet> createState() => _OtpSheetState();
}

class _OtpSheetState extends ConsumerState<_OtpSheet> {
  final _otpController = TextEditingController();
  bool _busy = false;
  String? _error;

  /// Resend cooldown (seconds) — mirrors Supabase's rate limit so the UI
  /// doesn't hit the endpoint before the server would allow it anyway.
  static const _resendCooldownSeconds = 60;
  int _cooldown = 0;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }


  void _startCooldown() {
    _cooldown = _resendCooldownSeconds;
    _tickCooldown();
  }

  void _tickCooldown() {
    if (!mounted) return;
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _cooldown--);
      if (_cooldown > 0) _tickCooldown();
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _resend() async {
    if (_cooldown > 0 || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authStateProvider.notifier).resendOtp(widget.email);
      if (mounted) {
        _otpController.clear();
        _startCooldown();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New code sent to your email.')),
        );
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.userMessage);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    if (_otpController.text.trim().length != 6) {
      setState(() => _error = 'Enter the 6-digit code');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(authStateProvider.notifier)
          .verifyOtp(widget.email, _otpController.text.trim());
      widget.onVerified();
    } on AuthException catch (e) {
      setState(() => _error = e.userMessage);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If the user activates via the email LINK (deep link) instead of
    // typing the code, the session appears here — finish immediately.
    ref.listen<bool>(authStateProvider, (previous, next) {
      if (next && previous != true) {
        Navigator.of(context).maybePop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Welcome to CityBee!')),
        );
        context.go('/');
      }
    });
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Verify your email', style: AppTypography.title),
              const SizedBox(height: 5),
              Text(
                'We sent a verification email to ${widget.email}.\n'
                'Tap the link in the email to continue — or enter the '
                '6-digit code if your email shows one.',
                style: AppTypography.caption,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _otpController,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                style: AppTypography.headline.copyWith(
                  fontSize: 24,
                  letterSpacing: 8,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '••••••',
                  errorText: _error,
                ),
              ),
              const SizedBox(height: 14),
              Pressable(
                onTap: _busy ? null : _verify,
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          'Verify & Continue',
                          style: AppTypography.bodyStrong
                              .copyWith(color: Colors.white, fontSize: 14),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              // Resend with cooldown — kept aligned with Supabase rate limits.
              Center(
                child: TextButton(
                  onPressed: _cooldown > 0 || _busy ? null : _resend,
                  child: Text(
                    _cooldown > 0
                        ? 'Resend code in ${_cooldown}s'
                        : 'Resend code',
                    style: AppTypography.label.copyWith(
                      color: _cooldown > 0 ? AppColors.textMuted : AppColors.primary,
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Official Google sign-in button treatment: white card, the multi-colour
/// Google "G" (per Google branding), Hanken Grotesk label. Shows a spinner
/// and blocks repeat taps while authentication is in flight.
class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.busy, required this.onPressed});

  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: busy ? null : onPressed,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.border, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (busy)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const _GoogleLogo(size: 22),
            const SizedBox(width: 12),
            Text(
              busy ? 'Signing in…' : 'Continue with Google',
              style: AppTypography.bodyStrong.copyWith(fontSize: 14.5),
            ),
          ],
        ),
      ),
    );
  }
}

/// Official multi-colour Google "G" logo drawn as a custom painter
/// (Google brand guidelines; no fake substitute glyph).
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo({this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  // Google brand colours.
  static const _blue = Color(0xFF4285F4);
  static const _green = Color(0xFF34A853);
  static const _yellow = Color(0xFFFBBC05);
  static const _red = Color(0xFFEA4335);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final stroke = s * 0.095;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    // Centre of the G.
    final c = Offset(s / 2, s / 2);
    final radius = (s - stroke) / 2 - s * 0.02;

    // Blue arc: top-right → bottom (crossbar originates here).
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: radius),
      -1.05, // ~-60°
      2.1,
      false,
      paint..color = _blue,
    );
    // Red arc: bottom → left.
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: radius),
      1.05,
      2.1,
      false,
      paint..color = _red,
    );
    // Yellow arc: left → top-left.
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: radius),
      3.15,
      2.1,
      false,
      paint..color = _yellow,
    );
    // Green arc: top-left → top.
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: radius),
      5.25,
      1.8,
      false,
      paint..color = _green,
    );

    // Horizontal crossbar of the G (blue).
    final barPaint = Paint()..color = _blue;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(c.dx, c.dy),
          width: radius * 1.15,
          height: stroke,
        ),
        Radius.circular(stroke / 2),
      ),
      barPaint,
    );
    // Vertical connector from crossbar to the blue arc end.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(c.dx + radius * 0.575, c.dy - stroke * 0.9),
          width: stroke,
          height: stroke * 2.2,
        ),
        Radius.circular(stroke / 2),
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GoogleLogoPainter oldDelegate) => false;
}
