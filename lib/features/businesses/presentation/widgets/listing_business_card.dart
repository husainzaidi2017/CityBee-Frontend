import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_launcher.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/badges.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/map_preview.dart';
import '../../../../domain/models/business.dart';

/// Full-width business card used by listing screens: image with badges,
/// name + verified, chips, address row, and Call/Route/Menu actions.
class ListingBusinessCard extends StatelessWidget {
  const ListingBusinessCard({super.key, required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/business/${business.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image row with badges + location pill ──────────────
            SizedBox(
              height: 120,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppImage(url: business.images.first),
                  Positioned(
                    top: 9,
                    left: 10,
                    child: ImageBadgeRow(
                      badges: [
                        if (business.isVerified) 'VERIFIED',
                        ...business.imageBadges.where((b) => b != 'VERIFIED'),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 9,
                    right: 10,
                    child: LocationPill(label: '${business.distanceLabel} km'),
                  ),
                ],
              ),
            ),
            // ── Content ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          business.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.titleSm,
                        ),
                      ),
                      const SizedBox(width: 6),
                      RatingPill.green(rating: business.ratingLabel),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${business.tagline} · ${business.priceText ?? _defaultPrice(business)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    children: business.featureChips
                        .take(3)
                        .map((chip) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                chip,
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      OpenStatusPill(isOpen: business.isOpen),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${business.area} · ${business.openingHours}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.label.copyWith(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (var i = 0; i < business.actionButtons.length; i++) ...[
                        if (i > 0) const SizedBox(width: 7),
                        CardActionButton(
                          label: business.actionButtons[i],
                          filled: i == business.actionButtons.length - 1,
                          onTap: () => _onAction(context, business.actionButtons[i]),
                        ),
                      ],
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

  void _onAction(BuildContext context, String action) {
    switch (action) {
      case 'Call':
        AppLauncher.call(business.phone);
      case 'Route':
        AppLauncher.directions(
          business.latitude,
          business.longitude,
          label: business.name,
        );
      case 'Menu':
      case 'Book Visit':
      case 'Website':
        context.go('/business/${business.id}');
      case 'WhatsApp':
        AppLauncher.whatsapp(business.whatsapp);
    }
  }
}

/// Map view page used when the listing screen toggles to map mode.
class BusinessesMapPage extends StatelessWidget {
  const BusinessesMapPage({super.key, required this.businesses});

  final List<Business> businesses;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
          children: [
            Positioned.fill(
              // Full-bleed map placeholder; swap for GoogleMap when the
              // API key is configured.
              child: MapPreview(
                latitude: businesses.firstOrNull?.latitude ?? 28.8386,
                longitude: businesses.firstOrNull?.longitude ?? 78.7733,
                height: null,
                showOpenMap: false,
              ),
            ),
              // Business pins.
              ...businesses.map((b) {
                final index = businesses.indexOf(b);
                return Positioned(
                  left: 40.0 + (index % 3) * 100,
                  top: 60.0 + (index % 4) * 90,
                  child: GestureDetector(
                    onTap: () => context.go('/business/${b.id}'),
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
                          const Icon(Icons.location_on,
                              size: 14, color: AppColors.brandRed),
                          const SizedBox(width: 4),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 90),
                            child: Text(
                              b.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
