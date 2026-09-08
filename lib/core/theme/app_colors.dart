import 'package:flutter/material.dart';

/// Centralized CityBee color palette.
///
/// The brand is anchored on the official logo orange (#FF6F00) with clean
/// neutral surfaces and dark ink typography. Green appears only where it is
/// semantically meaningful (verified, success, open-now, food) — it is never
/// the app theme.
abstract final class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────────
  /// CityBee orange — primary CTAs, selected states, active navigation,
  /// highlights, badges and brand accents (from the official logo).
  static const Color primary = Color(0xFFFF6F00);
  static const Color primaryDark = Color(0xFFE65100);
  static const Color primaryDeep = Color(0xFFBF360C);
  static const Color primarySoft = Color(0xFFFFF3E0);

  /// Orange-red secondary accent — legacy action highlights, offer badges.
  static const Color accent = Color(0xFFF4691F);
  static const Color accentSoft = Color(0xFFFFF1E6);
  static const Color brandRed = Color(0xFFE23A2E);

  /// Official CityBee logo colors (from the brand SVG):
  /// mark + "City" wordmark orange, "Bee" wordmark ink.
  static const Color brandOrange = Color(0xFFFF6F00);
  static const Color brandInk = Color(0xFF1E293B);

  // ── Surfaces ───────────────────────────────────────────────────────────
  /// Very light neutral background.
  static const Color background = Color(0xFFFAFAF8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFFDFDFC);
  static const Color border = Color(0xFFECECE8);
  static const Color divider = Color(0xFFF1F1ED);

  // ── Text (ink) ─────────────────────────────────────────────────────────
  /// Dark ink for primary text — matches the "Bee" wordmark color.
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // ── Chips / badges ─────────────────────────────────────────────────────
  /// Near-black selected filter chip background.
  static const Color chipDark = Color(0xFF1E293B);
  static const Color chipDarkText = Color(0xFFF8FAFC);

  /// Rating pill — orange brand tone (matches the new identity).
  static const Color rating = Color(0xFFFF6F00);
  static const Color ratingSoft = Color(0xFFFFF3E0);
  /// Semantic green: verified listings only.
  static const Color verifiedGreen = Color(0xFF16A34A);
  static const Color verifiedGreenSoft = Color(0xFFE7F6EC);
  static const Color starAmber = Color(0xFFF5A623);

  /// "POPULAR" / urgent badge red.
  static const Color badgeRed = Color(0xFFE23A2E);
  /// "FLAT x% OFF" badge orange.
  static const Color badgeOrange = Color(0xFFFF6F00);

  /// Semantic green: open-now status.
  static const Color openGreen = Color(0xFF16A34A);
  static const Color openGreenSoft = Color(0xFFE7F6EC);

  // ── Category tile tints (Explore Near You grid) ────────────────────────
  /// Tinted neutrals keep the grid calm; category identity comes from the
  /// icon color, so no single hue dominates the Home screen.
  static const Color catFashion = Color(0xFF7C3AED);
  static const Color catFashionSoft = Color(0xFFF3EEFC);
  static const Color catGrocery = Color(0xFF0891B2);
  static const Color catGrocerySoft = Color(0xFFE8F4F8);
  static const Color catFood = Color(0xFFFF6F00);
  static const Color catFoodSoft = Color(0xFFFFF3E0);
  static const Color catDoctor = Color(0xFF2563EB);
  static const Color catDoctorSoft = Color(0xFFE8EEFB);
  static const Color catHotel = Color(0xFF0D9488);
  static const Color catHotelSoft = Color(0xFFE4F4F1);
  static const Color catBarber = Color(0xFF9333EA);
  static const Color catBarberSoft = Color(0xFFF3EAFB);
  static const Color catHeritage = Color(0xFFB45309);
  static const Color catHeritageSoft = Color(0xFFFBF1E3);
  static const Color catSalon = Color(0xFFDB2777);
  static const Color catSalonSoft = Color(0xFFFDE9F2);

  // ── Banners ────────────────────────────────────────────────────────────
  /// Orange gradient for hero banners (replaces the old green).
  static const Color bannerOrangeTop = Color(0xFFFF8F2B);
  static const Color bannerOrangeBottom = Color(0xFFE65100);

  /// Cream savings footer banner on the Offers screen.
  static const Color creamBanner = Color(0xFFFFF8E7);
  static const Color creamBannerText = Color(0xFF8A6D1A);

  /// Map preview canvas tone.
  static const Color mapCanvas = Color(0xFFEDF1EC);
  static const Color mapRoad = Color(0xFFFFFFFF);
  static const Color mapRoadMinor = Color(0xFFF8FAF8);
}
