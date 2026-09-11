import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_launcher.dart';
import '../../../../core/widgets/app_icons.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/badges.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../../domain/models/business.dart';

/// Compact vertical business card used by "Popular Near You" on Home.
class PopularBusinessCard extends StatelessWidget {
  const PopularBusinessCard({super.key, required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => context.push('/business/${business.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── thumbnail with rating overlay ────────────────────────
            SizedBox(
              width: 92,
              height: 92,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AppImage(url: business.images.firstOrNull ?? '', width: 92, height: 92),
                  ),
                  Positioned(
                    bottom: 4,
                    left: 4,
                    child: RatingPill.soft(rating: business.ratingLabel),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 11),
            // ── content ──────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleSm,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    business.tagline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          '${business.area.isEmpty ? business.cityName : business.area} · ${business.distanceLabel} km',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.label,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _IconAction(
                        icon: AppIcons.callAsset,
                        onTap: () => AppLauncher.call(business.phone),
                      ),
                      const SizedBox(width: 8),
                      _IconAction(
                        icon: AppIcons.directionsAsset,
                        onTap: () => AppLauncher.directions(
                          business.latitude,
                          business.longitude,
                          label: business.name,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _IconAction(
                        icon: AppIcons.whatsappAsset,
                        onTap: () => AppLauncher.whatsapp(business.whatsapp),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular icon-only quick action (Call / Route / WhatsApp) — no label,
/// 40px tap target with the custom SVG brand icons.
class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.onTap});

  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.92,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Center(child: AppIcons.action(icon, size: 18)),
      ),
    );
  }
}
