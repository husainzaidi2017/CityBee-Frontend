import '../../../core/network/api_client.dart';
import '../../../domain/models/app_category.dart';
import '../../../domain/models/city.dart';
import '../../../domain/models/citybee_location.dart';
import '../city_repository.dart';

/// Backend implementation of location discovery & category lookups.
class ApiCityRepository implements CityRepository {
  ApiCityRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<City>> getCities() async {
    final data = await _api.get('/cities');
    if (data is! List) return const [];
    return data
        .map((e) => e is Map<String, dynamic> ? _city(e) : null)
        .whereType<City>()
        .toList();
  }

  @override
  Future<List<AppCategory>> getCategories() async {
    final data = await _api.get('/categories');
    if (data is! List) return const [];
    return data
        .map((e) => e is Map<String, dynamic> ? _category(e) : null)
        .whereType<AppCategory>()
        .toList();
  }

  @override
  Future<List<CitySuggestion>> searchCities(String query) async {
    final q = query.trim();
    if (q.length < 2) return const [];
    final data = await _api.getList('/location/search', query: {'q': q});
    if (data == null) return const [];
    return data.data
        .map((e) => e is Map<String, dynamic>
            ? CitySuggestion(
                placeId: e['placeId']?.toString() ?? '',
                mainText: e['mainText']?.toString() ?? '',
                secondaryText: e['secondaryText']?.toString() ?? '',
              )
            : null)
        .whereType<CitySuggestion>()
        .toList();
  }

  @override
  Future<CityBeeLocation?> resolveLocation(String placeId) async {
    final data = await _api.get('/location/resolve', query: {'placeId': placeId});
    return data is Map<String, dynamic> ? CityBeeLocation.fromJson(data) : null;
  }

  @override
  Future<CityBeeLocation?> reverseGeocode(double latitude, double longitude) async {
    final data = await _api.get('/location/reverse', query: {
      'lat': latitude.toString(),
      'lng': longitude.toString(),
    });
    return data is Map<String, dynamic> ? CityBeeLocation.fromJson(data) : null;
  }

  static City _city(Map<String, dynamic> json) => City(
        id: json['slug']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        state: json['state_region']?.toString() ?? '',
        nickname: json['nickname']?.toString() ?? '',
        defaultArea: json['default_area']?.toString() ?? '',
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
        businessCount: (json['business_count'] as num?)?.toInt() ?? 0,
      );

  static AppCategory _category(Map<String, dynamic> json) => AppCategory(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        // Listing titles keep the mock pattern ("Restaurants & Dining in …");
        // derived from the category name when the backend doesn't send one.
        listingTitle:
            json['listingTitle']?.toString() ?? json['name']?.toString() ?? '',
      );
}
