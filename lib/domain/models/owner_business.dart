// Business-owner management models (My Business tab).
// Mirrors the backend /me/businesses API 1:1. All records come from the
// database — nothing here is hardcoded.

/// Lightweight owner status used to decide the bottom navigation.
class OwnerBusinessSummary {
  const OwnerBusinessSummary({
    required this.hasApprovedBusiness,
    required this.approvedBusinessCount,
    required this.totalBusinessCount,
  });

  final bool hasApprovedBusiness;
  final int approvedBusinessCount;
  final int totalBusinessCount;

  static const empty =
      OwnerBusinessSummary(hasApprovedBusiness: false, approvedBusinessCount: 0, totalBusinessCount: 0);

  factory OwnerBusinessSummary.fromJson(Map<String, dynamic> json) => OwnerBusinessSummary(
        hasApprovedBusiness: json['hasApprovedBusiness'] as bool? ?? false,
        approvedBusinessCount: (json['approvedBusinessCount'] as num?)?.toInt() ?? 0,
        totalBusinessCount: (json['totalBusinessCount'] as num?)?.toInt() ?? 0,
      );
}

/// One owned business in the selector list.
class OwnerBusiness {
  const OwnerBusiness({
    required this.id,
    required this.slug,
    required this.name,
    required this.kind,
    required this.tagline,
    required this.status,
    required this.isVerified,
    required this.rating,
    required this.reviewCount,
    required this.area,
    required this.cityName,
    required this.primaryImage,
    required this.categories,
    required this.activeOffers,
  });

  final String id;
  final String slug;
  final String name;
  final String kind;
  final String tagline;
  final String status;
  final bool isVerified;
  final double rating;
  final int reviewCount;
  final String area;
  final String cityName;
  final String primaryImage;
  final List<String> categories;
  final int activeOffers;

  bool get isApproved => status == 'approved';

