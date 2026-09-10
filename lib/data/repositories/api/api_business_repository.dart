import '../../../core/network/api_client.dart';
import '../../../domain/models/business.dart';
import 'api_mappers.dart';
import '../business_repository.dart';

/// Backend implementation of [BusinessRepository] over the NestJS API.
///
/// Every list call is coordinate-based: the backend expands the search
/// radius per category (5→10→25→50→100 km) until it has enough results,
/// so the Flutter side never implements radius logic.
class ApiBusinessRepository implements BusinessRepository {
  ApiBusinessRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<Business>> getByCategory(String categoryId,
      {double? lat, double? lng}) async {
    final data = await _api.getList('/businesses/nearby', query: {
      'category': categoryId,
      'limit': '50',
      if (lat != null && lng != null) 'lat': lat.toString(),
      if (lat != null && lng != null) 'lng': lng.toString(),
    });
    return _mapList(data?.data);
  }

  @override
  Future<List<Business>> getPopular({
    PopularFilter filter = PopularFilter.all,
    double? lat,
    double? lng,
  }) async {
    // Nearby search without a category → backend returns everything close,
    // sorted by distance; the popular grouping stays a client-side filter.
    final data = await _api.getList('/businesses/nearby', query: {
      'limit': '50',
      if (lat != null && lng != null) 'lat': lat.toString(),
      if (lat != null && lng != null) 'lng': lng.toString(),
    });
    final all = _mapList(data?.data);
    final dining = {'dining', 'restaurants'};
    final shopping = {'fashion', 'heritage', 'heritages', 'malls', 'salons', 'shops', 'grocery'};
    final health = {'doctors', 'hotels'};
    return all.where((b) {
      switch (filter) {
        case PopularFilter.dining:
          return dining.contains(b.categoryId);
        case PopularFilter.shopping:
          return shopping.contains(b.categoryId);
        case PopularFilter.health:
          return health.contains(b.categoryId);
        case PopularFilter.all:
          return true;
      }
    }).toList();
  }

  @override
  Future<Business?> getById(String id, {double? lat, double? lng}) async {
    final data = await _api.get('/businesses/$id', query: {
      if (lat != null && lng != null) 'lat': lat.toString(),
      if (lat != null && lng != null) 'lng': lng.toString(),
    });
    return ApiMappers.business(data);
  }

  @override
  Future<List<Business>> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];
    final data = await _api.getList('/businesses/search', query: {
      'q': q,
      'limit': '30',
    });
    return _mapList(data?.data);
  }

  static List<Business> _mapList(List<dynamic>? rows) =>
      (rows ?? const []).map(ApiMappers.business).whereType<Business>().toList();
}
