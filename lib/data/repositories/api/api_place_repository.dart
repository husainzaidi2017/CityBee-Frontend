import '../../../core/network/api_client.dart';
import '../../../domain/models/place.dart';
import '../place_repository.dart';
import '../../mock/mock_places.dart' show mockFoods, mockGuide, mockExplorerTips;

/// Backend implementation of the Explore content contract.
///
/// Places come from the nearby API (backend radius expansion); food
/// highlights, the city guide and explorer tips are editorial content
/// (hand-written, city-flavoured) and stay local until a CMS exists.
class ApiPlaceRepository implements PlaceRepository {
  ApiPlaceRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<Place>> getPlaces({double? lat, double? lng}) async {
    final data = await _api.getList('/places/nearby', query: {
      'limit': '30',
      if (lat != null && lng != null) 'lat': lat.toString(),
      if (lat != null && lng != null) 'lng': lng.toString(),
    });
    return _mapList(data?.data);
  }

  @override
  Future<Place?> getById(String id) async {
    final data = await _api.get('/places/$id');
    return data is Map<String, dynamic> ? _place(data) : null;
  }

  @override
  Future<List<FoodHighlight>> getFoods() async => mockFoods;

  @override
  Future<CityGuide> getGuide() async => mockGuide;

  @override
  Future<List<ExplorerTip>> getTips() async => mockExplorerTips;

  static List<Place> _mapList(List<dynamic>? rows) =>
      (rows ?? const []).map((e) => e is Map<String, dynamic> ? _place(e) : null)
          .whereType<Place>()
          .toList();

  static Place _place(Map<String, dynamic> json) => Place(
        id: json['id']?.toString() ?? '',
        uuid: json['uuid']?.toString(),
        name: json['name']?.toString() ?? '',
        image: json['image']?.toString() ?? '',
        metaLine: json['metaLine']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        ratingText: json['ratingText']?.toString() ?? '',
        tags: json['tags'] is List
            ? (json['tags'] as List).map((e) => e.toString()).toList()
            : const [],
        address: json['address']?.toString() ?? '',
        cityName: json['cityName']?.toString() ?? '',
        timings: json['timings']?.toString() ?? '',
        entryFee: json['entryFee']?.toString() ?? '',
      );
}
