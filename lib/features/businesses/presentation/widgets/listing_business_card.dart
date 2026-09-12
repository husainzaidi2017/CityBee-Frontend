import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_launcher.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/badges.dart';
import '../../../../core/widgets/map_preview.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../../domain/models/business.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import '../../../../core/widgets/app_icons.dart';

/// Compact horizontal business card used by ALL category listing screens:
/// square thumbnail left, name/rating/meta right (matches the Doctors
/// pattern — several results visible per screen). Tapping opens details;
/// quick Call/Route actions are one tap away inside the card.
class ListingBusinessCard extends StatelessWidget {
  const ListingBusinessCard({super.key, required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => context.push('/business/${business.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 11),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: const [
            BoxShadow(color: Color(0x10000000), blurRadius: 6, offset: Offset(0, 1)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail: badges + open dot + rating ────────────────
            SizedBox(
              width: 96,
              height: 108,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AppImage(
                      url: business.images.firstOrNull ?? '',
                      width: 96,
                      height: 108,
                    ),
                  ),
                  if (business.isVerified)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Iconify(AppUiIcons.check_decagram,
                            size: 10, color: AppColors.verifiedGreen),
                      ),
                    ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Iconify(
                        AppUiIcons.circle,
                        size: 6,
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
            // ── Content ─────────────────────────────────────────────
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
                    '${business.tagline} · ${business.priceText ?? _defaultPrice(business)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Iconify(AppUiIcons.map_marker_outline,
                          size: 10, color: AppColors.textSecondary),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          '${business.area} · ${business.distanceLabel} km',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.label,
                        ),
                      ),
                      Text(
                        business.isOpen ? 'Open Now' : 'Closed',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: business.isOpen
                              ? AppColors.openGreen
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    business.openingHours,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _QuickAction(
                        label: 'Call',
                        icon: AppUiIcons.phone_outline,
                        onTap: () => AppLauncher.call(business.phone),
                      ),
                      const SizedBox(width: 6),
                      _QuickAction(
                        label: 'Route',
                        icon: AppUiIcons.near_me,
                        onTap: () => AppLauncher.directions(
                          business.latitude,
                          business.longitude,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _QuickAction(
                        label: 'Details',
                        icon: AppUiIcons.chevron_right,
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

  String _defaultPrice(Business business) => switch (business.kind) {
        BusinessKind.hotel => '₹1,400+',
        BusinessKind.doctor => business.consultationFee ?? '₹300',
        _ => '₹200–₹600 for two',
      };
}

/// Compact pill action inside the listing row.
class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Pressable(
        onTap: onTap,
        pressedScale: 0.96,
        child: Container(
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Iconify(icon, size: 12, color: AppColors.primary),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
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

/// Map view page used when the listing screen toggles to map mode.
class BusinessesMapPage extends StatelessWidget {
  const BusinessesMapPage({super.key, required this.businesses});

  final List<Business> businesses;

  @override
  Widget build(BuildContext context) {
    // Pin positions derived from the businesses' REAL coordinates (min/max
    // normalized into the padded canvas) so pins correspond to geography.
    final withCoords = businesses
        .where((b) => b.latitude != 0 && b.longitude != 0)
        .toList();
    final minLat = withCoords.map((b) => b.latitude).reduce((a, b) => a < b ? a : b);
    final maxLat = withCoords.map((b) => b.latitude).reduce((a, b) => a > b ? a : b);
    final minLng = withCoords.map((b) => b.longitude).reduce((a, b) => a < b ? a : b);
    final maxLng = withCoords.map((b) => b.longitude).reduce((a, b) => a > b ? a : b);
    double normalize(double v, double min, double max) =>
        max == min ? 0.5 : ((v - min) / (max - min)).clamp(0.0, 1.0);

    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              return Stack(
                children: [
                  Positioned.fill(
                    // Stylized map canvas; swap for GoogleMap when the API
                    // key is configured.
                    child: MapPreview(
                      latitude: businesses.firstOrNull?.latitude ?? 28.8386,
                      longitude: businesses.firstOrNull?.longitude ?? 78.7733,
                      height: null,
                      showOpenMap: false,
                    ),
                  ),
                  // Business pins, positioned by their coordinates.
                  for (final b in withCoords)
                    Positioned(
                      left: 30 + normalize(b.longitude, minLng, maxLng) * (w - 150),
                      top: 50 + normalize(b.latitude, minLat, maxLat) * (h - 140),
                      child: GestureDetector(
                        onTap: () => context.push('/business/${b.id}'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Iconify(AppUiIcons.map_marker,
                                  size: 12, color: AppColors.brandRed),
                              const SizedBox(width: 4),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 90),
                                child: Text(
                                  b.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
