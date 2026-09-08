import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import 'package:localgo/core/theme/app_typography.dart';
import 'package:localgo/core/widgets/app_image.dart';
import 'package:localgo/core/widgets/chips.dart';
import 'package:localgo/core/widgets/location_app_bar.dart';
import 'package:localgo/core/widgets/search_bar.dart';
import 'package:localgo/core/widgets/section_header.dart';
import 'package:localgo/core/widgets/states_view.dart';
import 'package:localgo/data/mock/mock_data.dart';
import 'package:localgo/data/repositories/business_repository.dart';
import 'package:localgo/domain/models/place.dart';
import 'package:localgo/providers/app_providers.dart';

import 'widgets/explore_nearby_grid.dart';
import 'widgets/home_hero_banner.dart';
import 'widgets/offers_rail.dart';
import 'widgets/owner_cta_card.dart';
import 'widgets/popular_business_card.dart';

/// Home tab: search, quick chips, hero banner, category grid, offers rail,
/// popular businesses, city places and the owner CTA.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  PopularFilter _popularFilter = PopularFilter.all;

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(selectedLocationProvider);
    final categories = ref.watch(categoriesProvider);
    final offers = ref.watch(offersByTagProvider('All'));
    final popular = ref.watch(popularBusinessesProvider(_popularFilter));
    final places = ref.watch(placesProvider);
    final offersCount = ref.watch(offersCountProvider).valueOrNull ?? 0;

    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          const LocationAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Search ───────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: AppSearchBar(
                      hint: 'Search anything in ${location.displayName}…',
                      readOnly: true,
                      onTap: () => context.push('/search'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Quick-shortcut chips: 38px rail so the 34px chips never clip.
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: homeQuickChips.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, index) => Center(
                        child: SelectChip(
                          label: homeQuickChips[index],
                          selected: false,
                          onTap: () => switch (index) {
                            // ⚡ Lightning Deals → Offers tab.
                            0 => context.go('/offers'),
                            // Cinemas Open → cinemas listing.
                            1 => context.push('/category/cinemas'),
                            // Biryani & Food → restaurants & dining listing.
                            _ => context.push('/category/dining'),
                          },
                        ),
                      ),
                    ),
                  ),

                  // ── Hero banner ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: HomeHeroBanner(),
                  ),

                  // ── Explore Near You ────────────────────────────────
                  _Section(
                    header: SectionHeader(
                      title: 'Explore Near You',
                      trailingLabel: 'View All (10) >',
                      onTrailingTap: () => context.push('/categories'),
                    ),
                    child: categories.when(
                      data: (list) => ExploreNearbyGrid(categories: list),
                      loading: () => const _RailSkeleton(height: 190),
                      error: (e, _) => _InlineError(onRetry: () => ref.invalidate(categoriesProvider)),
                    ),
                  ),

                  // ── Offers Near You ─────────────────────────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                        child: SectionHeader(
                          title: 'Offers Near You',
                          trailingLabel: 'See All ($offersCount) >',
                          onTrailingTap: () => context.go('/offers'),
                        ),
                      ),
                      offers.when(
                        data: (list) => OffersRail(
                          offers: list.where((o) => !o.featured).take(4).toList(),
                        ),
                        loading: () => const _RailSkeleton(height: 196, indented: true),
                        error: (e, _) => _InlineError(onRetry: () => ref.invalidate(offersByTagProvider('All'))),
                      ),
                    ],
                  ),

                  // ── Popular Near You ────────────────────────────────
                  _Section(
                    header: SectionHeader(title: 'Popular Near You'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 32,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: PopularFilter.values.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            padding: const EdgeInsets.only(bottom: 0),
                            itemBuilder: (_, index) {
                              final filter = PopularFilter.values[index];
                              return SelectChip(
                                label: switch (filter) {
                                  PopularFilter.all => 'All',
                                  PopularFilter.dining => 'Dining',
                                  PopularFilter.shopping => 'Shopping',
                                  PopularFilter.health => 'Health',
                                },
                                selected: filter == _popularFilter,
                                onTap: () => setState(() => _popularFilter = filter),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        popular.when(
                          data: (list) => Column(
                            children: list
                                .take(4)
                                .map((b) => PopularBusinessCard(business: b))
                                .toList(),
                          ),
                          loading: () => const _RailSkeleton(height: 240),
                          error: (e, _) => _InlineError(
                            onRetry: () => ref.invalidate(
                              popularBusinessesProvider(_popularFilter),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Explore City ────────────────────────────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                        child: SectionHeader(
                          title: 'Explore ${location.displayName}',
                          trailingLabel: 'See All >',
                          onTrailingTap: () => context.go('/explore'),
                        ),
                      ),
                      places.when(
                        data: (list) => _CityPlacesRail(places: list.take(3).toList()),
                        loading: () => const _RailSkeleton(height: 150, indented: true),
                        error: (e, _) => _InlineError(onRetry: () => ref.invalidate(placesProvider)),
                      ),
                    ],
                  ),

                  // ── Owner CTA + footer ──────────────────────────────
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
                    child: OwnerCtaCard(),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'About   ·   Help   ·   Terms',
                      style: AppTypography.label.copyWith(fontSize: 10),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'CityBee · Made in ${location.displayName} 💚',
                      style: AppTypography.label.copyWith(fontSize: 9.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Standard vertical section: header + content with screen padding.
class _Section extends StatelessWidget {
  const _Section({required this.header, required this.child});

  final Widget header;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Horizontal "Explore City" place cards.
class _CityPlacesRail extends StatelessWidget {
  const _CityPlacesRail({required this.places});

  final List<Place> places;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: places.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final place = places[index];
          return GestureDetector(
            onTap: () => context.push('/place/${place.id}'),
            child: Container(
              width: 190,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 86,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AppImage(url: place.image, fallbackIcon: Icons.photo_camera_outlined),
                        Positioned(
                          left: 8,
                          bottom: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              place.ratingText,
                              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 7, 10, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.titleSm.copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          place.metaLine,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.label.copyWith(fontSize: 9.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RailSkeleton extends StatelessWidget {
  const _RailSkeleton({required this.height, this.indented = false});

  final double height;
  final bool indented;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: indented ? 16 : 0),
        itemCount: 2,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => Container(
          width: 236,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: StatesView.error(
        message: 'Could not load this section.',
        onRetry: onRetry,
      ),
    );
  }
}
