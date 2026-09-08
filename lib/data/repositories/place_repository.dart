import '../../domain/models/place.dart';
import '../mock/mock_places.dart';

/// Contract for Explore content (places, food, guides, tips).
///
/// Places use coordinate-based nearby discovery; food/guide/tips stay
/// editorial content (local) until a CMS exists.
abstract class PlaceRepository {
  Future<List<Place>> getPlaces({double? lat, double? lng});
  Future<Place?> getById(String id);
  Future<List<FoodHighlight>> getFoods();
  Future<CityGuide> getGuide();
  Future<List<ExplorerTip>> getTips();
}

class MockPlaceRepository implements PlaceRepository {
  @override
  Future<List<Place>> getPlaces({double? lat, double? lng}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return mockPlaces;
  }

  @override
  Future<Place?> getById(String id) async =>
      mockPlaces.where((p) => p.id == id).firstOrNull;

  @override
  Future<List<FoodHighlight>> getFoods() async => mockFoods;

  @override
  Future<CityGuide> getGuide() async => mockGuide;

  @override
  Future<List<ExplorerTip>> getTips() async => mockExplorerTips;
}
