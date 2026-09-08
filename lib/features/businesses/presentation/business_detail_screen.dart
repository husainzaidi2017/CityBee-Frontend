import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_launcher.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/badges.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/map_preview.dart';
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

class BusinessDetailBody extends StatefulWidget {
  const BusinessDetailBody({super.key, required this.business});

  final Business business;

  @override
  State<BusinessDetailBody> createState() => _BusinessDetailBodyState();
}

class _BusinessDetailBodyState extends State<BusinessDetailBody> {
  final _photoController = PageController();
  int _photoIndex = 0;

  Business get business => widget.business;

  void _copyCoupon(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Coupon code $code copied — show it at billing!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDoctor = business.kind == BusinessKind.doctor;
    final isHotel = business.kind == BusinessKind.hotel;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _PhotoCarousel(
                controller: _photoController,
                images: business.images,
                index: _photoIndex,
                onChanged: (i) => setState(() => _photoIndex = i),
                badge: business.imageBadges.firstOrNull,
              ),

              // ── Header block ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 13, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            business.name,
                            style: AppTypography.headline.copyWith(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        if (business.isVerified) const VerifiedBadge(),
                        const SizedBox(width: 7),
                        OpenStatusPill(isOpen: business.isOpen, closedText: 'Opens at 11:00 AM'),
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
                        const Icon(Icons.location_on_outlined,
                            size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 2),
                        Text(
                          '${business.distanceLabel} km · ${business.area}',
                          style: AppTypography.label,
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
              ),

              // ── Action row ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 13, 16, 0),
                child: _ActionRow(business: business),
              ),

              // ── LocalGo deal banner ──────────────────────────────
              if (business.hasCoupon)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 13, 16, 0),
                  child: _DealBanner(
                    code: business.couponCode!,
                    title: business.couponTitle!,
                    subtitle: business.couponSubtitle!,
                    note: business.couponNote,
                    onCopy: () => _copyCoupon(business.couponCode!),
                  ),
                ),

              // ── Highlights ───────────────────────────────────────
              if (business.featureChips.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 15, 16, 0),
                  child: _HighlightsRow(chips: business.featureChips),
                ),

              // ── Doctor / hotel specifics ─────────────────────────
              if (isDoctor)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 15, 16, 0),
                  child: _DoctorInfoCard(business: business),
                ),
              if (isHotel) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 15, 16, 0),
                  child: _AmenitiesCard(amenities: business.amenities),
                ),
              ],

              // ── About ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 15, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('About', style: AppTypography.titleSm),
                    const SizedBox(height: 5),
                    Text(business.description, style: AppTypography.body),
                  ],
                ),
              ),

              // ── Info card ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: _InfoCard(business: business),
              ),

              // ── Menu specialties ─────────────────────────────────
              if (business.menu.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 18, 16, 10),
                  child: _MenuHeader(),
                ),
                ...business.menu.map((item) => Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: _MenuItemRow(item: item),
                    )),
              ],

              // ── Map ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: _LocationSection(business: business),
              ),

              // ── Reviews ──────────────────────────────────────────
              if (business.reviews.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
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
                        style: AppTypography.label.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                ...business.reviews.map((review) => Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: _ReviewCard(review: review),
                    )),
              ],
              const SizedBox(height: 8),
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
                        BusinessKind.hotel => business.priceText ?? 'Best rates',
                        BusinessKind.doctor => 'Consultation ${business.consultationFee ?? ''}',
                        _ => 'Table for 2 · Free',
                      },
                      style: AppTypography.bodyStrong.copyWith(fontSize: 12.5),
                    ),
                    Text(
                      switch (business.kind) {
                        BusinessKind.hotel => 'incl. taxes & breakfast',
                        BusinessKind.doctor => business.timings ?? '',
                        _ => 'No booking fee · Instant confirm',
                      },
                      style: AppTypography.label.copyWith(fontSize: 10),
                    ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x330E6B4F),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
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

/// ── Photo carousel with page dots ──────────────────────────────────────
class _PhotoCarousel extends StatelessWidget {
  const _PhotoCarousel({
    required this.controller,
    required this.images,
    required this.index,
    required this.onChanged,
    this.badge,
  });

