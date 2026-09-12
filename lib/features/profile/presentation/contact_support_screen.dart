import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_launcher.dart';
import '../../../core/widgets/sub_page_scaffold.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import '../../../core/widgets/app_icons.dart';

/// Contact Support: WhatsApp, email and call channels plus response-time
/// expectations.
class ContactSupportScreen extends ConsumerWidget {
  const ContactSupportScreen({super.key});

  Future<void> _launch(
    BuildContext context,
    Future<bool> Function() action,
    String failMessage,
  ) async {
    final ok = await action();
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SubPageScaffold(
      title: 'Contact Support',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.bannerOrangeTop, AppColors.bannerOrangeBottom],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Iconify(AppUiIcons.face_agent,
                    color: Colors.white, size: 29),
                const SizedBox(height: 10),
                const Text(
                  'We usually reply within a few hours',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Support hours: 9 AM – 9 PM, all days. Hindi & English.',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SupportChannelCard(
            children: [
              _ChannelTile(
                icon: AppUiIcons.message_outline,
                title: 'WhatsApp Us',
                subtitle: AppConfig.supportWhatsApp,
                onTap: () => _launch(
                  context,
                  () => AppLauncher.whatsapp(
                    AppConfig.supportWhatsApp,
                    message:
                        'Hi CityBee support, I need help with the ${AppConfig.appName} app.',
                  ),
                  'Could not open WhatsApp. Please try email instead.',
                ),
              ),
              _ChannelTile(
                icon: AppUiIcons.email_outline,
                title: 'Email Support',
                subtitle: AppConfig.supportEmail,
                onTap: () => _launch(
                  context,
                  () => AppLauncher.email(
                    AppConfig.supportEmail,
                    subject: 'CityBee app support',
                  ),
                  'Could not open your email app.',
                ),
              ),
              _ChannelTile(
                icon: AppUiIcons.phone_outline,
                title: 'Call Support',
                subtitle: '+91 98765 43210',
                onTap: () => _launch(
                  context,
                  () => AppLauncher.call('+919876543210'),
                  'Could not open the dialer.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Before you write to us', style: AppTypography.titleSm),
                const SizedBox(height: 8),
                ...[
                  'Check the Help & FAQ — most questions are answered there.',
                  'For a wrong business listing, use “Report a problem” from the listing page.',
                  'For billing issues with a coupon, include the coupon code.',
                ].map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Iconify(AppUiIcons.check_circle_outline,
                            size: 13, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(child: Text(tip, style: AppTypography.caption)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportChannelCard extends StatelessWidget {
  const _SupportChannelCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Column(children: children),
    );
  }
}

class _ChannelTile extends StatelessWidget {
  const _ChannelTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Material keeps the ListTile ink ripple visible over the parent card.
    return Material(
      color: Colors.transparent,
      child: ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 13),
      leading: Iconify(icon, color: AppColors.primary, size: 20),
      title: Text(title, style: AppTypography.bodyStrong),
      subtitle: Text(subtitle, style: AppTypography.label.copyWith(fontSize: 10)),
      trailing:
          Iconify(AppUiIcons.chevron_right, size: 16, color: AppColors.textMuted),
      ),
    );
  }
}
