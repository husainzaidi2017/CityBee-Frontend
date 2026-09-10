import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_launcher.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/sub_page_scaffold.dart';
import '../../../providers/app_providers.dart';

/// About CityBee: brand story, stats, version info and quick links.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(selectedLocationProvider);

    return SubPageScaffold(
      title: 'About ${AppConfig.appName}',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          // ── Brand card ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppShadows.card,
            ),
            child: const Column(
              children: [
                BrandMark(markSize: 84, wordmarkSize: 48),
                SizedBox(height: 14),
                Text(
                  'Your city, in your pocket.',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Story ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Our story', style: AppTypography.titleSm),
                const SizedBox(height: 8),
                Text(
                  'CityBee helps you discover the best of your city — verified local '
                  'businesses, exclusive coupons, trusted doctors, restaurants, hotels '
                  'and hidden heritage gems. Born in ${location.state ?? location.displayName} (${location.displayName}), '
                  'we are building one city at a time with local teams who know every lane.',
                  style: AppTypography.body,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Stats ───────────────────────────────────────────────
          Row(
            children: const [
              Expanded(
                child: _AboutStat(value: '340+', label: 'Verified Experts'),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _AboutStat(value: '86', label: 'Live Offers'),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _AboutStat(value: '50K+', label: 'Happy Users'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Links ───────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.shield_outlined,
                      size: 19, color: AppColors.primary),
                  title: Text('Privacy Policy', style: AppTypography.bodyStrong),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      size: 19, color: AppColors.textMuted),
                  onTap: () => context.push('/privacy'),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.description_outlined,
                      size: 19, color: AppColors.primary),
                  title:
                      Text('Terms & Conditions', style: AppTypography.bodyStrong),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      size: 19, color: AppColors.textMuted),
                  onTap: () => context.push('/terms'),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.star_border_rounded,
                      size: 19, color: AppColors.starAmber),
                  title: Text('Rate CityBee', style: AppTypography.bodyStrong),
                  trailing: const Icon(Icons.open_in_new,
                      size: 16, color: AppColors.textMuted),
                  onTap: () => AppLauncher.openWebsite(AppConfig.playStoreUrl),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'CityBee v1.0.0 · Made in ${location.state ?? location.displayName} 💚',
              style: AppTypography.label.copyWith(fontSize: 9.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutStat extends StatelessWidget {
  const _AboutStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Text(value, style: AppTypography.titleSm.copyWith(fontSize: 16)),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.label.copyWith(fontSize: 9),
          ),
        ],
      ),
    );
  }
}
