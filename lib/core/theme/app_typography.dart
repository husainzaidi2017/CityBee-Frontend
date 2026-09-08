import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Centralized type scale extracted from the HTML design reference.
///
/// Two families:
///  • **Outfit** (600/700/800) — headings, section titles, display text.
///  • **HankenGrotesk** (400/600/700) — body, labels, buttons, inputs,
///    navigation labels and supporting text.
///
/// Widgets should compose these styles instead of hand-rolling font
/// families/weights. Framework widgets (buttons, inputs, list tiles…)
/// inherit Hanken Grotesk through [AppTheme].
abstract final class AppTypography {
  static const String displayFamily = 'Outfit';
  static const String bodyFamily = 'HankenGrotesk';

  // ── Outfit: display / headings ──────────────────────────────────────
  static const TextStyle headline = TextStyle(
    fontFamily: displayFamily,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.25,
    letterSpacing: -0.4,
  );

  static const TextStyle title = TextStyle(
    fontFamily: displayFamily,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
    letterSpacing: -0.2,
  );

  static const TextStyle titleSm = TextStyle(
    fontFamily: displayFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
    letterSpacing: -0.1,
  );

  static const TextStyle eyebrow = TextStyle(
    fontFamily: displayFamily,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    height: 1.2,
    letterSpacing: 0.6,
  );

  // ── Hanken Grotesk: body / labels ───────────────────────────────────
  static const TextStyle body = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.45,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.3,
  );
}
