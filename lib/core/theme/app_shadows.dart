import 'package:flutter/material.dart';

/// Soft, layered card shadows used across the design.
///
/// Cards separate from the background by elevation (shadow), not hairline
/// borders — the borderless "native card" look. Shadows are NEUTRAL grey
/// (never tinted) and tightly bound (small blur + offset) so they can never
/// glow past a card's neighbours or read as a warm/orange haze on the
/// off-white background.
abstract final class AppShadows {
  /// Standard card elevation: soft, tight, neutral.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> cardStrong = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 14,
      offset: Offset(0, 4),
    ),
  ];

  /// Shadow for floating elements (map pill, sticky bars).
  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x2E000000),
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
  ];
}
