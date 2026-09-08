import '../../domain/models/app_category.dart';
import '../../domain/models/city.dart';
import '../mock/mock_data.dart';

/// Contract for city & category lookups.
///
/// The UI depends only on this interface; a Supabase-backed implementation
/// replaces [MockCityRepository] when the backend is connected.
abstract class CityRepository {
  Future<List<City>> getCities();
  Future<List<AppCategory>> getCategories();
}

class MockCityRepository implements CityRepository {
  @override
  Future<List<City>> getCities() async => mockCities;

  @override
  Future<List<AppCategory>> getCategories() async => mockCategories;
}
