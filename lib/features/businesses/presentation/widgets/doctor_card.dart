import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_launcher.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/badges.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../../domain/models/business.dart';

/// Compact row card used ONLY on the doctors listing — small photo on the
/// left, doctor identity and speciality info on the right (the same shape
/// as "Popular Near You" on Home). Keeps Call/Route/Book Visit actions.
class DoctorCard extends StatelessWidget {
  const DoctorCard({super.key, required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    final speciality = business.specialization ??
        business.tagline.split('·').first.trim();

    return Pressable(
      onTap: () => context.push('/business/${business.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 11),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── photo with rating + open dot overlay ───────────────
            SizedBox(
              width: 84,
              height: 104,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AppImage(
                      url: business.images.firstOrNull ?? '',
                      width: 84,
                      height: 104,
                      fallbackIcon: Icons.medical_services_outlined,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.circle,
                        size: 8,
                        color: business.isOpen
                            ? AppColors.openGreen
                            : AppColors.textMuted,
                      ),
                    ),
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
            // ── doctor identity ─────────────────────────────────────
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
                    [
                      speciality,
                      if (business.qualification != null &&
                          business.qualification!.isNotEmpty)
                        business.qualification,
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          '${business.area} · ${business.distanceLabel} km',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.label,
                        ),
                      ),
                      if (business.consultationFee != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          'Fee ${business.consultationFee}',
                          style: AppTypography.label.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    business.openingHours,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label.copyWith(
                        color: business.isOpen
                            ? AppColors.textSecondary
                            : AppColors.brandRed),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CardActionButton(
                        label: 'Call',
                        icon: Icons.call_outlined,
                        onTap: () => AppLauncher.call(business.phone),
                      ),
                      const SizedBox(width: 6),
                      CardActionButton(
                        label: 'Route',
                        icon: Icons.near_me_outlined,
                        onTap: () => AppLauncher.directions(
                          business.latitude,
                          business.longitude,
                          label: business.name,
                        ),
                      ),
                      const SizedBox(width: 6),
                      CardActionButton(
                        label: 'Book Visit',
                        icon: Icons.event_available_outlined,
                        filled: true,
                        onTap: () => context.push('/business/${business.id}'),
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
