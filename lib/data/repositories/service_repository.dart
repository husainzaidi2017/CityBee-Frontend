import '../../domain/models/service_item.dart';
import '../mock/mock_services.dart';

/// Contract for the Services hub. `lat`/`lng` (when available) let the
/// backend resolve the nearest city; `cityId` is a display-name fallback.
abstract class ServiceRepository {
  Future<List<ServiceItem>> getServices(
      {String cityId, double? lat, double? lng});
  Future<List<ServiceItem>> getEventServices(
      {String cityId, double? lat, double? lng});
  Future<ServiceItem> getLegalService({String cityId, double? lat, double? lng});
  Future<List<Helpline>> getHelplines({String cityId});
  Future<int> specialistCount({String cityId, double? lat, double? lng});
}

class MockServiceRepository implements ServiceRepository {
  @override
  Future<List<ServiceItem>> getServices(
      {String cityId = '', double? lat, double? lng}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return mockServices;
  }

  @override
  Future<List<ServiceItem>> getEventServices(
          {String cityId = '', double? lat, double? lng}) async =>
      mockEventServices;

  @override
  Future<ServiceItem> getLegalService(
          {String cityId = '', double? lat, double? lng}) async =>
      mockLegalService;

  @override
  Future<List<Helpline>> getHelplines({String cityId = ''}) async =>
      mockHelplines;

  @override
  Future<int> specialistCount(
          {String cityId = '', double? lat, double? lng}) async =>
      340;
}
