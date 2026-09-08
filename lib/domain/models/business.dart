import 'menu_item.dart';
import 'review.dart';

/// The kind of local business. Drives category-specific detail sections
/// (e.g. consultation fee for doctors, amenities for hotels) while all
/// businesses share the same base model and screens.
enum BusinessKind { restaurant, doctor, hotel, salon, shop, mall, service }

/// A local business: shop, restaurant, clinic, hotel, salon, …
///
/// This is the common entity every listing/detail screen renders. Category
/// specific extras live in the optional fields so doctors/hotels/restaurants
/// reuse the same architecture (per the business-system requirement).
class Business {
  const Business({
    required this.id,
    required this.name,
    required this.kind,
    required this.categoryId,
    required this.tagline,
    required this.description,
    required this.images,
    required this.rating,
    required this.ratingCount,
    required this.address,
    required this.area,
    this.cityName = '',
    required this.distanceKm,
    required this.phone,
    required this.whatsapp,
    this.website,
    required this.openingHours,
    required this.isOpen,
    required this.isVerified,
    required this.isPureVeg,
    required this.imageBadges,
    required this.featureChips,
    required this.actionButtons,
    required this.latitude,
    required this.longitude,
    this.distanceMeters,
    this.menu = const [],
    this.reviews = const [],
    this.couponCode,
    this.couponTitle,
    this.couponSubtitle,
    this.couponNote,
    // Doctor specifics
    this.qualification,
    this.experienceYears,
    this.consultationFee,
    this.timings,
    // Hotel specifics
    this.amenities = const [],
    // Display-only price summary, e.g. "₹1,400–₹2,800 / night".
    this.priceText,
    // Backend database id (null for purely local/mock entries). Public id
    // [id] is the stable slug used by routes and favorites.
    this.uuid,
  });

  final String id;
  final String? uuid;
  final String name;
  final BusinessKind kind;
  final String categoryId;

  /// Short line under the name — cuisines, specialization, services.
  final String tagline;
  final String description;
  final List<String> images;
  final double rating;
  final int ratingCount;
  final String address;
  final String area;

  /// Actual CityBee city of the business (e.g. "Hubli") — distinct from the
  /// user's selected location; displayed with distance for honesty.
  final String cityName;

  /// Distance in meters from the selected location (backend-computed).
  final int? distanceMeters;

  /// Distance from the user's selected location, in kilometres.
  final double distanceKm;
  final String phone;
  final String whatsapp;
  final String? website;
  final String openingHours;
  final bool isOpen;
  final bool isVerified;
  final bool isPureVeg;

  /// Badges rendered over the card image (e.g. "POPULAR", "FLAT 15% OFF").
  final List<String> imageBadges;

  /// Small chips under the title (e.g. "Banquet", "Pure Veg").
  final List<String> featureChips;

  /// Row action labels, e.g. ["Call", "Route", "Menu"] or
  /// ["Call", "Route", "Book Visit"].
  final List<String> actionButtons;

  final double latitude;
  final double longitude;
  final List<MenuItem> menu;
  final List<Review> reviews;

  // ── LocalGo deal banner on the detail page ────────────────────────────
  final String? couponCode;
  final String? couponTitle;
  final String? couponSubtitle;
  final String? couponNote;

  // ── Doctor specifics ──────────────────────────────────────────────────
  final String? qualification;
  final int? experienceYears;
  final String? consultationFee;
  final String? timings;

  // ── Hotel specifics ───────────────────────────────────────────────────
  final List<String> amenities;
  final String? priceText;

  String get ratingLabel => rating.toStringAsFixed(1);
  String get ratingCountLabel => _compact(ratingCount);
  String get distanceLabel => distanceKm.toStringAsFixed(1);

  bool get hasCoupon => couponCode != null && couponCode!.isNotEmpty;

  static String _compact(int value) {
    if (value >= 100000) return '${(value / 100000).toStringAsFixed(1)}L';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toString();
  }
}
