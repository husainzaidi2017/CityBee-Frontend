/// A discount offer / coupon from a local business.
class Offer {
  const Offer({
    required this.id,
    required this.businessId,
    required this.title,
    required this.badgeText,
    required this.subtitle,
    required this.description,
    required this.couponCode,
    required this.validityText,
    required this.image,
    required this.categoryTag,
    required this.rating,
    required this.area,
    required this.distanceText,
    this.remainingText,
    this.leftCount,
    this.featured = false,
  });

  final String id;

  /// The business this offer belongs to (may be absent for mock entries).
  final String businessId;
  final String title;

  /// Big discount label, e.g. "25% OFF".
  final String badgeText;

  /// What the discount applies to, e.g. "on All Boutique".
  final String subtitle;
  final String description;
  final String couponCode;
  final String validityText;
  final String image;

  /// Filter chip group, e.g. "Dining", "Beauty & Salon".
  final String categoryTag;
  final double rating;
  final String area;
  final String distanceText;
  final String? remainingText;
  final int? leftCount;
  final bool featured;
}