  factory OwnerBusiness.fromJson(Map<String, dynamic> json) => OwnerBusiness(
        id: json['id']?.toString() ?? '',
        slug: json['slug']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        kind: json['kind']?.toString() ?? '',
        tagline: json['tagline']?.toString() ?? '',
        status: json['status']?.toString() ?? 'pending',
        isVerified: json['isVerified'] as bool? ?? false,
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
        area: json['area']?.toString() ?? '',
        cityName: json['cityName']?.toString() ?? '',
        primaryImage: json['primaryImage']?.toString() ?? '',
        categories: (json['categories'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        activeOffers: (json['activeOffers'] as num?)?.toInt() ?? 0,
      );

  static List<OwnerBusiness> fromList(dynamic data) => (data as List? ?? const [])
      .map((e) => e is Map<String, dynamic> ? OwnerBusiness.fromJson(e) : null)
      .whereType<OwnerBusiness>()
      .toList();
}

/// One day of opening hours (0 = Monday … 6 = Sunday in the app UI).
class BusinessHour {
  const BusinessHour({
    required this.dayOfWeek,
    required this.isClosed,
    required this.openTime,
    required this.closeTime,
    this.configured = false,
  });

  final int dayOfWeek;
  final bool isClosed;
  final String openTime; // "HH:MM"
  final String closeTime;
  final bool configured;

  BusinessHour copyWith({bool? isClosed, String? openTime, String? closeTime}) => BusinessHour(
        dayOfWeek: dayOfWeek,
        isClosed: isClosed ?? this.isClosed,
        openTime: openTime ?? this.openTime,
        closeTime: closeTime ?? this.closeTime,
        configured: true,
      );

  factory BusinessHour.fromJson(Map<String, dynamic> json) => BusinessHour(
        dayOfWeek: (json['dayOfWeek'] as num?)?.toInt() ?? 0,
        isClosed: json['isClosed'] as bool? ?? false,
        openTime: json['openTime']?.toString() ?? '09:00',
        closeTime: json['closeTime']?.toString() ?? '21:00',
        configured: json['configured'] as bool? ?? false,
      );
}

/// Owner-managed offer (existing offers table, surfaced per phase).
class OwnerOffer {
  const OwnerOffer({
    required this.id,
    required this.title,
    required this.description,
    required this.badgeText,
    required this.subtitle,
    required this.couponCode,
    required this.categoryTag,
    required this.discountType,
    required this.discountValue,
    required this.validFrom,
    required this.validUntil,
    required this.status,
    required this.phase,
    required this.isFeatured,
  });

  final String id;
  final String title;
  final String description;
  final String badgeText;
  final String subtitle;
  final String couponCode;
  final String categoryTag;
  final String? discountType;
  final double? discountValue;
  final String? validFrom;
  final String? validUntil;
  final String status;
  final String phase; // active | scheduled | expired | draft
  final bool isFeatured;

  factory OwnerOffer.fromJson(Map<String, dynamic> json) => OwnerOffer(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        badgeText: json['badgeText']?.toString() ?? '',
        subtitle: json['subtitle']?.toString() ?? '',
        couponCode: json['couponCode']?.toString() ?? '',
        categoryTag: json['categoryTag']?.toString() ?? 'All',
        discountType: json['discountType']?.toString(),
        discountValue: (json['discountValue'] as num?)?.toDouble(),
        validFrom: json['validFrom']?.toString(),
        validUntil: json['validUntil']?.toString(),
        status: json['status']?.toString() ?? 'draft',
        phase: json['phase']?.toString() ?? 'draft',
        isFeatured: json['isFeatured'] as bool? ?? false,
      );

  static List<OwnerOffer> fromList(dynamic data) => (data as List? ?? const [])
      .map((e) => e is Map<String, dynamic> ? OwnerOffer.fromJson(e) : null)
      .whereType<OwnerOffer>()
      .toList();
}

class OwnerMenuItem {
  const OwnerMenuItem({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.isVeg,
    required this.available,
    required this.sortOrder,
  });

  final String id;
  final String? categoryId;
  final String name;
  final String description;
  final String price;
  final String imageUrl;
  final bool isVeg;
  final bool available;
  final int sortOrder;

  factory OwnerMenuItem.fromJson(Map<String, dynamic> json) => OwnerMenuItem(
        id: json['id']?.toString() ?? '',
        categoryId: json['categoryId']?.toString(),
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        price: json['price']?.toString() ?? '',
        imageUrl: json['imageUrl']?.toString() ?? '',
        isVeg: json['isVeg'] as bool? ?? true,
        available: json['available'] as bool? ?? true,
        sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      );

  static List<OwnerMenuItem> fromList(dynamic data) => (data as List? ?? const [])
      .map((e) => e is Map<String, dynamic> ? OwnerMenuItem.fromJson(e) : null)
      .whereType<OwnerMenuItem>()
      .toList();
}

class OwnerMenuCategory {
  const OwnerMenuCategory({required this.id, required this.name, required this.active});

  final String id;
  final String name;
  final bool active;

  factory OwnerMenuCategory.fromJson(Map<String, dynamic> json) => OwnerMenuCategory(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        active: json['active'] as bool? ?? true,
      );

  static List<OwnerMenuCategory> fromList(dynamic data) => (data as List? ?? const [])
      .map((e) => e is Map<String, dynamic> ? OwnerMenuCategory.fromJson(e) : null)
      .whereType<OwnerMenuCategory>()
      .toList();
}

class BusinessServiceItem {
  const BusinessServiceItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    required this.active,
  });

  final String id;
  final String name;
  final String description;
  final String price;
  final int? durationMinutes;
  final bool active;

  factory BusinessServiceItem.fromJson(Map<String, dynamic> json) => BusinessServiceItem(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        price: json['price']?.toString() ?? '',
        durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
        active: json['active'] as bool? ?? true,
      );

  static List<BusinessServiceItem> fromList(dynamic data) => (data as List? ?? const [])
      .map((e) => e is Map<String, dynamic> ? BusinessServiceItem.fromJson(e) : null)
      .whereType<BusinessServiceItem>()
      .toList();
}

class OwnerBusinessImage {
  const OwnerBusinessImage({
    required this.id,
    required this.url,
    required this.isPrimary,
    required this.sortOrder,
  });

  final String id;
  final String url;
  final bool isPrimary;
  final int sortOrder;

  factory OwnerBusinessImage.fromJson(Map<String, dynamic> json) => OwnerBusinessImage(
        id: json['id']?.toString() ?? '',
        url: json['url']?.toString() ?? '',
        isPrimary: json['isPrimary'] as bool? ?? false,
        sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      );

  static List<OwnerBusinessImage> fromList(dynamic data) => (data as List? ?? const [])
      .map((e) => e is Map<String, dynamic> ? OwnerBusinessImage.fromJson(e) : null)
      .whereType<OwnerBusinessImage>()
      .toList();
}

