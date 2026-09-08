import '../../../domain/models/business.dart';
import '../../../domain/models/menu_item.dart';
import '../../../domain/models/review.dart';

/// Maps API JSON payloads onto the app's domain models.
///
/// The backend already returns display-ready fields (tagline, imageBadges,
/// featureChips, actionButtons) derived server-side, so the mappers stay
/// thin: null-safety plus enum/string coercions.
abstract final class ApiMappers {
  static BusinessKind _kind(String? raw) => switch (raw) {
        'restaurant' => BusinessKind.restaurant,
        'doctor' => BusinessKind.doctor,
        'hotel' => BusinessKind.hotel,
        'salon' => BusinessKind.salon,
        'mall' => BusinessKind.mall,
        'shop' => BusinessKind.shop,
        _ => BusinessKind.service,
      };

  static String _s(dynamic v, [String fallback = '']) =>
      v == null ? fallback : v.toString();

  static List<String> _strings(dynamic v) =>
      v is List ? v.map((e) => e.toString()).toList() : const <String>[];

  static Business? business(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    final doctor = json['doctor'] as Map<String, dynamic>?;
    final hotel = json['hotel'] as Map<String, dynamic>?;
    return Business(
      id: _s(json['id']),
      uuid: json['uuid'] as String?,
      name: _s(json['name']),
      kind: _kind(json['kind']),
      categoryId: _s(json['categoryIds'] is List && (json['categoryIds'] as List).isNotEmpty
          ? (json['categoryIds'] as List).first
          : ''),
      tagline: _s(json['tagline']),
      description: _s(json['description']),
      images: _strings(json['images']),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
      address: _s(json['address']),
      area: _s(json['area']),
      cityName: _s(json['cityName']),
      distanceMeters: (json['distanceMeters'] as num?)?.toInt(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      phone: _s(json['phone']),
      whatsapp: _s(json['whatsapp']),
      website: json['website'] as String?,
      openingHours: _s(json['openingHours']),
      isOpen: json['isOpen'] as bool? ?? true,
      isVerified: json['isVerified'] as bool? ?? false,
      isPureVeg: json['isPureVeg'] as bool? ?? false,
      imageBadges: _strings(json['imageBadges']),
      featureChips: _strings(json['featureChips']),
      actionButtons: _strings(json['actionButtons']),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      menu: _menu(json['menu']),
      reviews: _reviews(json['reviews']),
      qualification: doctor?['qualification'] as String?,
      experienceYears: (doctor?['experience_years'] as num?)?.toInt(),
      consultationFee: doctor?['consultation_fee'] as String?,
      timings: doctor != null ? _s(doctor['specialization']) : null,
      amenities: _strings(hotel?['amenities']),
      priceText: hotel?['price_range'] as String?,
    );
  }

  static List<MenuItem> _menu(dynamic json) {
    if (json is! List) return const [];
    return json
        .map((e) => e is Map<String, dynamic>
            ? MenuItem(
                name: _s(e['name']),
                description: _s(e['description']),
                price: _s(e['price']),
                image: _s(e['image']),
                isVeg: e['isVeg'] as bool? ?? true,
              )
            : null)
        .whereType<MenuItem>()
        .toList();
  }

  static List<Review> _reviews(dynamic json) {
    if (json is! List) return const [];
    return json
        .map((e) => e is Map<String, dynamic>
            ? Review(
                id: _s(e['id']),
                author: _s(e['author'], 'CityBee user'),
                authorMeta: _s(e['authorMeta'], 'CityBee Explorer'),
                rating: (e['rating'] as num?)?.toDouble() ?? 5,
                text: _s(e['text']),
                timeAgo: _s(e['timeAgo']),
              )
            : null)
        .whereType<Review>()
        .toList();
  }
}
