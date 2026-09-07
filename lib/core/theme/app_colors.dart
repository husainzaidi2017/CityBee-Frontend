import 'package:flutter/material.dart';

/// Centralized LocalGo color palette extracted from the design screenshots.
///
/// Do not hard-code colors in widgets — always reference [AppColors] so the
/// brand can be adjusted from a single place.
abstract final class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────────
  /// Deep brand green — primary buttons, active nav tab, verified accents.
  static const Color primary = Color(0xFF0E6B4F);
  static const Color primaryDark = Color(0xFF0A5744);
  static const Color primaryDeep = Color(0xFF0B3B2E);
  static const Color primarySoft = Color(0xFFE7F4EE);

  /// Orange-red brand accent — "Go" wordmark, offer badges, CTA highlights.
  static const Color accent = Color(0xFFF4691F);
  static const Color accentSoft = Color(0xFFFFF1E6);
  static const Color brandRed = Color(0xFFE23A2E);

  // ── Surfaces ───────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF5F6F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFFAFBFA);
  static const Color border = Color(0xFFE9EDE9);
  static const Color divider = Color(0xFFEFF1EF);

  // ── Text ───────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF17211B);
  static const Color textSecondary = Color(0xFF79827D);
  static const Color textMuted = Color(0xFF9AA39E);

  // ── Chips / badges ─────────────────────────────────────────────────────
  /// Near-black selected filter chip background.
  static const Color chipDark = Color(0xFF1C1C1C);
  static const Color chipDarkText = Color(0xFFEDEDED);

  static const Color ratingGreen = Color(0xFF0E7A5F);
  static const Color ratingGreenSoft = Color(0xFFE7F3EE);
  static const Color starAmber = Color(0xFFF5A623);
  static const Color verifiedGreen = Color(0xFF1B7A4A);

  /// "POPULAR" / urgent badge red.
  static const Color badgeRed = Color(0xFFE23A2E);
  /// "FLAT x% OFF" badge orange.
  static const Color badgeOrange = Color(0xFFF4711F);

  static const Color openGreen = Color(0xFF15803D);
  static const Color openGreenSoft = Color(0xFFE8F6EC);

  // ── Category tile tints (Explore Near You grid) ────────────────────────
  static const Color catFashion = Color(0xFF8033D6);
  static const Color catFashionSoft = Color(0xFFF2E7FD);
  static const Color catGrocery = Color(0xFF0F8A46);
  static const Color catGrocerySoft = Color(0xFFE4F4E9);
  static const Color catFood = Color(0xFFF4691F);
  static const Color catFoodSoft = Color(0xFFFFF0E4);
  static const Color catDoctor = Color(0xFF2563EB);
  static const Color catDoctorSoft = Color(0xFFE7EEFD);
  static const Color catHotel = Color(0xFF0D9488);
  static const Color catHotelSoft = Color(0xFFE3F5F3);
  static const Color catBarber = Color(0xFF9333EA);
  static const Color catBarberSoft = Color(0xFFF4E9FD);
  static const Color catHeritage = Color(0xFFB45309);
  static const Color catHeritageSoft = Color(0xFFFCF0DF);
  static const Color catSalon = Color(0xFFDB2777);
  static const Color catSalonSoft = Color(0xFFFDE9F2);

  // ── Banners ────────────────────────────────────────────────────────────
  /// Green gradient used by hero banners on Home / Services.
  static const Color bannerGreenTop = Color(0xFF0F6E4E);
  static const Color bannerGreenBottom = Color(0xFF0B4A36);

  /// Cream savings footer banner on the Offers screen.
  static const Color creamBanner = Color(0xFFFFF8E7);
  static const Color creamBannerText = Color(0xFF8A6D1A);

  /// Map preview canvas tone.
  static const Color mapCanvas = Color(0xFFEDF1EC);
  static const Color mapRoad = Color(0xFFFFFFFF);
  static const Color mapRoadMinor = Color(0xFFF8FAF8);
}
