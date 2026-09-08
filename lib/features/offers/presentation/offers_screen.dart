import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/badges.dart';
import '../../../core/widgets/chips.dart';
import '../../../core/widgets/search_bar.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/states_view.dart';
import '../../../domain/models/offer.dart';
import '../../../providers/app_providers.dart';

const _tags = ['All', 'Dining', 'Beauty & Salon', 'Fashion', 'Wellness & Health'];

/// Offers tab: coupon search, filter chips, featured hero deal, the
/// "Verified City Deals" list and the community savings banner.
class OffersScreen extends ConsumerStatefulWidget {
  const OffersScreen({super.key});

  @override
  ConsumerState<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends ConsumerState<OffersScreen> {
  String _tag = 'All';
  String _query = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final city = ref.watch(selectedCityProvider);
    final offers = ref.watch(offersByTagProvider(_tag));

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Text(
                'Offers & Deals',
                style: AppTypography.headline,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppSearchBar(
                hint: 'Search coupons, deals, brands…',
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _tags.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, index) => SelectChip(
                  label: index == _tags.length - 1 && index > 2
                      ? '${_tags[index]} +3'
                      : _tags[index],
                  selected: _tags[index] == _tag,
                  onTap: () => setState(() => _tag = _tags[index]),
                ),
              ),
            ),
            const SizedBox(height: 6),

            // ── Content ─────────────────────────────────────────────
            Expanded(
              child: offers.when(
                data: (list) {
                  final filtered = _query.trim().isEmpty
                      ? list
                      : list
                          .where((o) =>
                              o.title.toLowerCase().contains(_query.toLowerCase()) ||
                              o.subtitle.toLowerCase().contains(_query.toLowerCase()))
                          .toList();
                  if (filtered.isEmpty) {
                    return StatesView.empty(
                      message: 'No deals match "$_query".',
                      actionLabel: 'Clear search',
                      onAction: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                    children: [
                      ...filtered.where((o) => o.featured).map(
                            (offer) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: FeaturedOfferCard(offer: offer),
                            ),
                          ),
                      SectionHeader(
                        title: 'Verified ${city.name} Deals',
                        underline: true,
                        subtitle:
                            '${filtered.where((o) => !o.featured).length} live offers · updated today',
                      ),
                      const SizedBox(height: 12),
                      ...filtered
                          .where((o) => !o.featured)
                          .map((offer) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: DealCard(offer: offer),
                              )),
                      const SizedBox(height: 8),
                      const SavingsBanner(),
                    ],
                  );
                },
                loading: () => StatesView.loading(message: 'Fetching live deals…'),
                error: (e, _) => StatesView.error(
                  message: 'Could not load offers. Check your connection.',
                  onRetry: () => ref.invalidate(offersByTagProvider(_tag)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Big featured hero deal card with coupon code and remaining counter.
class FeaturedOfferCard extends StatelessWidget {
  const FeaturedOfferCard({super.key, required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/offer/${offer.id}'),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 148,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppImage(url: offer.image, fallbackIcon: Icons.local_offer_rounded),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xE617211B), Colors.transparent],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.badgeOrange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        offer.badgeText,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    bottom: 12,
                    right: 90,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${offer.badgeText} ${offer.subtitle}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 7),
                        RatingPill.soft(rating: offer.rating.toStringAsFixed(1)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${offer.area} · ${offer.distanceText} · ${offer.validityText}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.label,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _CouponCodeChip(code: offer.couponCode),
                            if (offer.leftCount != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                'Only ${offer.leftCount} Left',
                                style: AppTypography.label.copyWith(
                                  color: AppColors.brandRed,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _ClaimButton(offer: offer),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Standard verified-deal row card.
class DealCard extends StatelessWidget {
  const DealCard({super.key, required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/offer/${offer.id}'),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 96,
              height: 108,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AppImage(url: offer.image, width: 96, height: 108),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.badgeOrange,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        offer.badgeText,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          offer.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.titleSm,
                        ),
                      ),
                      const SizedBox(width: 6),
                      RatingPill.soft(rating: offer.rating.toStringAsFixed(1)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${offer.badgeText} ${offer.subtitle}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 11, color: AppColors.textSecondary),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          '${offer.area} · ${offer.distanceText}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.label.copyWith(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      _CouponCodeChip(code: offer.couponCode),
                      const Spacer(),
                      _ClaimButton(offer: offer),
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

class _CouponCodeChip extends StatelessWidget {
  const _CouponCodeChip({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: code));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Coupon code $code copied')),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              code,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.copy_rounded, size: 12, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _ClaimButton extends StatelessWidget {
  const _ClaimButton({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/offer/${offer.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Text(
          'Claim Coupon',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
    );
  }
}

/// Cream "₹6.8 Lakhs City Saved" community banner.
class SavingsBanner extends ConsumerWidget {
  const SavingsBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final city = ref.watch(selectedCityProvider);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.creamBanner,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF2E3B3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                '₹6.8 Lakhs',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.creamBannerText,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '${city.name} Saved',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.creamBannerText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          const Text(
            'Join LocalGo to unlock deals & city savings.',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFFA98A3C),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Claim Your First Deal',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
