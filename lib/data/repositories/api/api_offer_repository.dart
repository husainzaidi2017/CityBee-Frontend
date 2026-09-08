import '../../../core/network/api_client.dart';
import '../../../domain/models/offer.dart';
import '../offer_repository.dart';

/// Backend implementation of the offers contract (coordinate-based).
class ApiOfferRepository implements OfferRepository {
  ApiOfferRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<Offer>> getOffers({String? tag, double? lat, double? lng}) async {
    final data = await _api.getList('/offers/nearby', query: {
      'limit': '50',
      if (lat != null && lng != null) 'lat': lat.toString(),
      if (lat != null && lng != null) 'lng': lng.toString(),
    });
    final all = _mapList(data?.data);
    if (tag == null || tag == 'All') return all;
    return all.where((o) => o.categoryTag == tag).toList();
  }

  @override
  Future<List<Offer>> getNearby({double? lat, double? lng, int limit = 4}) async {
    final data = await _api.getList('/offers/nearby', query: {
      'limit': '$limit',
      if (lat != null && lng != null) 'lat': lat.toString(),
      if (lat != null && lng != null) 'lng': lng.toString(),
    });
    return _mapList(data?.data).take(limit).toList();
  }

  @override
  Future<Offer?> getById(String id) async {
    final data = await _api.get('/offers/$id');
    return data is Map<String, dynamic> ? _offer(data) : null;
  }

  @override
  Future<int> countAll({double? lat, double? lng}) async {
    final data = await _api.get('/offers/count', query: {
      if (lat != null && lng != null) 'lat': lat.toString(),
      if (lat != null && lng != null) 'lng': lng.toString(),
    });
    return data is int ? data : (data as num?)?.toInt() ?? 0;
  }

  static List<Offer> _mapList(List<dynamic>? rows) =>
      (rows ?? const []).map((e) => e is Map<String, dynamic> ? _offer(e) : null)
          .whereType<Offer>()
          .toList();

  static Offer _offer(Map<String, dynamic> json) => Offer(
        id: json['id']?.toString() ?? '',
        uuid: json['id']?.toString(),
        businessId: json['businessId']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        badgeText: json['badgeText']?.toString() ?? '',
        subtitle: json['subtitle']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        couponCode: json['couponCode']?.toString() ?? '',
        validityText: json['validityText']?.toString() ?? '',
        image: json['image']?.toString() ?? '',
        categoryTag: json['categoryTag']?.toString() ?? 'All',
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        area: json['area']?.toString() ?? '',
        cityName: json['cityName']?.toString() ?? '',
        distanceText: json['distanceText']?.toString() ?? '',
        remainingText: json['remainingText'] as String?,
        leftCount: (json['leftCount'] as num?)?.toInt(),
        featured: json['featured'] as bool? ?? false,
      );
}
