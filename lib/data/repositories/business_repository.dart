import '../../domain/models/business.dart';
import '../../domain/models/menu_item.dart';
import '../mock/mock_businesses.dart';

/// How "Popular Near You" cards are grouped on the Home screen.
enum PopularFilter { all, dining, shopping, health }

/// Contract for business discovery.
///
/// All list queries are coordinate-based: the backend runs PostGIS nearby
/// searches with per-category progressive radius expansion. There is no
/// city-name matching anywhere in the flow.
abstract class BusinessRepository {
  Future<List<Business>> getByCategory(String categoryId, {double? lat, double? lng});
  Future<List<Business>> getPopular({PopularFilter filter, double? lat, double? lng});
  Future<Business?> getById(String id, {double? lat, double? lng});
  Future<List<Business>> search(String query);
}

class MockBusinessRepository implements BusinessRepository {
  @override
  Future<List<Business>> getByCategory(String categoryId,
      {double? lat, double? lng}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return mockBusinesses.where((b) => b.categoryId == categoryId).toList();
  }

  @override
  Future<List<Business>> getPopular({
    PopularFilter filter = PopularFilter.all,
    double? lat,
    double? lng,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _filterPopular(mockBusinesses, filter);
  }

  static List<Business> _filterPopular(List<Business> all, PopularFilter filter) {
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
  Future<Business?> getById(String id, {double? lat, double? lng}) async =>
      mockBusinesses.where((b) => b.id == id).firstOrNull;

  @override
  Future<List<Business>> search(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return mockBusinesses
        .where((b) =>
            b.name.toLowerCase().contains(q) ||
            b.tagline.toLowerCase().contains(q) ||
            b.area.toLowerCase().contains(q))
        .toList();
  }

  /// Menu items for a business (kept beside the repository so the detail
  /// screen never queries mock lists directly).
  Future<List<MenuItem>> getMenu(String businessId) async =>
      mockBusinesses
          .where((b) => b.id == businessId)
          .map((b) => b.menu)
          .firstOrNull ??
      const [];
}
