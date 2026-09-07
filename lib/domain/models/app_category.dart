/// A discovery category shown in the "Explore Near You" grid and used to
/// scope business listings (e.g. Food & Dining, Doctors, Salons).
class AppCategory {
  const AppCategory({
    required this.id,
    required this.name,
    required this.listingTitle,
  });

  final String id;
  final String name;

  /// Title of the listing screen when this category is opened,
  /// e.g. "Restaurants & Dining in Moradabad".
  final String listingTitle;
}
