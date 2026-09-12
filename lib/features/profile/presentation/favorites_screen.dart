import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/states_view.dart';
import '../../../data/repositories/business_repository.dart';
import '../../../domain/models/business.dart';
import '../../../domain/models/place.dart';
import '../../../providers/app_providers.dart';
import '../../../core/widgets/app_icons.dart';

/// Bookmarked businesses and saved places for the current user.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final businesses = ref.watch(popularBusinessesProvider(PopularFilter.all));
    final places = ref.watch(placesProvider);

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
                    icon: AppUiIcons.show(AppUiIcons.back, size: 15),
                    onPressed: () => context.pop(),
                  ),
                  Text('My Favorites', style: AppTypography.title),
                ],
              ),
            ),
            Expanded(
              child: favorites.isEmpty
                  ? StatesView.empty(
                      icon: AppUiIcons.heart_outline,
                      message:
                          'No favorites yet — tap the heart on any business or place to save it here.',
                    )
                  : _FavoritesList(
                      favoriteIds: favorites,
                      businesses: businesses.valueOrNull ?? const [],
                      places: places.valueOrNull ?? const [],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoritesList extends StatelessWidget {
  const _FavoritesList({
    required this.favoriteIds,
    required this.businesses,
    required this.places,
  });

  final Set<String> favoriteIds;
  final List<Business> businesses;
  final List<Place> places;

  @override
  Widget build(BuildContext context) {
    final favBusinesses =
        businesses.where((b) => favoriteIds.contains(b.id)).toList();
    final favPlaces = places.where((p) => favoriteIds.contains(p.id)).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        if (favBusinesses.isNotEmpty) ...[
          Text('Businesses', style: AppTypography.titleSm),
          const SizedBox(height: 10),
          ...favBusinesses.map((business) => _FavoriteBusinessTile(business: business)),
        ],
        if (favPlaces.isNotEmpty) ...[
          if (favBusinesses.isNotEmpty) const SizedBox(height: 16),
          Text('Places', style: AppTypography.titleSm),
          const SizedBox(height: 10),
          ...favPlaces.map((place) => _FavoritePlaceTile(place: place)),
        ],
      ],
    );
  }
}

class _FavoriteBusinessTile extends StatelessWidget {
  const _FavoriteBusinessTile({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/business/${business.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AppImage(url: business.images.firstOrNull ?? '', width: 56, height: 56),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(business.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyStrong),
                  const SizedBox(height: 2),
                  Text(
                    '${business.tagline} · ${business.area}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label,
                  ),
                ],
              ),
            ),
            AppUiIcons.show(AppUiIcons.heart, size: 15, color: AppColors.brandRed),
          ],
        ),
      ),
    );
  }
}

class _FavoritePlaceTile extends StatelessWidget {
  const _FavoritePlaceTile({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/place/${place.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AppImage(url: place.image, width: 56, height: 56),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(place.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyStrong),
                  const SizedBox(height: 2),
                  Text(
                    place.metaLine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label,
                  ),
                ],
              ),
            ),
            AppUiIcons.show(AppUiIcons.heart, size: 15, color: AppColors.brandRed),
          ],
        ),
      ),
    );
  }
}
