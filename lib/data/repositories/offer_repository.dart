import '../../domain/models/offer.dart';
import '../mock/mock_offers.dart';

/// Contract for offers/coupons.
abstract class OfferRepository {
  Future<List<Offer>> getOffers({String cityId, String? tag});
  Future<List<Offer>> getNearby({String cityId, int limit});
  Future<Offer?> getById(String id);
  Future<int> countAll({String cityId});
}

class MockOfferRepository implements OfferRepository {
  @override
  Future<List<Offer>> getOffers({String cityId = '', String? tag}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final all = mockOffers;
    if (tag == null || tag == 'All') return all;
    return all.where((o) => o.categoryTag == tag).toList();
  }

  @override
  Future<List<Offer>> getNearby({String cityId = '', int limit = 4}) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return mockOffers.where((o) => !o.featured).take(limit).toList();
  }

  @override
  Future<Offer?> getById(String id) async =>
      mockOffers.where((o) => o.id == id).firstOrNull;

  @override
  Future<int> countAll({String cityId = ''}) async => 86;
}
