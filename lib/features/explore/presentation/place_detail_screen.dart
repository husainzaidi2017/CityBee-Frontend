import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/share_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_launcher.dart';
import '../../../core/widgets/badges.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/collapsing_detail_header.dart';
import '../../../core/widgets/map_preview.dart';
import '../../../core/widgets/states_view.dart';
import '../../../domain/models/place.dart';
import '../../../providers/app_providers.dart';

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
            icon: Icons.photo_camera_outlined,
            message: 'This place is no longer available.',
          ),
        ),
      ],
    );
  }
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
                fallbackIcon: Icons.photo_camera_outlined,
                isFavorite: isSaved,
                onFavoriteTap: () {
                  ref.read(favoritesProvider.notifier).toggle(place.id);
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
        border: Border.all(color: AppColors.border),
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
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          if (place.address.isNotEmpty) ...[
            _InfoRow(
              icon: Icons.location_on_outlined,
              label: 'Address',
              value: place.address,
            ),
            const Divider(height: 20),
          ],
          if (place.timings.isNotEmpty) ...[
            _InfoRow(
              icon: Icons.schedule_outlined,
              label: 'Timings',
              value: place.timings,
            ),
            const Divider(height: 20),
          ],
          if (place.entryFee.isNotEmpty)
            _InfoRow(
              icon: Icons.confirmation_number_outlined,
              label: 'Entry',
              value: place.entryFee,
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 9),
        SizedBox(
          width: 68,
          child: Text(label, style: AppTypography.caption),
        ),
        Expanded(child: Text(value, style: AppTypography.bodyStrong)),
      ],
    );
  }
}
