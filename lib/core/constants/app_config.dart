/// App-level configuration values.
///
/// URLs live here so they can be swapped per environment (dev/staging/prod)
/// without touching UI code.
abstract final class AppConfig {
  /// User-facing app name.
  static const String appName = 'CityBee';

  /// Public app link appended to shared content.
  static const String appUrl = 'https://citybee.app';

  /// Temporary destination for the "List Your Business" CTA.
  /// Replace with the real CityBee business-registration portal when live.
  static const String businessListingUrl = 'https://www.google.com';

  /// Play Store listing (used by Rate CityBee).
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.localgo';

  /// Support WhatsApp line (CountryCode + number, digits only).
  static const String supportWhatsApp = '919876543210';

  /// Support email.
  static const String supportEmail = 'support@citybee.app';
}
