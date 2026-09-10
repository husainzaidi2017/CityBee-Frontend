import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../core/widgets/pressable.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/states_view.dart';
import '../../../domain/models/app_category.dart';
import '../../../providers/app_providers.dart';
import 'widgets/category_visual.dart';

/// "All Categories" — the full destination for Home's
/// Explore Near You → View All. Renders every configured category with its
/// icon, tinted tile and press animation; tapping opens the existing
/// category listing screen.
class AllCategoriesScreen extends ConsumerWidget {
  const AllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final location = ref.watch(selectedLocationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  Text(
                    'All Categories',
                    style: AppTypography.title.copyWith(fontSize: 17),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Text(
                'Everything to explore in ${location.displayName}',
                style: AppTypography.caption,
              ),
            ),
            Expanded(
              child: categories.when(
                data: (list) => GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.05,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, index) => FadeSlideIn(
                    delay: Duration(milliseconds: 30 * index),
                    child: _CategoryTile(category: list[index]),
                  ),
                ),
                loading: () => GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.05,
                  ),
                  itemCount: 9,
                  itemBuilder: (_, __) =>
                      const SkeletonBox(height: double.infinity, radius: 18),
                ),
                error: (e, _) => StatesView.error(
                  message: 'Could not load categories.',
                  onRetry: () => ref.invalidate(categoriesProvider),
                ),
              ),
            ),
          ],
        ),
      ),
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
      pressedScale: 0.95,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppShadows.card,
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CategoryIcon(visual: visual, size: 52),
            const SizedBox(height: 9),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTypography.bodyStrong.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
