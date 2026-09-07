/// Small formatting helpers shared across screens.
abstract final class Formatters {
  /// 1240 -> "1.2K", 680000 -> "6.8L".
  static String compactCount(int value) {
    if (value >= 100000) return '${(value / 100000).toStringAsFixed(value % 100000 == 0 ? 0 : 1)}L';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}K';
    return value.toString();
  }

  /// 1.8 -> "1.8 km away".
  static String distanceAway(double km) => '${km.toStringAsFixed(1)} km away';
}
