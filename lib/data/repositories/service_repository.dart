import '../domain/models/service_item.dart';
import 'mock/mock_services.dart';

/// Contract for the Services hub.
abstract class ServiceRepository {
  Future<List<ServiceItem>> getServices({String cityId});
  Future<List<ServiceItem>> getEventServices({String cityId});
  Future<ServiceItem> getLegalService({String cityId});
  Future<List<Helpline>> getHelplines({String cityId});
  Future<int> specialistCount({String cityId});
}

class MockServiceRepository implements ServiceRepository {
  @override
  Future<List<ServiceItem>> getServices({String cityId = ''}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return mockServices;
  }

  @override
  Future<List<ServiceItem>> getEventServices({String cityId = ''}) async =>
      mockEventServices;

  @override
  Future<ServiceItem> getLegalService({String cityId = ''}) async =>
      mockLegalService;

  @override
  Future<List<Helpline>> getHelplines({String cityId = ''}) async =>
      mockHelplines;

  @override
  Future<int> specialistCount({String cityId = ''}) async => 340;
}