  final PageController controller;
  final List<String> images;
  final int index;
  final ValueChanged<int> onChanged;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Stack(
        children: [
          PageView.builder(
            controller: controller,
            itemCount: images.length,
            onPageChanged: onChanged,
            itemBuilder: (context, i) => AppImage(url: images[i]),
          ),
          // Gradient + badges + dots
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 0.55, 1],
                  colors: [Color(0x55000000), Colors.transparent, Color(0x66000000)],
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 12,
            child: CircleIconButton(
              icon: Icons.arrow_back,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),
          Positioned(
            top: 40,
            right: 12,
            child: CircleIconButton(
              icon: Icons.share_outlined,
              onTap: () {},
            ),
          ),
          if (badge != null)
            Positioned(
              top: 40,
              left: 60,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: imageBadgeColor(badge!),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          if (images.length > 1)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < images.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == index ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == index ? Colors.white : Colors.white54,
                        borderRadius: BorderRadius.circular(999),
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

/// ── Action row: Call · WhatsApp · Directions · Website ─────────────────
class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    final actions = <_ActionData>[
      _ActionData(Icons.call_outlined, 'Call', () => AppLauncher.call(business.phone)),
      _ActionData(Icons.chat_bubble_outline_rounded, 'WhatsApp',
          () => AppLauncher.whatsapp(business.whatsapp)),
      _ActionData(Icons.directions_outlined, 'Directions',
          () => AppLauncher.directions(business.latitude, business.longitude, label: business.name)),
      if (business.website != null)
        _ActionData(Icons.language_rounded, 'Website',
            () => AppLauncher.openWebsite(business.website!)),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
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

  final IconData icon;
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
              child: Icon(action.icon, size: 19, color: AppColors.primary),
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

/// ── LocalGo deal banner ────────────────────────────────────────────────
class _DealBanner extends StatelessWidget {
  const _DealBanner({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.onCopy,
    this.note,
  });

  final String code;
  final String title;
  final String subtitle;
  final String? note;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3E8), Color(0xFFFFE8D2)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFF7CBA3)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_offer_rounded, color: Colors.white, size: 21),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyStrong.copyWith(fontSize: 12.5)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: onCopy,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        code,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.copy_rounded, size: 12, color: Colors.white),
                    ],
                  ),
                ),
              ),
              if (note != null) ...[
                const SizedBox(height: 3),
                Text(
                  note!,
                  style: AppTypography.label.copyWith(
                    fontSize: 9,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        ],
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
              .map((chip) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 13, color: AppColors.primary),
                        const SizedBox(width: 5),
                        Text(
                          chip,
                          style: AppTypography.body.copyWith(fontSize: 11.5),
                        ),
                      ],
                    ),
                  ))
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
        border: Border.all(color: AppColors.border),
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
            border: Border.all(color: AppColors.border),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 9,
            children: amenities
                .map((amenity) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, size: 14, color: AppColors.primary),
                        const SizedBox(width: 5),
                        Text(amenity, style: AppTypography.body.copyWith(fontSize: 12)),
                      ],
                    ))
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
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Address',
            value: business.address,
          ),
          const Divider(height: 18),
          _InfoRow(
            icon: Icons.schedule_outlined,
            label: 'Hours',
            value: business.openingHours,
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
          width: 84,
          child: Text(label, style: AppTypography.caption),
        ),
        Expanded(
          child: Text(value, style: AppTypography.bodyStrong.copyWith(fontSize: 12.5)),
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
            color: AppColors.ratingGreenSoft,
            borderRadius: BorderRadius.circular(7),
          ),
          child: const Text(
            'Updated Daily',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppColors.ratingGreen,
            ),
          ),
        ),
        const Spacer(),
        Text(
          'Full Menu',
          style: AppTypography.label.copyWith(color: AppColors.primary),
        ),
        const SizedBox(width: 2),
        const Icon(Icons.chevron_right_rounded, size: 15, color: AppColors.primary),
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
        border: Border.all(color: AppColors.border),
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
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
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

/// ── Location + map section ─────────────────────────────────────────────
class _LocationSection extends StatelessWidget {
  const _LocationSection({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Location', style: AppTypography.titleSm),
        const SizedBox(height: 8),
        MapPreview(
          latitude: business.latitude,
          longitude: business.longitude,
          height: 150,
          pinLabel: business.name,
        ),
      ],
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
        border: Border.all(color: AppColors.border),
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
                    Text(review.authorMeta, style: AppTypography.label.copyWith(fontSize: 9.5)),
                  ],
                ),
              ),
              RatingPill.green(rating: review.rating.toStringAsFixed(0)),
            ],
          ),
          const SizedBox(height: 9),
          Text(review.text, style: AppTypography.caption.copyWith(fontSize: 11.5)),
          const SizedBox(height: 7),
          Text(review.timeAgo, style: AppTypography.label.copyWith(fontSize: 9.5)),
        ],
      ),
    );
  }
}
