import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_launcher.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/pressable.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../providers/app_providers.dart';

/// CityBee login — phone (+91, 10-digit) with OTP, WhatsApp OTP, Google,
/// guest browsing and a business-owner section. Login is never mandatory:
/// guests can browse everything.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  String? _phoneError;
  bool _busy = false;

  static final _digitsOnly = FilteringTextInputFormatter.digitsOnly;
  static final _phoneRegex = RegExp(r'^[6-9]\d{9}$');

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  bool get _isPhoneValid => _phoneRegex.hasMatch(_phoneController.text.trim());

  Future<void> _handleGetOtp({OtpChannel channel = OtpChannel.sms}) async {
    final phone = _phoneController.text.trim();
    if (!_isPhoneValid) {
      setState(() => _phoneError = 'Enter a valid 10-digit mobile number');
      return;
    }
    setState(() {
      _phoneError = null;
      _busy = true;
    });
    try {
      await ref.read(authStateProvider.notifier).sendOtp('91$phone', channel: channel);
      if (!mounted) return;
      await _showOtpSheet(phone, channel);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _handleGoogle() async {
    setState(() => _busy = true);
    try {
      await ref.read(authStateProvider.notifier).signInWithGoogle();
      if (!mounted) return;
      _greetAndGoHome();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _greetAndGoHome() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Welcome to CityBee!')),
    );
    context.go('/');
  }

  Future<void> _showOtpSheet(String phone, OtpChannel channel) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _OtpSheet(
        phone: phone,
        channel: channel,
        onVerified: () {
          Navigator.of(context).pop();
          _greetAndGoHome();
        },
      ),
    );
  }

  Future<void> _openBusinessListing() async {
    final ok = await AppLauncher.openWebsite(AppConfig.businessListingUrl);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the browser.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                'Welcome to CityBee 👋',
                textAlign: TextAlign.center,
                style: AppTypography.headline,
              ),
              const SizedBox(height: 6),
              Text(
                'Sign in to save favorites, claim coupons and get\npersonalized deals near you.',
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(fontSize: 12.5, height: 1.5),
              ),
              const SizedBox(height: 30),

              // ── Phone card ──────────────────────────────────────
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
                    Text('Phone Number', style: AppTypography.label),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          height: 46,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border, width: 1.1),
                          ),
                          child: Row(
                            children: [
                              Text('🇮🇳', style: const TextStyle(fontSize: 15)),
                              const SizedBox(width: 6),
                              Text('+91',
                                  style: AppTypography.bodyStrong.copyWith(fontSize: 14)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [_digitsOnly, LengthLimitingTextInputFormatter(10)],
                            style: AppTypography.body.copyWith(fontSize: 14.5),
                            decoration: InputDecoration(
                              hintText: '98765 43210',
                              errorText: _phoneError,
                              isDense: true,
                            ),
                            onChanged: (_) {
                              if (_phoneError != null) {
                                setState(() => _phoneError = null);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Pressable(
                      onTap: _busy ? null : () => _handleGetOtp(),
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
                                'Get OTP / Continue',
                                style: AppTypography.bodyStrong.copyWith(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // WhatsApp OTP — same flow, delivered on WhatsApp.
                    _SocialButton(
                      icon: Icons.chat_bubble_outline_rounded,
                      iconColor: const Color(0xFF16A34A),
                      label: 'Get OTP on WhatsApp',
                      onPressed: _busy ? null : () => _handleGetOtp(channel: OtpChannel.whatsapp),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ── Divider ─────────────────────────────────────────
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or continue with', style: AppTypography.label),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 18),

              // ── Google ──────────────────────────────────────────
              _SocialButton(
                icon: Icons.g_mobiledata_rounded,
                iconColor: AppColors.textPrimary,
                iconSize: 26,
                label: 'Continue with Google',
                onPressed: _busy ? null : _handleGoogle,
              ),
              const SizedBox(height: 12),

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
                            'List it free on CityBee & reach 50,000+ locals',
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

/// OTP verification sheet (SMS or WhatsApp).
class _OtpSheet extends ConsumerStatefulWidget {
  const _OtpSheet({
    required this.phone,
    required this.channel,
    required this.onVerified,
  });

  final String phone;
  final OtpChannel channel;
  final VoidCallback onVerified;

  @override
  ConsumerState<_OtpSheet> createState() => _OtpSheetState();
}

class _OtpSheetState extends ConsumerState<_OtpSheet> {
  final _otpController = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_otpController.text.trim().length != 6) {
      setState(() => _error = 'Enter the 6-digit OTP');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(authStateProvider.notifier)
          .verifyOtp('91${widget.phone}', _otpController.text.trim());
      widget.onVerified();
    } on AuthException catch (e) {
      setState(() => _error = e.userMessage);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viaWhatsApp = widget.channel == OtpChannel.whatsapp;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Verify your number', style: AppTypography.title),
              const SizedBox(height: 5),
              Text(
                viaWhatsApp
                    ? 'We sent a 6-digit code to +91 ${widget.phone} on WhatsApp.'
                    : 'We sent a 6-digit code to +91 ${widget.phone}.',
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
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Demo build: use OTP 123456',
                  style: AppTypography.label.copyWith(fontSize: 10),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onPressed,
    this.iconSize = 20,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback? onPressed;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onPressed,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.border, width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize, color: iconColor),
            const SizedBox(width: 9),
            Text(label, style: AppTypography.bodyStrong.copyWith(fontSize: 13.5)),
          ],
        ),
      ),
    );
  }
}
