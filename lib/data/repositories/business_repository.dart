import '../domain/models/business.dart';
import '../domain/models/menu_item.dart';
import 'mock/mock_businesses.dart';

/// How "Popular Near You" cards are grouped on the Home screen.
enum PopularFilter { all, dining, shopping, health }

/// Contract for business discovery. PostGIS radius queries will implement
/// the same interface on Supabase (e.g. businesses within N km of the user).
abstract class BusinessRepository {
  Future<List<Business>> getByCategory(String categoryId, {String cityId});
  Future<List<Business>> getPopular({String cityId, PopularFilter filter});
  Future<Business?> getById(String id);
  Future<List<Business>> search(String query, {String cityId});
}

class MockBusinessRepository implements BusinessRepository {
  @override
  Future<List<Business>> getByCategory(String categoryId, {String cityId = ''}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return mockBusinesses.where((b) => b.categoryId == categoryId).toList();
  }

  @override
  Future<List<Business>> getPopular({
    String cityId = '',
    PopularFilter filter = PopularFilter.all,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final dining = {'dining', 'grocery'};
    final shopping = {'fashion', 'heritage', 'malls', 'salons'};
    final health = {'doctors', 'hotels'};
    return mockBusinesses.where((b) {
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
  Future<Business?> getById(String id) async =>
      mockBusinesses.where((b) => b.id == id).firstOrNull;

  @override
  Future<List<Business>> search(String query, {String cityId = ''}) async {
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
