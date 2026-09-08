import '../../domain/models/app_category.dart';
import '../../domain/models/city.dart';
import '../../domain/models/citybee_location.dart';
import '../mock/mock_data.dart';

/// A Google Places suggestion from the location search endpoint.
class CitySuggestion {
  const CitySuggestion({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
  });

  final String placeId;
  final String mainText;
  final String secondaryText;
}

/// Contract for location discovery & category lookups.
///
/// Location selection is Google Places–driven and NEVER creates CityBee
/// `cities` rows; [getCities] returns CityBee's own reference cities only.
abstract class CityRepository {
  /// CityBee cities with actual content (reference data, not user state).
  Future<List<City>> getCities();

  Future<List<AppCategory>> getCategories();

  /// Google Places autocomplete for arbitrary worldwide locations (>= 2 chars).
  Future<List<CitySuggestion>> searchCities(String query);

  /// Resolves a Places suggestion to name/coordinates/address.
  /// Pure location data — no city is created server-side.
  Future<CityBeeLocation?> resolveLocation(String placeId);

  /// Reverse geocodes GPS coordinates to a location (for "use my location").
  Future<CityBeeLocation?> reverseGeocode(double latitude, double longitude);
}

class MockCityRepository implements CityRepository {
  @override
  Future<List<City>> getCities() async => mockCities;

  @override
  Future<List<AppCategory>> getCategories() async => mockCategories;

  @override
  Future<List<CitySuggestion>> searchCities(String query) async {
    final q = query.trim().toLowerCase();
    return mockCities
        .where((c) => c.name.toLowerCase().contains(q))
        .map((c) => CitySuggestion(
              placeId: c.id,
              mainText: c.name,
              secondaryText: c.state,
            ))
        .toList();
  }

  @override
  Future<CityBeeLocation?> resolveLocation(String placeId) async {
    final city = mockCities.where((c) => c.id == placeId).firstOrNull;
    return city == null
        ? null
        : CityBeeLocation(
            displayName: city.name,
            latitude: city.latitude,
            longitude: city.longitude,
            state: city.state,
            locality: city.name,
          );
  }

  @override
  Future<CityBeeLocation?> reverseGeocode(double latitude, double longitude) async =>
      CityBeeLocation(
        displayName: mockCities.first.name,
        latitude: latitude,
        longitude: longitude,
        state: mockCities.first.state,
      );
}
