import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/share_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_launcher.dart';
import '../../../core/widgets/badges.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/collapsing_detail_header.dart';
import '../../../core/widgets/photo_viewer.dart';
import '../../../core/widgets/map_preview.dart';
import '../../../core/widgets/states_view.dart';
import '../../../domain/models/place.dart';
import '../../../providers/app_providers.dart';
import '../../../core/widgets/app_icons.dart';

/// Place detail: hero, meta strip, description, info rows and map.
class PlaceDetailScreen extends ConsumerWidget {
  const PlaceDetailScreen({super.key, required this.placeId});

  final String placeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placeAsync = ref.watch(placeByIdProvider(placeId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: placeAsync.when(
        data: (place) {
          if (place == null) {
            return const _MissingPlace();
          }
          return _PlaceDetailBody(place: place);
        },
        loading: () => StatesView.loading(message: 'Loading place…'),
        error: (e, _) => StatesView.error(
          message: 'Could not load this place.',
          onRetry: () => ref.invalidate(placeByIdProvider(placeId)),
        ),
      ),
    );
  }
}

class _MissingPlace extends StatelessWidget {
  const _MissingPlace();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        const BackButton(),
        Expanded(
          child: StatesView.empty(
            icon: AppUiIcons.camera_outline,
            message: 'This place is no longer available.',
          ),
        ),
      ],
    );
  }
}

void _openViewer(BuildContext context, String imageUrl) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => PhotoViewerScreen(imageUrls: [imageUrl]),
    ),
  );
}

class _PlaceDetailBody extends ConsumerWidget {
  const _PlaceDetailBody({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaved = ref.watch(favoritesProvider).contains(place.id);
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              // ── Immersive collapsing hero (back · favorite · share) ──
              CollapsingDetailHeader(
                title: place.name,
                image: place.image,
                fallbackIcon: AppUiIcons.camera_outline,
                isFavorite: isSaved,
                onImageTap: (index) => _openViewer(context, place.image),
                onFavoriteTap: () {
                  ref
                      .read(favoritesProvider.notifier)
                      .toggle(place.id, uuid: place.uuid, type: 'place');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          isSaved ? 'Removed from favorites' : 'Saved to favorites'),
                    ),
                  );
                },
                onShareTap: () => ShareService.sharePlace(place),
                badge: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RatingPill.soft(rating: place.ratingText.split(' ').first),
                    const SizedBox(width: 6),
                    ...place.tags.take(2).map((tag) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )),
                  ],
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                sliver: SliverList.list(
                  children: [
                    // ── Title + meta strip ────────────────────────────
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          style: AppTypography.headline.copyWith(fontSize: 20),
                        ),
                        const SizedBox(height: 8),
                        _MetaStrip(place: place),
                      ],
                    ),

                    // ── Description ───────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('About this place', style: AppTypography.titleSm),
                          const SizedBox(height: 6),
                          Text(place.description, style: AppTypography.body),
                        ],
                      ),
                    ),

                    // ── Info card ─────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: _InfoCard(place: place),
                    ),

                    // ── Map ───────────────────────────────────────────
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: MapPreview(
                        latitude: 28.8386,
                        longitude: 78.7733,
                        height: 150,
                        pinLabel: 'City Center',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Sticky action ──────────────────────────────────────────
        Container(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            12 + MediaQuery.paddingOf(context).bottom,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: CardActionButton(
                  label: 'Get Directions',
                  filled: true,
                  onTap: () => AppLauncher.directions(28.8386, 78.7733, label: place.name),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CardActionButton(
                  label: 'Add to Trip',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to your trip plan')),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetaStrip extends StatelessWidget {
  const _MetaStrip({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final parts = place.metaLine.split(' · ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: parts
            .map((part) => Column(
                  children: [
                    Text(
                      part,
                      style: AppTypography.bodyStrong.copyWith(fontSize: 12.5),
                    ),
                  ],
                ))
            .toList(),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final rows = <List<Object?>>[
      if (place.address.isNotEmpty)
        [
          'ADDRESS',
          place.address,
          'View Map',
          () => AppLauncher.openWebsite(
              'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(place.address.isEmpty ? place.name : place.address)}'),
        ],
      if (place.timings.isNotEmpty) ['TIMINGS', place.timings, null, null],
      if (place.entryFee.isNotEmpty) ['ENTRY FEE', place.entryFee, null, null],
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Text('Contact Details', style: AppTypography.titleSm),
        const SizedBox(height: 9),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) const Divider(height: 1, color: AppColors.divider),
                InkWell(
                  onTap: rows[i][3] as VoidCallback?,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 96,
                        color: AppColors.background,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        child: Text(
                          rows[i][0] as String,
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            rows[i][1] as String,
                            style: AppTypography.body.copyWith(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                      if (rows[i][2] != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Text(
                            rows[i][2] as String,
                            style: TextStyle(
                              fontFamily: AppTypography.bodyFamily,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

