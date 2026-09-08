/// A CityBee city — reference data for places where CityBee has content.
///
/// This is NOT the user's selected location (that is [CityBeeLocation],
/// sourced from Google Places). `cities` rows exist only where CityBee
/// businesses/places are anchored, and are managed by CityBee, never
/// auto-created from a user's Google search.
class City {
  const City({
    required this.id,
    required this.name,
    required this.state,
    required this.nickname,
    required this.defaultArea,
    required this.latitude,
    required this.longitude,
    this.businessCount = 0,
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

  /// Number of businesses listed in this city (from the API).
  final int businessCount;

  /// Whether this city has actual CityBee content — drives the
  /// "Popular on CityBee" section of the location picker.
  bool get hasContent => businessCount > 0;

  String get displayName => '$name, $state';
}
