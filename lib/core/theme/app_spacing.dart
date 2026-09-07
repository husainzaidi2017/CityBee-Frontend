/// Centralized spacing scale. Use these instead of raw `SizedBox` values so
/// layouts stay consistent across screens and densities.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Standard horizontal page padding.
  static const double screenH = 16;

  /// Vertical gap between major home/list sections.
  static const double section = 24;
}
