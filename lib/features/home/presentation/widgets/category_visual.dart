import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import '../../../../core/widgets/app_icons.dart';

/// Resolve API slugs and legacy category IDs without changing navigation IDs.
class CategoryVisual {
  const CategoryVisual(this.icon);
  final String icon;

  static CategoryVisual of(String id) =>
      CategoryVisual(switch (id.trim().toLowerCase()) {
        'fashion' => AppUiIcons.tShirt,
        'shops' || 'shop' || 'grocery' || 'groceries' => AppUiIcons.storefront,
        'dining' || 'restaurant' || 'restaurants' => AppUiIcons.food,
        'doctor' || 'doctors' || 'hospital' || 'hospitals' => AppUiIcons.medical_bag,
        'hotel' || 'hotels' => AppUiIcons.building1,
        // Barber merged into Salons (category removed from the database —
        // its businesses were relinked to salons).
        'barber' || 'barbers' => AppUiIcons.scissors2,
        'heritage' || 'heritages' => AppUiIcons.monument,
        'salon' || 'salons' || 'spa' => AppUiIcons.scissors2,
        'mall' || 'malls' => AppUiIcons.shoppingBag,
        'cinema' || 'cinemas' => AppUiIcons.movie,
        'gym' || 'gyms' => AppUiIcons.dumbbell,
        'bar' || 'bars' => AppUiIcons.wineglass,
        'cafe' || 'cafes' => AppUiIcons.teacup,
        _ => AppUiIcons.storefront,
      });
}

/// Category glyph (MingCute), shared by Home and All Categories.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({super.key, required this.visual, this.size = 44, this.color});
  final CategoryVisual visual;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => Iconify(
    visual.icon,
    size: size,
    color: color,
  );
}
