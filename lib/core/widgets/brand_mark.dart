import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Official CityBee brand lockup, used everywhere the app shows the brand.
///
/// The bee/map-pin mark is rendered from the official SVG asset
/// (`assets/brand/citybee_mark.svg`, extracted verbatim from the official
/// `citybee_logo.svg`). The "CityBee" wordmark is rendered natively with
/// the Outfit 800 font — the same font the official SVG specifies — because
/// flutter_svg cannot rasterize SVG `<text>` elements.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.markSize = 30, this.wordmarkSize = 19});

  /// Height of the bee mark (SVG aspect ratio is 110:120).
  final double markSize;

  /// Font size of the "CityBee" wordmark.
  final double wordmarkSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/brand/citybee_mark.svg',
          height: markSize,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 7),
        Text.rich(
          TextSpan(
            text: 'City',
            style: TextStyle(
              fontFamily: AppTypography.displayFamily,
              fontSize: wordmarkSize,
              fontWeight: FontWeight.w800,
              color: AppColors.brandOrange,
              letterSpacing: -0.5,
              height: 1.1,
            ),
            children: [
              TextSpan(
                text: 'Bee',
                style: TextStyle(color: AppColors.brandInk),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
