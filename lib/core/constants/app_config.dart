/// App-level configuration values.
///
/// URLs live here so they can be swapped per environment (dev/staging/prod)
/// without touching UI code. Override at build time with
/// `flutter run --dart-define=API_BASE_URL=https://...`.
abstract final class AppConfig {
  /// User-facing app name.
  static const String appName = 'CityBee';

  /// Public app link appended to shared content.
  static const String appUrl = 'https://citybee.app';

  /// NestJS backend base URL (no trailing slash).
  ///
  /// - dev default serves the local API (Chrome/web)
  /// - Android emulator should use http://10.0.2.2:3000/api
  /// - production uses the deployed API domain
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );

  /// Supabase project URL. Public by design (anon key is a publishable key;
  /// all write operations flow through the NestJS API, never direct).
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://uqjhuiylvfafuqehuzwm.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVxamh1aXlsdmZhZnVxZWh1endtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg4NzI2MTQsImV4cCI6MjEwNDQ0ODYxNH0.8--m2hX4EZNc144QI0bD0tHKwm6g0XgSctqILAAxMGA',
  );

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
