import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/share_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_launcher.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/badges.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/collapsing_detail_header.dart';
import '../../../core/widgets/photo_viewer.dart';
import '../../../core/widgets/states_view.dart';
import '../../../domain/models/business.dart';
import '../../../domain/models/menu_item.dart';
import '../../../domain/models/review.dart';
import '../../../providers/app_providers.dart';

/// Business detail page — works for restaurants, doctors, hotels, salons…
/// Category-specific sections render from the same [Business] model.
class BusinessDetailScreen extends ConsumerWidget {
  const BusinessDetailScreen({super.key, required this.businessId});

  final String businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessAsync = ref.watch(businessByIdProvider(businessId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: businessAsync.when(
        data: (business) {
          if (business == null) {
            return const _MissingBusiness();
          }
          return BusinessDetailBody(business: business);
        },
        loading: () => StatesView.loading(message: 'Loading details…'),
        error: (e, _) => StatesView.error(
          message: 'Could not load this business.',
          onRetry: () => ref.invalidate(businessByIdProvider(businessId)),
        ),
      ),
    );
  }
}

class _MissingBusiness extends StatelessWidget {
  const _MissingBusiness();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        const BackButton(),
        Expanded(
          child: StatesView.empty(
            icon: Icons.storefront_outlined,
            message: 'This listing is no longer available.',
          ),
        ),
      ],
    );
  }
}

class BusinessDetailBody extends ConsumerStatefulWidget {
  const BusinessDetailBody({super.key, required this.business});

  final Business business;

  @override
  ConsumerState<BusinessDetailBody> createState() => _BusinessDetailBodyState();
}

class _BusinessDetailBodyState extends ConsumerState<BusinessDetailBody> {
  int _photoIndex = 0;

  Business get business => widget.business;

