import '../domain/models/place.dart';
import 'mock/mock_places.dart';

/// Contract for Explore content (places, food, guides, tips).
abstract class PlaceRepository {
  Future<List<Place>> getPlaces({String cityId});
  Future<Place?> getById(String id);
  Future<List<FoodHighlight>> getFoods({String cityId});
  Future<CityGuide> getGuide({String cityId});
  Future<List<ExplorerTip>> getTips({String cityId});
}

class MockPlaceRepository implements PlaceRepository {
  @override
  Future<List<Place>> getPlaces({String cityId = ''}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return mockPlaces;
  }

  @override
  Future<Place?> getById(String id) async =>
      mockPlaces.where((p) => p.id == id).firstOrNull;

  @override
  Future<List<FoodHighlight>> getFoods({String cityId = ''}) async => mockFoods;

  @override
  Future<CityGuide> getGuide({String cityId = ''}) async => mockGuide;

  @override
  Future<List<ExplorerTip>> getTips({String cityId = ''}) async =>
      mockExplorerTips;
}