class OwnerReview {
  const OwnerReview({
    required this.rating,
    required this.comment,
    required this.author,
    required this.createdAt,
  });

  final double rating;
  final String comment;
  final String author;
  final String createdAt;

  factory OwnerReview.fromJson(Map<String, dynamic> json) => OwnerReview(
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        comment: json['comment']?.toString() ?? '',
        author: json['author']?.toString() ?? 'CityBee user',
        createdAt: json['createdAt']?.toString() ?? '',
      );
}

/// Full management payload for one owned business.
class OwnerBusinessDetails {
  const OwnerBusinessDetails({
    required this.id,
    required this.slug,
    required this.name,
    required this.kind,
    required this.tagline,
    required this.description,
    required this.phone,
    required this.whatsapp,
    required this.email,
    required this.website,
    required this.address,
    required this.locality,
    required this.postalCode,
    required this.openingHours,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.rejectionReason,
    required this.isVerified,
    required this.rating,
    required this.reviewCount,
    required this.cityName,
    required this.categories,
    required this.images,
    required this.hours,
    required this.offers,
    required this.services,
    required this.menuCategories,
    required this.menuItems,
    required this.doctor,
    required this.restaurant,
    required this.hotel,
    required this.hotelAmenities,
  });

  final String id;
  final String slug;
  final String name;
  final String kind;
  final String tagline;
  final String description;
  final String phone;
  final String whatsapp;
  final String email;
  final String website;
  final String address;
  final String locality;
  final String postalCode;
  final String openingHours;
  final double? latitude;
  final double? longitude;
  final String status;
  final String rejectionReason;
  final bool isVerified;
  final double rating;
  final int reviewCount;
  final String cityName;
  final List<String> categories;
  final List<OwnerBusinessImage> images;
  final List<BusinessHour> hours;
  final List<OwnerOffer> offers;
  final List<BusinessServiceItem> services;
  final List<OwnerMenuCategory> menuCategories;
  final List<OwnerMenuItem> menuItems;
  final Map<String, dynamic>? doctor;
  final Map<String, dynamic>? restaurant;
  final Map<String, dynamic>? hotel;
  final List<String> hotelAmenities;

  bool get isApproved => status == 'approved';

  factory OwnerBusinessDetails.fromJson(Map<String, dynamic> json) => OwnerBusinessDetails(
        id: json['id']?.toString() ?? '',
        slug: json['slug']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        kind: json['kind']?.toString() ?? '',
        tagline: json['tagline']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        whatsapp: json['whatsapp']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        website: json['website']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        locality: json['locality']?.toString() ?? '',
        postalCode: json['postalCode']?.toString() ?? '',
        openingHours: json['openingHours']?.toString() ?? '',
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        status: json['status']?.toString() ?? 'pending',
        rejectionReason: json['rejectionReason']?.toString() ?? '',
        isVerified: json['isVerified'] as bool? ?? false,
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
        cityName: json['cityName']?.toString() ?? '',
        categories: (json['categories'] as List?)
                ?.map((e) => e is Map<String, dynamic> ? e['name'].toString() : e.toString())
                .toList() ??
            const [],
        images: OwnerBusinessImage.fromList(json['images']),
        hours: ((json['hours'] as List?) ?? const [])
            .map((e) => e is Map<String, dynamic> ? BusinessHour.fromJson(e) : null)
            .whereType<BusinessHour>()
            .toList(),
        offers: OwnerOffer.fromList(json['offers']),
        services: BusinessServiceItem.fromList(json['services']),
        menuCategories: OwnerMenuCategory.fromList((json['menu'] as Map<String, dynamic>?)?['categories']),
        menuItems: OwnerMenuItem.fromList((json['menu'] as Map<String, dynamic>?)?['items']),
        doctor: json['doctor'] is Map<String, dynamic> ? json['doctor'] as Map<String, dynamic> : null,
        restaurant:
            json['restaurant'] is Map<String, dynamic> ? json['restaurant'] as Map<String, dynamic> : null,
        hotel: json['hotel'] is Map<String, dynamic> ? json['hotel'] as Map<String, dynamic> : null,
        hotelAmenities: (json['hotel'] is Map<String, dynamic>
                ? ((json['hotel'] as Map<String, dynamic>)['amenities'] as List?)
                : null)
            ?.map((e) => e.toString())
            .toList() ?? const [],
      );
}
