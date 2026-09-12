import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Resolve API slugs and legacy category IDs without changing navigation IDs.
class CategoryVisual {
  const CategoryVisual(this.assetName);
  final String assetName;
  String get assetPath => 'assets/categories/$assetName.svg';

  static CategoryVisual of(String id) =>
      CategoryVisual(switch (id.trim().toLowerCase()) {
        'fashion' => 'fashion',
        'shops' || 'shop' || 'grocery' || 'groceries' => 'shops',
        'dining' || 'restaurant' || 'restaurants' => 'restaurants',
        'doctor' || 'doctors' => 'doctors',
        'hotel' || 'hotels' => 'hotels',
        // Barber merged into Salons (category removed from the database —
        // its businesses were relinked to salons).
        'barber' || 'barbers' => 'salons',
        'heritage' || 'heritages' => 'heritage',
        'salon' || 'salons' || 'spa' => 'salons',
        'mall' || 'malls' => 'malls',
        'cinema' || 'cinemas' => 'cinemas',
        'gym' || 'gyms' => 'gym',
        'bar' || 'bars' => 'bar',
        'cafe' || 'cafes' => 'cafe',
        'hospital' || 'hospitals' => 'hospital',
        _ => 'shop',
      });
}

/// Original multicolor illustrations, shared by Home and All Categories.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({super.key, required this.visual, this.size = 44});
  final CategoryVisual visual;
  final double size;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    visual.assetPath,
    width: size,
    height: size,
    excludeFromSemantics: true,
  );
}
