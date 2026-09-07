import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Icon + tint for each category id — the single place that maps category
/// data to visuals (used by Home grid and listing headers).
class CategoryVisual {
  const CategoryVisual(this.icon, this.foreground, this.background);

  final IconData icon;
  final Color foreground;
  final Color background;

  static CategoryVisual of(String id) => switch (id) {
        'fashion' => const CategoryVisual(Icons.checkroom, AppColors.catFashion, AppColors.catFashionSoft),
        'grocery' => const CategoryVisual(Icons.shopping_basket, AppColors.catGrocery, AppColors.catGrocerySoft),
        'dining' => const CategoryVisual(Icons.restaurant, AppColors.catFood, AppColors.catFoodSoft),
        'doctors' => const CategoryVisual(Icons.medical_services, AppColors.catDoctor, AppColors.catDoctorSoft),
        'hotels' => const CategoryVisual(Icons.hotel, AppColors.catHotel, AppColors.catHotelSoft),
        'barbers' => const CategoryVisual(Icons.content_cut, AppColors.catBarber, AppColors.catBarberSoft),
        'heritage' => const CategoryVisual(Icons.account_balance, AppColors.catHeritage, AppColors.catHeritageSoft),
        'salons' => const CategoryVisual(Icons.spa, AppColors.catSalon, AppColors.catSalonSoft),
        'malls' => const CategoryVisual(Icons.local_mall, AppColors.catDoctor, AppColors.catDoctorSoft),
        _ => const CategoryVisual(Icons.storefront, AppColors.primary, AppColors.primarySoft),
      };
}
