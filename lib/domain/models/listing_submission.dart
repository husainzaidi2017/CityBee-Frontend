// List-Your-Business submission models (mirror of /me/business-listings).

class ListingSubmission {
  const ListingSubmission({
    required this.id,
    required this.businessName,
    required this.categorySlug,
    required this.status,
    required this.rejectionReason,
    required this.submittedAt,
    required this.cityName,
    required this.hasImages,
  });

  final String id;
  final String businessName;
  final String categorySlug;
  final String status; // pending | approved | rejected
  final String rejectionReason;
  final String submittedAt;
  final String cityName;
  final bool hasImages;

  factory ListingSubmission.fromJson(Map<String, dynamic> json) =>
      ListingSubmission(
        id: json['id']?.toString() ?? '',
        businessName: json['businessName']?.toString() ?? '',
        categorySlug: json['categorySlug']?.toString() ?? '',
        status: json['status']?.toString() ?? 'pending',
        rejectionReason: json['rejectionReason']?.toString() ?? '',
        submittedAt: json['submittedAt']?.toString() ?? '',
        cityName: json['cityName']?.toString() ?? '',
        hasImages: json['hasImages'] as bool? ?? false,
      );

  static List<ListingSubmission> fromList(dynamic data) =>
      (data as List? ?? const [])
          .map((e) => e is Map<String, dynamic> ? ListingSubmission.fromJson(e) : null)
          .whereType<ListingSubmission>()
          .toList();
}

/// Everything the wizard collects before submitting.
class ListingDraft {
  ListingDraft({
    this.categorySlug,
    this.businessName = '',
    this.tagline = '',
    this.description = '',
    this.phone = '',
    this.whatsapp = '',
    this.email = '',
    this.website = '',
    this.address = '',
    this.locality = '',
    this.cityName = '',
    this.cityLat,
    this.cityLng,
    this.bizLat,
    this.bizLng,
    this.openingHours = '',
    // Doctor
    this.specialization,
    this.qualification,
    this.experienceYears,
    this.consultationFee,
    // Restaurant
    this.cuisine,
    this.priceRange,
    this.vegType = 'mixed',
    // Hotel
    this.hotelType,
    this.checkInTime,
    this.checkOutTime,
    this.amenities = const [],
    // Salon / service
    this.serviceNames = const [],
    this.imageUrls = const [],
  });

  String? categorySlug;
  String businessName;
  String tagline;
  String description;
  String phone;
  String whatsapp;
  String email;
  String website;
  String address;
  String locality;
  String cityName;
  double? cityLat;
  double? cityLng;
  double? bizLat;
  double? bizLng;
  String openingHours;

  String? specialization;
  String? qualification;
  int? experienceYears;
  String? consultationFee;

  String? cuisine;
  String? priceRange;
  String vegType;

  String? hotelType;
  String? checkInTime;
  String? checkOutTime;
  List<String> amenities;

  List<String> serviceNames;
  List<String> imageUrls;

  // Live DB slugs: the hotel category is "hotel" (was "hotels"), barber was
  // merged into salons, and gyms/bars/cafes exist too. Accept legacy and
  // current forms so old drafts keep working.
  bool get isDoctor => categorySlug == 'doctors';
  bool get isRestaurant => categorySlug == 'restaurants' || categorySlug == 'dining';
  bool get isHotel => categorySlug == 'hotel' || categorySlug == 'hotels';
  bool get isSalon =>
      categorySlug == 'salons' || categorySlug == 'salon' || categorySlug == 'barber' || categorySlug == 'barbers';

  Map<String, dynamic> toBody() => {
        'businessName': businessName.trim(),
        'categorySlug': categorySlug,
        if (tagline.trim().isNotEmpty) 'tagline': tagline.trim(),
        if (description.trim().isNotEmpty) 'description': description.trim(),
        'phone': phone.trim(),
        if (whatsapp.trim().isNotEmpty) 'whatsapp': whatsapp.trim(),
        if (email.trim().isNotEmpty) 'email': email.trim(),
        if (website.trim().isNotEmpty) 'website': website.trim(),
        'address': address.trim(),
        if (locality.trim().isNotEmpty) 'locality': locality.trim(),
        'cityName': cityName.trim(),
        if (cityLat != null) 'cityLat': cityLat,
        if (cityLng != null) 'cityLng': cityLng,
        'bizLat': bizLat,
        'bizLng': bizLng,
        if (openingHours.trim().isNotEmpty) 'openingHours': openingHours.trim(),
        if (isDoctor) ...{
          'specialization': specialization ?? '',
          if (qualification?.trim().isNotEmpty == true) 'qualification': qualification!.trim(),
          if (experienceYears != null) 'experienceYears': experienceYears,
          if (consultationFee?.trim().isNotEmpty == true) 'consultationFee': consultationFee!.trim(),
        },
        if (isRestaurant) ...{
          'cuisine': cuisine ?? '',
          if (priceRange?.trim().isNotEmpty == true) 'priceRange': priceRange!.trim(),
          'vegType': vegType,
        },
        if (isHotel) ...{
          'hotelType': hotelType ?? '',
          if (priceRange?.trim().isNotEmpty == true) 'priceRange': priceRange!.trim(),
          if (checkInTime?.trim().isNotEmpty == true) 'checkInTime': checkInTime!.trim(),
          if (checkOutTime?.trim().isNotEmpty == true) 'checkOutTime': checkOutTime!.trim(),
          if (amenities.isNotEmpty) 'amenities': amenities,
        },
        if (isSalon && serviceNames.isNotEmpty) 'serviceNames': serviceNames,
        if (imageUrls.isNotEmpty) 'imageUrls': imageUrls,
      };


  /// Prefills the draft from a submission detail (edit & resubmit flow).
  void applyDetail(Map<String, dynamic> d) {
    categorySlug = d['categorySlug']?.toString();
    businessName = d['businessName']?.toString() ?? '';
    tagline = d['tagline']?.toString() ?? '';
    description = d['description']?.toString() ?? '';
    phone = d['phone']?.toString() ?? '';
    whatsapp = d['whatsapp']?.toString() ?? '';
    email = d['email']?.toString() ?? '';
    website = d['website']?.toString() ?? '';
    address = d['address']?.toString() ?? '';
    locality = d['locality']?.toString() ?? '';
    cityName = d['cityName']?.toString() ?? '';
    cityLat = (d['cityLat'] as num?)?.toDouble();
    cityLng = (d['cityLng'] as num?)?.toDouble();
    bizLat = (d['bizLat'] as num?)?.toDouble();
    bizLng = (d['bizLng'] as num?)?.toDouble();
    openingHours = d['openingHours']?.toString() ?? '';
    specialization = d['specialization']?.toString();
    qualification = d['qualification']?.toString();
    experienceYears = (d['experienceYears'] as num?)?.toInt();
    consultationFee = d['consultationFee']?.toString();
    cuisine = d['cuisine']?.toString();
    priceRange = d['priceRange']?.toString();
    vegType = d['vegType']?.toString() ?? 'mixed';
    hotelType = d['hotelType']?.toString();
    checkInTime = d['checkInTime']?.toString();
    checkOutTime = d['checkOutTime']?.toString();
    amenities = (d['amenities'] as List? ?? const [])
        .map((e) => e.toString())
        .toList();
    imageUrls = (d['imageUrls'] as List? ?? const [])
        .map((e) => e.toString())
        .toList();
  }
}
