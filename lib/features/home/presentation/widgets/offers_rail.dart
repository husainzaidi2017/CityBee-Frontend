import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/badges.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../../domain/models/offer.dart';

/// Horizontal rail of "Offers Near You" cards on the Home screen.
class OffersRail extends StatelessWidget {
  const OffersRail({super.key, required this.offers});

  final List<Offer> offers;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 188,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: offers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => _HomeOfferCard(offer: offers[index]),
      ),
    );
  }
}

class _HomeOfferCard extends StatelessWidget {
  const _HomeOfferCard({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => context.push('/offer/${offer.id}'),
      child: Container(
        width: 232,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── image with badge + overlay text ──────────────────────
            SizedBox(
              height: 112,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppImage(url: offer.image, fallbackIcon: Icons.local_offer_rounded),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.transparent, Color(0xCC000000)],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.badgeOrange,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        offer.badgeText,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${offer.badgeText} ${_titleLine(offer)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          '${offer.title.toUpperCase()} · ${offer.categoryTag.toUpperCase()}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.85),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // ── white footer ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textSecondary),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                '${offer.area} · ${offer.distanceText}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.label,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        RatingPill.soft(rating: offer.rating.toStringAsFixed(1)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _titleLine(Offer offer) => offer.subtitle.replaceFirst(RegExp('^on '), '');
}