  void _openPhotoViewer(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            PhotoViewerScreen(imageUrls: business.images, initialIndex: index),
      ),
    );
  }

  void _toggleFavorite() {
    ref
        .read(favoritesProvider.notifier)
        .toggle(business.id, uuid: business.uuid);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ref.read(favoritesProvider).contains(business.id)
              ? 'Added to favorites'
              : 'Removed from favorites',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDoctor = business.kind == BusinessKind.doctor;
    final isHotel = business.kind == BusinessKind.hotel;
    final isFavorite = ref.watch(favoritesProvider).contains(business.id);

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              // ── Immersive collapsing hero (photos · back · heart · share)
              CollapsingDetailHeader(
                title: business.name,
                image: business.images.firstOrNull ?? '',
                imageList: business.images,
                fallbackIcon: Icons.storefront_outlined,
                isFavorite: isFavorite,
                onFavoriteTap: _toggleFavorite,
                onShareTap: () => ShareService.shareBusiness(business),
                onImageTap: (index) => _openPhotoViewer(index),
                badge: business.imageBadges.firstOrNull != null
                    ? ImageBadgeRow(
                        badges: [
                          if (business.isVerified) 'VERIFIED',
                          ...business.imageBadges.where((b) => b != 'VERIFIED'),
                        ],
                      )
                    : null,
                onPageChanged: (i) => setState(() => _photoIndex = i),
                pageIndex: _photoIndex,
              ),

              SliverPadding(
                // 18px breathing room under the hero — the title needs air.
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                sliver: SliverList.list(
                  children: [
                    // ── Header block ─────────────────────────────────
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                business.name,
                                style: AppTypography.headline.copyWith(
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            if (business.isVerified) const VerifiedBadge(),
                            const SizedBox(width: 7),
                            OpenStatusPill(
                              isOpen: business.isOpen,
                              closedText: 'Opens at 11:00 AM',
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            RatingPill.green(rating: business.ratingLabel),
                            const SizedBox(width: 6),
                            Text(
                              '${business.ratingCountLabel} ratings',
                              style: AppTypography.label,
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.location_on_outlined,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                '${business.distanceLabel} km · ${business.area}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.label,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          isDoctor
                              ? '${business.qualification ?? ''} · ${business.experienceYears ?? 0} yrs exp'
                              : business.tagline,
                          style: AppTypography.caption.copyWith(
                            fontSize: 12.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),

                    // ── Action row ───────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.only(top: 13),
                      child: _ActionRow(business: business),
                    ),

                    // ── Highlights ───────────────────────────────────
                    if (business.featureChips.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: _HighlightsRow(chips: business.featureChips),
                      ),

                    // ── Doctor specifics ─────────────────────────────
                    if (isDoctor)
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: _DoctorInfoCard(business: business),
                      ),

                    // ── About ────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('About', style: AppTypography.titleSm),
                          const SizedBox(height: 5),
                          Text(business.description, style: AppTypography.body),
                        ],
                      ),
                    ),

                    // ── Location & policies / contact summary ────────
                    Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: _InfoCard(business: business),
                    ),

                    // ── Hotel amenities ─────────────────────────────
                    if (isHotel)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: _AmenitiesCard(amenities: business.amenities),
                      ),

                    // ── Menu specialties ─────────────────────────────
                    if (business.menu.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.only(top: 18, bottom: 10),
                        child: _MenuHeader(),
                      ),
                      ...business.menu.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _MenuItemRow(item: item),
                        ),
                      ),
                    ],

                    // ── Reviews ──────────────────────────────────────
                    if (business.reviews.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 10),
                        child: Row(
                          children: [
                            Text('Reviews', style: AppTypography.titleSm),
                            const SizedBox(width: 6),
                            RatingPill.soft(
                              rating: business.ratingLabel,
                              count: business.ratingCountLabel,
                            ),
                            const Spacer(),
                            Text(
                              'View All (${business.reviews.length})',
                              style: AppTypography.label.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...business.reviews.map(
                        (review) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ReviewCard(review: review),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Sticky booking bar ─────────────────────────────────────
        Container(
          padding: EdgeInsets.fromLTRB(
            16,
            11,
            16,
            11 + MediaQuery.paddingOf(context).bottom,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      switch (business.kind) {
                        BusinessKind.hotel =>
                          business.priceText ?? 'Best rates',
                        BusinessKind.doctor =>
                          'Consultation ${business.consultationFee ?? ''}',
                        _ => 'Table for 2 · Free',
                      },
                      style: AppTypography.bodyStrong.copyWith(fontSize: 12.5),
                    ),
                    Text(switch (business.kind) {
                      BusinessKind.hotel => 'incl. taxes & breakfast',
                      BusinessKind.doctor => business.timings ?? '',
                      _ => 'No booking fee · Instant confirm',
                    }, style: AppTypography.label.copyWith(fontSize: 10)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(switch (business.kind) {
                      BusinessKind.hotel => 'Room availability coming soon',
                      BusinessKind.doctor => 'Appointment booking coming soon',
                      _ => 'Table request sent to ${business.name}',
                    }),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    switch (business.kind) {
                      BusinessKind.hotel => 'Check Availability',
                      BusinessKind.doctor => 'Book Appointment',
                      _ => 'Book a Table',
                    },
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
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

/// ── Action row: Call · WhatsApp · Directions · Website ─────────────────
class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.business});

  final Business business;

  Future<void> _whatsapp(BuildContext context) async {
    final ok = await AppLauncher.whatsapp(
      business.whatsapp,
      message:
          'Hi ${business.name}, I found you on CityBee and have a question.',
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('WhatsApp is not available on this device.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final actions = <_ActionData>[
      _ActionData(
        AppIcons.callAsset,
        'Call',
        () => AppLauncher.call(business.phone),
      ),
      _ActionData(AppIcons.whatsappAsset, 'WhatsApp', () => _whatsapp(context)),
      _ActionData(
        AppIcons.directionsAsset,
        'Directions',
        () => AppLauncher.directions(
          business.latitude,
          business.longitude,
          label: business.name,
        ),
      ),
      if (business.website != null)
        _ActionData(
          Icons.language_rounded,
          'Website',
          () => AppLauncher.openWebsite(business.website!),
        ),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        // Flat border instead of a shadow: shadows bleed upward over the
        // hero's bottom edge and read as an orange glow behind the carousel.
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var i = 0; i < actions.length; i++)
            _ActionButton(action: actions[i]),
        ],
      ),
    );
  }
}

class _ActionData {
  const _ActionData(this.icon, this.label, this.onTap);

  /// SVG asset path (Call/WhatsApp/Directions) or IconData (Website).
  final Object icon;
  final String label;
  final VoidCallback onTap;
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action});

  final _ActionData action;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: action.icon is String
                    ? AppIcons.action(action.icon as String, size: 20)
                    : Icon(
                        action.icon as IconData,
                        size: 19,
                        color: AppColors.primary,
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              action.label,
              style: AppTypography.label.copyWith(
                fontSize: 10.5,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ── Highlights chips row ───────────────────────────────────────────────
class _HighlightsRow extends StatelessWidget {
  const _HighlightsRow({required this.chips});

  final List<String> chips;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Highlights', style: AppTypography.titleSm),
        const SizedBox(height: 8),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: chips
              .map(
                (chip) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: AppShadows.card,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 13,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        chip,
                        style: AppTypography.body.copyWith(fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

/// ── Doctor specifics ───────────────────────────────────────────────────
class _DoctorInfoCard extends StatelessWidget {
  const _DoctorInfoCard({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.school_outlined,
            label: 'Qualification',
            value: business.qualification ?? '-',
          ),
          const Divider(height: 18),
          _InfoRow(
            icon: Icons.work_history_outlined,
            label: 'Experience',
            value: '${business.experienceYears ?? 0} years',
          ),
          const Divider(height: 18),
          _InfoRow(
            icon: Icons.payments_outlined,
            label: 'Fee',
            value: business.consultationFee ?? '-',
          ),
          const Divider(height: 18),
          _InfoRow(
            icon: Icons.schedule_outlined,
            label: 'Timings',
            value: business.timings ?? business.openingHours,
          ),
        ],
      ),
    );
  }
}

/// ── Hotel amenities ────────────────────────────────────────────────────
class _AmenitiesCard extends StatelessWidget {
  const _AmenitiesCard({required this.amenities});

  final List<String> amenities;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Amenities', style: AppTypography.titleSm),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(15),
            boxShadow: AppShadows.card,
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 9,
            children: amenities
                .map(
                  (amenity) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        amenity,
                        style: AppTypography.body.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

/// ── Address / hours info card ──────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    final hours = business.openingHours.isNotEmpty
        ? business.openingHours
        : business.timings ?? 'Hours not available';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Location & Policies', style: AppTypography.titleSm),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 13),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _RoundInfoIcon(icon: Icons.location_on_rounded),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ADDRESS',
                          style: AppTypography.label.copyWith(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          business.address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyStrong.copyWith(
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _MapPill(
                    onTap: () => AppLauncher.directions(
                      business.latitude,
                      business.longitude,
                      label: business.name,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, color: AppColors.divider),
              Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 19,
                    color: AppColors.openGreen,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      hours,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body.copyWith(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoundInfoIcon extends StatelessWidget {
  const _RoundInfoIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: const BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: AppColors.primary),
    );
  }
}

class _MapPill extends StatelessWidget {
  const _MapPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.directions_rounded,
              size: 17,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text('Map', style: AppTypography.bodyStrong.copyWith(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

/// One row inside the Contact Details card: icon chip + text + optional
/// trailing action. Tappable when [onTap] is set.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

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
        SizedBox(width: 84, child: Text(label, style: AppTypography.caption)),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodyStrong.copyWith(fontSize: 12.5),
          ),
        ),
      ],
    );
  }
}

/// ── Menu ───────────────────────────────────────────────────────────────
class _MenuHeader extends StatelessWidget {
  const _MenuHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Menu Specialties', style: AppTypography.titleSm),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.verifiedGreenSoft,
            borderRadius: BorderRadius.circular(7),
          ),
          child: const Text(
            'Updated Daily',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: AppColors.verifiedGreen,
            ),
          ),
        ),
        const Spacer(),
        Text(
          'Full Menu',
          style: AppTypography.label.copyWith(color: AppColors.primary),
        ),
        const SizedBox(width: 2),
        const Icon(
          Icons.chevron_right_rounded,
          size: 15,
          color: AppColors.primary,
        ),
      ],
    );
  }
}

class _MenuItemRow extends StatelessWidget {
  const _MenuItemRow({required this.item});

  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: AppImage(url: item.image, width: 56, height: 56),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    VegDot(isVeg: item.isVeg),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyStrong.copyWith(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(item.price, style: AppTypography.bodyStrong),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${item.name} added to your order'),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Text(
                          'ADD',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ── Review card ────────────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: AppColors.primarySoft,
                child: Text(
                  review.author.substring(0, 1),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.author, style: AppTypography.bodyStrong),
                    Text(
                      review.authorMeta,
                      style: AppTypography.label.copyWith(fontSize: 10.5),
                    ),
                  ],
                ),
              ),
              RatingPill.green(rating: review.rating.toStringAsFixed(0)),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            review.text,
            style: AppTypography.caption.copyWith(fontSize: 11.5),
          ),
          const SizedBox(height: 7),
          Text(
            review.timeAgo,
            style: AppTypography.label.copyWith(fontSize: 10.5),
          ),
        ],
      ),
    );
  }
}
