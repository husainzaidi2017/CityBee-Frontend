import 'package:flutter/material.dart';
import '../../../../core/widgets/app_icons.dart';
import 'animated_category_icon.dart';

/// Resolve API slugs and legacy category IDs without changing navigation
/// IDs. Each category carries its signature icon micro-animation.
class CategoryVisual {
  const CategoryVisual(this.icon, this.move);
  final String icon;
  final IconMove move;

  static CategoryVisual of(String id) => CategoryVisual(
        switch (id.trim().toLowerCase()) {
          'fashion' => AppUiIcons.tShirt,
          'shops' || 'shop' || 'grocery' || 'groceries' => AppUiIcons.storefront,
          'dining' || 'restaurant' || 'restaurants' => AppUiIcons.food,
          'doctor' || 'doctors' || 'hospital' || 'hospitals' =>
            AppUiIcons.medical_bag,
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
        },
        switch (id.trim().toLowerCase()) {
          'doctor' || 'doctors' || 'hospital' || 'hospitals' => IconMove.pulse,
          'dining' || 'restaurant' || 'restaurants' => IconMove.drop,
          'hotel' || 'hotels' => IconMove.float,
          'salon' || 'salons' || 'spa' || 'barber' || 'barbers' => IconMove.snip,
          'shops' || 'shop' || 'grocery' || 'groceries' ||
          'mall' || 'malls' || 'fashion' => IconMove.spin,
          'bar' || 'bars' || 'cafe' || 'cafes' || 'cinema' || 'cinemas' =>
            IconMove.wiggle,
          _ => IconMove.pop,
        },
      );
}

/// Category glyph with its signature micro-animation, shared by Home and
/// All Categories.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({super.key, required this.visual, this.size = 44, this.color});
  final CategoryVisual visual;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => AnimatedCategoryIcon(
    icon: visual.icon,
    move: visual.move,
    size: size,
    color: color,
  );
}
