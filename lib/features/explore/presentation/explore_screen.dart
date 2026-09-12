import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/share_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/badges.dart';
import '../../../core/widgets/pressable.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/states_view.dart';
import '../../../domain/models/place.dart';
import '../../../providers/app_providers.dart';
import '../../../core/widgets/app_icons.dart';
import 'package:iconify_flutter/iconify_flutter.dart';

/// Explore tab: city guide hero, curated spots, food rail and tips —
/// the "Explore City" discovery screen. All copy is driven by the
/// selected location so the screen works for any city.
class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(selectedLocationProvider);
    final places = ref.watch(placesProvider);
    final foods = ref.watch(foodsProvider);
    final guide = ref.watch(cityGuideProvider);

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Explore ${location.displayName}', style: AppTypography.headline),
                  const SizedBox(height: 3),
                  Text(
                    'Your local guide to ${location.state ?? location.displayName} — food, markets & heritage',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: places.when(
                data: (placeList) => ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    // ── Featured guide card ─────────────────────────
                    guide.maybeWhen(
                      data: (g) => _GuideCard(guide: g),
                      orElse: () => const SkeletonCard(
                          height: 200, width: double.infinity, imageHeight: 200, radius: 18),
                    ),
                    const SizedBox(height: 20),

                    // ── Curated spotlights ──────────────────────────
                    const SectionHeader(title: 'Curated City Spotlights'),
                    const SizedBox(height: 10),
                    if (placeList.isEmpty)
                      const _InlineEmpty(
                        icon: AppUiIcons.compass_outline,
                        message: 'No places to explore here yet — check back soon.',
                      )
                    else
                      ...placeList.map((place) => Padding(
                            padding: const EdgeInsets.only(bottom: 11),
                            child: _PlaceSpotlightCard(place: place),
                          )),
                    const SizedBox(height: 10),

                    // ── Food rail ───────────────────────────────────
                    SectionHeader(
                      title: 'Local Flavors & Food',
                      subtitle: 'Tried, tested & loved by locals',
                    ),
                    const SizedBox(height: 10),
                    foods.maybeWhen(
                      data: (foodList) => foodList.isEmpty
                          ? const _InlineEmpty(
                              icon: AppUiIcons.silverware_fork_knife,
                              message: 'No local food picks here yet.',
                            )
                          : _FoodRail(foods: foodList),
                      orElse: () => const SkeletonRail(
                          height: 168, itemWidth: 150, indented: true),
                    ),
                    const SizedBox(height: 20),

                    // ── Explorer tips ───────────────────────────────
                    const SectionHeader(title: 'Tips for Smart Explorers'),
                    const SizedBox(height: 10),
                    const _TipsCard(),
                    const SizedBox(height: 18),

                    // ── Plan CTA ────────────────────────────────────
                    _PlanTripCta(cityName: location.displayName),
                  ],
                ),
                loading: () => ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: const [
                    SkeletonCard(
                        height: 200, width: double.infinity, imageHeight: 200, radius: 18),
                    SizedBox(height: 20),
                    SkeletonBox(height: 16, width: 200, radius: 8),
                    SizedBox(height: 12),
                    SkeletonList(itemCount: 3, itemHeight: 124),
                  ],
                ),
                error: (e, _) => StatesView.error(
                  message: 'Could not load places. Check your connection.',
                  onRetry: () => ref.invalidate(placesProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact inline empty placeholder for explore sections.
class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty({required this.icon, required this.message});

  final String icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Iconify(icon, size: 22, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: AppTypography.caption),
        ],
      ),
    );
  }
}

/// ── Featured artisan guide hero ────────────────────────────────────────
class _GuideCard extends StatelessWidget {
  const _GuideCard({required this.guide});

  final CityGuide guide;

  void _openGuide(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(guide.title, style: AppTypography.title),
              const SizedBox(height: 5),
              Text('By ${guide.author}', style: AppTypography.label),
              const SizedBox(height: 10),
              Text(guide.subtitle, style: AppTypography.body),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999)),
                  ),
                  onPressed: () => ShareService.shareApp(
                    note: '${guide.title} — ${guide.subtitle}',
                  ),
                  icon: AppUiIcons.show(AppUiIcons.share, size: 14),
                  label: const Text('Share This Guide',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => _openGuide(context),
      child: Container(
        height: 200,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppShadows.card,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppImage(url: guide.image, fallbackIcon: AppUiIcons.auto_fix),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 0.4, 1],
                  colors: [Colors.transparent, Colors.transparent, Color(0xE617211B)],
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 13,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Text(
                      'FEATURED GUIDE',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    guide.title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    guide.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'By ${guide.author}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ── Curated place spotlight row ────────────────────────────────────────
class _PlaceSpotlightCard extends StatelessWidget {
  const _PlaceSpotlightCard({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => context.push('/place/${place.id}'),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 96,
              height: 104,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AppImage(url: place.image, fallbackIcon: AppUiIcons.camera_outline),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleSm,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    place.metaLine,
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    place.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(height: 1.35),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      RatingPill.soft(rating: place.ratingText.split(' ').first),
                      const SizedBox(width: 6),
                      ...place.tags.take(2).map((tag) => Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(7),
                                boxShadow: AppShadows.card,
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ── Food highlights rail ───────────────────────────────────────────────
class _FoodRail extends StatelessWidget {
  const _FoodRail({required this.foods});

  final List<FoodHighlight> foods;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: foods.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final food = foods[index];
          return SizedBox(
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 108,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: AppImage(url: food.image, fallbackIcon: AppUiIcons.silverware_fork_knife),
                      ),
                      Positioned(
                        top: 7,
                        right: 7,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Iconify(AppUiIcons.star, size: 9, color: AppColors.starAmber),
                              const SizedBox(width: 2),
                              Text(
                                food.rating,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  food.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleSm.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  food.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label.copyWith(fontSize: 10.5),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// ── Explorer tips card ─────────────────────────────────────────────────
class _TipsCard extends ConsumerWidget {
  const _TipsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(selectedLocationProvider);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          for (var i = 0; i < 3; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == 2 ? 0 : 11),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Iconify(
                    switch (i) {
                      0 => AppUiIcons.clock_outline,
                      1 => AppUiIcons.handshake_outline,
                      _ => AppUiIcons.account_voice,
                    },
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          switch (i) {
                            0 => 'Best Times to Visit',
                            1 => 'Bargain Like a Local',
                            _ => 'Local Phrases',
                          },
                          style: AppTypography.bodyStrong,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          switch (i) {
                            0 =>
                              'Mornings (8–11 AM) are cooler and bazaars are most active.',
                            1 =>
                              'Compare at least three shops in ${location.displayName} before you buy.',
                            _ => 'A little Hindi goes a long way — “kitne ka hai?” (how much?).',
                          },
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// ── Plan-a-trip CTA ────────────────────────────────────────────────────
class _PlanTripCta extends StatelessWidget {
  const _PlanTripCta({required this.cityName});

  final String cityName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.bannerOrangeTop, AppColors.bannerOrangeBottom],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan Your $cityName Trip',
                  style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Save spots, build a route & share with friends.',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => ShareService.shareApp(
              note: 'I am planning a trip to $cityName with CityBee — '
                  'bazaars, food and heritage walks!',
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Start Planning',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
