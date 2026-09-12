/// A dish / service menu item shown on business detail pages.
class MenuItem {
  const MenuItem({
    required this.name,
    required this.description,
    required this.price,
    this.image,
    this.isVeg,
  });

  final String name;
  final String description;

  /// Display-ready price text, e.g. "₹340".
  final String price;

  /// Dish photos (restaurants); null for service items (rooms, plans…).
  final String? image;

  /// Veg marker (restaurants only); null hides the dot for other kinds.
  final bool? isVeg;
}
