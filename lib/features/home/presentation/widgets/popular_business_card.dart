import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_launcher.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/badges.dart';
import '../../../../core/widgets/buttons.dart';
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
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
                    child: AppImage(url: business.images.first, width: 92, height: 92),
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
                  const SizedBox(height: 3),
                  Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    children: business.featureChips
                        .take(3)
                        .map((chip) => _MiniChip(label: chip))
                        .toList(),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          '${business.area} · ${business.distanceLabel} km',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.label.copyWith(fontSize: 10.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CardActionButton(
                        label: 'Call',
                        onTap: () => AppLauncher.call(business.phone),
                      ),
                      const SizedBox(width: 6),
                      CardActionButton(
                        label: 'Route',
                        onTap: () => AppLauncher.directions(
                          business.latitude,
                          business.longitude,
                          label: business.name,
                        ),
                      ),
                      const SizedBox(width: 6),
                      CardActionButton(
                        label: 'WhatsApp',
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

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
      ),
    );
  }
}
