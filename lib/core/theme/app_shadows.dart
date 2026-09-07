import 'package:flutter/material.dart';

/// Soft, layered card shadows used across the design.
abstract final class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x14120F0A),
      blurRadius: 18,
      offset: Offset(0, 5),
    ),
  ];

  static const List<BoxShadow> cardStrong = [
    BoxShadow(
      color: Color(0x24120F0A),
      blurRadius: 26,
      offset: Offset(0, 8),
    ),
  ];

  /// Shadow for floating elements (map pill, sticky bars).
  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x33120F0A),
      blurRadius: 30,
      offset: Offset(0, 10),
    ),
  ];
}
