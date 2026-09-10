/// A verified local specialist card on the Services hub.
class ServiceItem {
  const ServiceItem({
    required this.id,
    required this.name,
    required this.badge,
    required this.rating,
    required this.servicesSummary,
    required this.priceText,
    required this.etaText,
    required this.statsText,
    required this.trustNote,
    required this.image,
    required this.actionLabel,
    required this.phone,
    this.category,
    this.citySpecialty = false,
  });

  final String id;
  final String name;
  final String badge;
  final String rating;
  final String servicesSummary;
  final String priceText;
  final String etaText;
  final String statsText;
  final String trustNote;
  final String image;

  /// Primary CTA, e.g. "Book Slot", "Get Quote", "Send Rescue".
  final String actionLabel;
  final String phone;

  /// Trade category id this provider belongs to (electrician, plumber, …).
  /// Null = general/other (shown only in the unfiltered list).
  final String? category;
  final bool citySpecialty;
}

/// Emergency / civic helpline tile (108 Ambulance, 112 Police, …).
class Helpline {
  const Helpline({
    required this.label,
    required this.number,
    required this.colorValue,
  });

  final String label;

  /// Dial-ready number, e.g. "108".
  final String number;

  /// Brand color of the tile (stored as int to keep the model UI-free).
  final int colorValue;
}
