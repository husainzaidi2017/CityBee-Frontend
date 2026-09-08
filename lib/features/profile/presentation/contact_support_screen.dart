import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_launcher.dart';
import '../../../core/widgets/sub_page_scaffold.dart';

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
                const Icon(Icons.support_agent_rounded,
                    color: Colors.white, size: 34),
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
                icon: Icons.chat_bubble_outline_rounded,
                iconColor: const Color(0xFF16A34A),
                iconBg: const Color(0xFFE3F6E9),
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
                icon: Icons.mail_outline_rounded,
                iconColor: AppColors.catDoctor,
                iconBg: AppColors.catDoctorSoft,
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
                icon: Icons.call_outlined,
                iconColor: AppColors.primary,
                iconBg: AppColors.primarySoft,
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
              border: Border.all(color: AppColors.border),
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
                        const Icon(Icons.check_circle_outline,
                            size: 15, color: AppColors.primary),
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
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

class _ChannelTile extends StatelessWidget {
  const _ChannelTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 13),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, color: iconColor, size: 19),
      ),
      title: Text(title, style: AppTypography.bodyStrong),
      subtitle: Text(subtitle, style: AppTypography.label.copyWith(fontSize: 10)),
      trailing:
          const Icon(Icons.chevron_right_rounded, size: 19, color: AppColors.textMuted),
    );
  }
}
