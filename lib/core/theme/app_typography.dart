import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Centralized type scale — mobile-first sizes with real weight hierarchy.
///
/// Two families:
///  • **Outfit** (600/700/800) — headings, section titles, display text.
///  • **HankenGrotesk** (400/600/700) — body, labels, buttons, inputs,
///    navigation labels and supporting text.
///
/// The scale is intentionally compact: page title → section title → card
/// title → body → metadata. Body text is 14px/regular so content reads at
/// arm's length; bold is reserved for emphasis, not applied to everything.
abstract final class AppTypography {
  static const String displayFamily = 'Outfit';
  static const String bodyFamily = 'HankenGrotesk';

  // ── Outfit: display / headings ──────────────────────────────────────
  /// Page title (tab pages and pushed pages).
  static const TextStyle headline = TextStyle(
    fontFamily: displayFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.22,
    letterSpacing: -0.4,
  );

  /// Card/section heading on detail screens.
  static const TextStyle title = TextStyle(
    fontFamily: displayFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
    letterSpacing: -0.2,
  );

  /// Sub-section heading and card titles.
  static const TextStyle titleSm = TextStyle(
    fontFamily: displayFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
    letterSpacing: -0.1,
  );

  static const TextStyle eyebrow = TextStyle(
    fontFamily: displayFamily,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    height: 1.2,
    letterSpacing: 0.6,
  );

  // ── Hanken Grotesk: body / labels ───────────────────────────────────
  /// Primary reading text — regular weight by default.
  static const TextStyle body = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.45,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  /// Secondary text — descriptions, subtitles.
  static const TextStyle caption = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  /// Metadata — smallest comfortable size on a phone.
  static const TextStyle label = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 11.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.3,
  );
}
