import 'package:flutter/material.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/sub_page_scaffold.dart';

/// Long-form legal content (Privacy Policy / Terms & Conditions) sharing one
/// styled screen.
class LegalScreen extends StatelessWidget {
  const LegalScreen.privacy({super.key})
      : title = 'Privacy Policy',
        _sections = _privacySections,
        _updated = 'Last updated: 1 September 2026';

  const LegalScreen.terms({super.key})
      : title = 'Terms & Conditions',
        _sections = _termsSections,
        _updated = 'Last updated: 1 September 2026';

  final String title;
  final String _updated;
  final List<(String, String)> _sections;

  static const _privacySections = <(String, String)>[
    (
      'Information we collect',
      'When you use CityBee we collect: your name, phone number and email if you '
          'create an account; your selected city; and technical data such as device '
          'model and app version. If you grant location permission, we use your '
          'coordinates only to find nearby businesses — never to track you.'
    ),
    (
      'How we use it',
      'Your information powers your experience: showing offers and businesses near '
          'you, saving your favorites and bookmarks, and improving listings. We do '
          'not sell your personal data to anyone.'
    ),
    (
      'Coupons & businesses',
      'Coupon redemption happens directly between you and the business. We share '
          'only the coupon code with the merchant — never your contact details — '
          'unless you choose to contact them via call or WhatsApp.'
    ),
    (
      'Your rights',
      'You can request a copy or deletion of your data anytime from Settings → '
          'Contact Support. Deleting the app removes locally stored preferences; '
          'account data is deleted on request within 30 days.'
    ),
    (
      'Contact',
      'Questions about this policy? Reach us at support@citybee.app.'
    ),
  ];

  static const _termsSections = <(String, String)>[
    (
      'Using CityBee',
      'CityBee connects you with local businesses, offers and places. Content is '
          'provided for personal, non-commercial use. You agree to use the app '
          'lawfully and not to scrape, resell or misuse listings or coupon codes.'
    ),
    (
      'Coupons & offers',
      'Coupons are issued by the businesses themselves. Validity, conditions and '
          'discount amounts are set by the merchant; CityBee is not responsible for '
          'a merchant refusing an expired or misused code. One coupon per bill '
          'unless stated otherwise.'
    ),
    (
      'Business listings',
      'Listing information (hours, prices, contact numbers) is provided by '
          'businesses and may change. While we verify listed businesses, CityBee '
          'is not liable for the quality of goods or services purchased from them.'
    ),
    (
      'Accounts',
      'You are responsible for keeping your account credentials safe. We may '
          'suspend accounts used for fraud, spam or abuse of coupon systems.'
    ),
    (
      'Changes',
      'We may update these terms as the service grows. Continued use after an '
          'update means you accept the revised terms.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: title,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Text(
            '$title — ${AppConfig.appName}',
            style: AppTypography.title,
          ),
          const SizedBox(height: 4),
          Text(_updated, style: AppTypography.label),
          const SizedBox(height: 16),
          ..._sections.map(
            (section) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(15),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(section.$1, style: AppTypography.titleSm),
                  const SizedBox(height: 6),
                  Text(section.$2, style: AppTypography.body.copyWith(height: 1.55)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
