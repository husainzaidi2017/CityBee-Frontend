import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Rating pills used on cards and detail headers — one consistent brand
/// orange treatment everywhere (solid = on light bg, soft = on imagery).
/// [RatingPill.solid] — solid orange pill "★ 4.6".
/// [RatingPill.soft]  — light orange pill with count "★ 4.6 (1.2K)".
class RatingPill extends StatelessWidget {
  const RatingPill.green({super.key, required this.rating})
      : count = null,
        _soft = false;

  const RatingPill.soft({super.key, required this.rating, this.count})
      : _soft = true;

  final String rating;
  final String? count;
  final bool _soft;

  @override
  Widget build(BuildContext context) {
    final soft = _soft;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: soft ? AppColors.ratingSoft : AppColors.rating,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 13, color: soft ? AppColors.rating : Colors.white),
          const SizedBox(width: 3),
          Text(
            count == null ? rating : '$rating ($count)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: soft ? AppColors.ratingDark : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// "✓ CityBee Verified" green pill.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, this.label = 'CityBee Verified'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.verifiedGreenSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified, size: 13, color: AppColors.verifiedGreen),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.verifiedGreen,
            ),
          ),
        ],
      ),
    );
  }
}

/// "● Open Now" / "Opens at 11 AM" status pill.
class OpenStatusPill extends StatelessWidget {
  const OpenStatusPill({super.key, required this.isOpen, this.closedText = 'Opens at 11:00 AM'});

  final bool isOpen;
  final String closedText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen ? AppColors.openGreenSoft : const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 6, color: isOpen ? AppColors.openGreen : AppColors.brandRed),
          const SizedBox(width: 5),
          Text(
            isOpen ? 'Open Now' : closedText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isOpen ? AppColors.openGreen : AppColors.brandRed,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge colors for overlay ribbons on card images.
Color imageBadgeColor(String badge) {
  final b = badge.toUpperCase();
  if (b.contains('POPULAR') || b.contains('URGENT')) return AppColors.badgeRed;
  if (b.contains('%') || b.contains('OFF') || b.contains('NEW')) return AppColors.badgeOrange;
  if (b.contains('SPECIALTY')) return const Color(0xFF8A5A00);
  return AppColors.chipDark;
}

/// Row of small overlay badges ("VERIFIED", "POPULAR", "FLAT 15% OFF").
class ImageBadgeRow extends StatelessWidget {
  const ImageBadgeRow({super.key, required this.badges, this.verifiedFirst = true});

  final List<String> badges;
  final bool verifiedFirst;

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        for (final badge in badges)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badge == 'VERIFIED' ? AppColors.verifiedGreen : imageBadgeColor(badge),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
      ],
    );
  }
}

/// Small white pill pinned on card images ("📍 1.8 km").
class LocationPill extends StatelessWidget {
  const LocationPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on_outlined, size: 11, color: AppColors.textPrimary),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppTypography.label.copyWith(color: AppColors.textPrimary, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
