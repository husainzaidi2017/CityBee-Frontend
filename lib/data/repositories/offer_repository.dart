import '../../domain/models/offer.dart';
import '../mock/mock_offers.dart';

/// Contract for offers — coordinate-based nearby discovery with backend
/// radius expansion (offers expand 5→10→25→50→100 km like every category).
abstract class OfferRepository {
  Future<List<Offer>> getOffers({String? tag, double? lat, double? lng});
  Future<List<Offer>> getNearby({double? lat, double? lng, int limit = 4});
  Future<Offer?> getById(String id);
  Future<int> countAll({double? lat, double? lng});
}

class MockOfferRepository implements OfferRepository {
  @override
  Future<List<Offer>> getOffers({String? tag, double? lat, double? lng}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final all = mockOffers;
    if (tag == null || tag == 'All') return all;
    return all.where((o) => o.categoryTag == tag).toList();
  }

  @override
  Future<List<Offer>> getNearby({double? lat, double? lng, int limit = 4}) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return mockOffers.where((o) => !o.featured).take(limit).toList();
  }

  @override
  Future<Offer?> getById(String id) async =>
      mockOffers.where((o) => o.id == id).firstOrNull;

  @override
  Future<int> countAll({double? lat, double? lng}) async => 86;
}
