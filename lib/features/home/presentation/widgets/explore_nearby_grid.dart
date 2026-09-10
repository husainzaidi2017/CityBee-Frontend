import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../../domain/models/app_category.dart';
import 'category_visual.dart';

/// "Explore Near You" 4-column category grid (8 tiles on Home).
class ExploreNearbyGrid extends StatelessWidget {
  const ExploreNearbyGrid({super.key, required this.categories});

  final List<AppCategory> categories;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.88,
      ),
      itemCount: categories.take(8).length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _CategoryTile(category: category);
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});

  final AppCategory category;

  @override
  Widget build(BuildContext context) {
    final visual = CategoryVisual.of(category.id);
    return Pressable(
      onTap: () => context.push('/category/${category.id}'),
      pressedScale: 0.96,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CategoryIcon(visual: visual, size: 42),
            const SizedBox(height: 7),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label.copyWith(
                  fontSize: 11,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
