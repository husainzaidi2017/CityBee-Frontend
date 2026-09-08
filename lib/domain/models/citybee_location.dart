/// The user's selected location — a Google Places choice, NOT a CityBee city.
///
/// This is the single location model used across the app:
/// - [displayName] is what the user picked ("Sirsi") and what the header shows
/// - [latitude]/[longitude] drive all nearby discovery (PostGIS, backend)
/// - everything else is Google-provided context
///
/// Selecting a location never creates a `cities` row; it is persisted
/// locally (guests) and on the user profile (signed in).
class CityBeeLocation {
  const CityBeeLocation({
    required this.displayName,
    required this.latitude,
    required this.longitude,
    this.formattedAddress,
    this.googlePlaceId,
    this.country,
    this.countryCode,
    this.state,
    this.locality,
  });

  final String displayName;
  final String? formattedAddress;
  final String? googlePlaceId;
  final double latitude;
  final double longitude;
  final String? country;
  final String? countryCode;
  final String? state;
  final String? locality;

  /// "Sirsi, Karnataka" — header subtitle style.
  String get subtitle {
    final parts = [locality != null && locality != displayName ? locality : null, state, country]
        .whereType<String>()
        .where((p) => p.isNotEmpty)
        .toSet()
        .toList();
    if (parts.isEmpty) return displayName;
    return parts.join(', ');
  }

  factory CityBeeLocation.fromJson(Map<String, dynamic> json) => CityBeeLocation(
        displayName: (json['displayName'] ?? json['name'] ?? '').toString(),
        formattedAddress: json['formattedAddress'] as String?,
        googlePlaceId: (json['googlePlaceId'] ?? json['placeId']) as String?,
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
        country: json['country'] as String?,
        countryCode: json['countryCode'] as String?,
        state: (json['state'] ?? json['stateRegion']) as String?,
        locality: json['locality'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'formattedAddress': formattedAddress,
        'googlePlaceId': googlePlaceId,
        'latitude': latitude,
        'longitude': longitude,
        'country': country,
        'countryCode': countryCode,
        'state': state,
        'locality': locality,
      };

  /// Payload shape for PATCH /users/me selectedLocation.
  Map<String, dynamic> toProfilePatch() => {
        'name': displayName,
        'latitude': latitude,
        'longitude': longitude,
        if (googlePlaceId != null) 'googlePlaceId': googlePlaceId,
        if (country != null) 'country': country,
        if (countryCode != null) 'countryCode': countryCode,
        if (state != null) 'state': state,
        if (locality != null) 'locality': locality,
      };
}
