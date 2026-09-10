import '../../../core/network/api_client.dart';
import '../../../domain/models/service_item.dart';
import '../service_repository.dart';

/// Backend implementation of the Services hub.
///
/// All experts (electricians, plumbers, carpenters, painters, …) come from
/// GET /services — city-resolved on the server from the caller's
/// coordinates. Occasions (pandit/mehndi) and legal aid are the same table
/// filtered by category. Helplines stay local: they are national civic
/// numbers (108/112/1912), not database content.
class ApiServiceServiceRepository implements ServiceRepository {
  ApiServiceServiceRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<ServiceItem>> getServices(
      {String cityId = '', double? lat, double? lng}) async {
    final all = await _fetchAll(lat: lat, lng: lng, city: cityId);
    // The trade grid shows everything EXCEPT occasions/legal, which have
    // their own sections on the Services screen.
    return all
        .where((s) => s.category != 'occasions' && s.category != 'legal')
        .toList();
  }

  @override
  Future<List<ServiceItem>> getEventServices(
      {String cityId = '', double? lat, double? lng}) async {
    final all = await _fetchAll(lat: lat, lng: lng, city: cityId);
    return all.where((s) => s.category == 'occasions').toList();
  }

  @override
  Future<ServiceItem> getLegalService(
      {String cityId = '', double? lat, double? lng}) async {
    final all = await _fetchAll(lat: lat, lng: lng, city: cityId);
    return all.firstWhere(
      (s) => s.category == 'legal',
      orElse: () => const ServiceItem(
        id: 'legal-unavailable',
        name: 'Legal & Documentation',
        badge: '',
        rating: '4.5',
        servicesSummary: 'Notary & documentation services',
        priceText: '',
        etaText: '',
        statsText: '',
        trustNote: '',
        image: '',
        actionLabel: 'Inquire',
        phone: '',
      ),
    );
  }

  @override
  Future<List<Helpline>> getHelplines({String cityId = ''}) async =>
      const [
        Helpline(label: '108 Ambulance', number: '108', colorValue: 0xFFE23A2E),
        Helpline(label: '112 Police', number: '112', colorValue: 0xFF2563EB),
        Helpline(label: '1912 Bijli Board', number: '1912', colorValue: 0xFFF4711F),
        Helpline(label: 'Nagar Nigam', number: '155213', colorValue: 0xFF0E6B4F),
        Helpline(label: '24x7 Pharmacy', number: '1800180152', colorValue: 0xFF0D9488),
      ];

  @override
  Future<int> specialistCount(
      {String cityId = '', double? lat, double? lng}) async {
    final services = await getServices(cityId: cityId, lat: lat, lng: lng);
    return services.length;
  }

  Future<List<ServiceItem>> _fetchAll(
      {double? lat, double? lng, String? city}) async {
    final data = await _api.get('/services', query: {
      if (lat != null && lng != null) 'lat': lat.toString(),
      if (lat != null && lng != null) 'lng': lng.toString(),
      if (city != null && city.isNotEmpty) 'city': city,
    });
    if (data is! List) return const [];
    return data
        .map((e) => e is Map<String, dynamic> ? _service(e) : null)
        .whereType<ServiceItem>()
        .toList();
  }

  static ServiceItem _service(Map<String, dynamic> json) => ServiceItem(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        badge: json['badge']?.toString() ?? '',
        rating: json['rating']?.toString() ?? '4.5',
        servicesSummary: json['servicesSummary']?.toString() ?? '',
        priceText: json['priceText']?.toString() ?? '',
        etaText: json['etaText']?.toString() ?? '',
        statsText: json['statsText']?.toString() ?? '',
        trustNote: json['trustNote']?.toString() ?? '',
        image: json['image']?.toString() ?? '',
        actionLabel: json['actionLabel']?.toString() ?? 'Call Now',
        phone: json['phone']?.toString() ?? '',
        category: json['category']?.toString(),
        citySpecialty: json['citySpecialty'] as bool? ?? false,
      );
}
