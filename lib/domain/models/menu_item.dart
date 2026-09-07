/// A dish / service menu item shown on business detail pages.
class MenuItem {
  const MenuItem({
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    this.isVeg = true,
  });

  final String name;
  final String description;

  /// Display-ready price text, e.g. "₹340".
  final String price;
  final String image;
  final bool isVeg;
}
