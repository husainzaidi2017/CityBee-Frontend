/// A city that LocalGo operates in. The app is city-aware: every listing,
/// offer and place is scoped to the selected [City].
///
/// New cities can be added in the data layer without UI changes.
class City {
  const City({
    required this.id,
    required this.name,
    required this.state,
    required this.nickname,
    required this.defaultArea,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String name;

  /// e.g. "Uttar Pradesh".
  final String state;

  /// Marketing nickname, e.g. "Peetal Nagri" for Moradabad.
  final String nickname;

  /// Area shown under the city name in the location header.
  final String defaultArea;

  final double latitude;
  final double longitude;

  String get displayName => '$name, $state';
}
