import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Brand SVG icons (assets/icons/) for actions and navigation — one
/// consistent custom style across the app, replacing ad-hoc Material icons.
abstract final class AppIcons {
  // ── Detail-page actions ──────────────────────────────────────────────
  static const String callAsset = 'assets/icons/call.svg';
  static const String whatsappAsset = 'assets/icons/whatsapp.svg';
  static const String directionsAsset = 'assets/icons/directions.svg';

  // ── Bottom navigation ────────────────────────────────────────────────
  static const String home = 'assets/icons/home.svg';
  static const String homeOutline = 'assets/icons/home_outline.svg';
  static const String offers = 'assets/icons/offers.svg';
  static const String offersOutline = 'assets/icons/offers_outline.svg';
  static const String services = 'assets/icons/services.svg';
  static const String servicesOutline = 'assets/icons/services_outline.svg';
  static const String explore = 'assets/icons/explore.svg';
  static const String exploreOutline = 'assets/icons/explore_outline.svg';
  static const String business = 'assets/icons/business.svg';
  static const String businessOutline = 'assets/icons/business_outline.svg';
  static const String more = 'assets/icons/more.svg';
  static const String moreOutline = 'assets/icons/more_outline.svg';

  /// Nav icon: SVG assets are pre-colored (orange active / slate inactive).
  static Widget nav(String asset, {double size = 23, Key? key}) =>
      SvgPicture.asset(asset, width: size, height: size, key: key);

  /// Renders one of the action icons at [size].
  static Widget action(String asset, {double size = 20}) =>
      SvgPicture.asset(asset, width: size, height: size);

}
