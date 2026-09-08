import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_launcher.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/map_preview.dart';
import '../../../core/widgets/states_view.dart';
import '../../../domain/models/business.dart';
import '../../../domain/models/offer.dart';
import '../../../providers/app_providers.dart';

/// Full offer details: hero image, coupon, business info, validity,
/// terms, map and call/WhatsApp actions.
class OfferDetailScreen extends ConsumerWidget {
  const OfferDetailScreen({super.key, required this.offerId});

  final String offerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offerAsync = ref.watch(offerByIdProvider(offerId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: offerAsync.when(
        data: (offer) {
          if (offer == null) {
            return const _MissingOffer();
          }
          final businessAsync = ref.watch(businessByIdProvider(offer.businessId));
          final business = businessAsync.valueOrNull;
          return _OfferDetailBody(offer: offer, business: business);
        },
        loading: () => StatesView.loading(message: 'Loading offer…'),
        error: (e, _) => StatesView.error(
          message: 'Could not load this offer.',
          onRetry: () => ref.invalidate(offerByIdProvider(offerId)),
        ),
      ),
    );
  }
}

class _MissingOffer extends StatelessWidget {
  const _MissingOffer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        const BackButton(),
        Expanded(
          child: StatesView.empty(
            icon: Icons.local_offer_outlined,
            message: 'This offer is no longer available.',
          ),
        ),
      ],
    );
  }
}

class _OfferDetailBody extends StatelessWidget {
  const _OfferDetailBody({required this.offer, required this.business});

  final Offer offer;
  final Business? business;

  void _copyCoupon(BuildContext context) {
    Clipboard.setData(ClipboardData(text: offer.couponCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Coupon code ${offer.couponCode} copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero image with back + share ─────────────────────
                SizedBox(
                  height: 235,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppImage(url: offer.image, fallbackIcon: Icons.local_offer_rounded),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0, 0.45, 1],
                            colors: [Color(0x66000000), Colors.transparent, Color(0x99000000)],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        left: 12,
                        child: CircleIconButton(
                          icon: Icons.arrow_back,
                          onTap: () => context.pop(),
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
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 14,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.badgeOrange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                offer.badgeText,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              offer.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${offer.badgeText} ${offer.subtitle}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Coupon card ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: _CouponCard(offer: offer, onCopy: () => _copyCoupon(context)),
                ),

                // ── Description ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('About this offer', style: AppTypography.titleSm),
                      const SizedBox(height: 6),
                      Text(offer.description, style: AppTypography.body),
                      const SizedBox(height: 14),
                      _ValidityRow(offer: offer),
                    ],
                  ),
                ),

                // ── Business block ──────────────────────────────────
                if (business != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                    child: _BusinessBlock(business: business!),
                  ),
              ],
            ),
          ),
        ),

        // ── Sticky bottom actions ──────────────────────────────────
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
                  label: 'Call Business',
                  onTap: () => AppLauncher.call(business?.phone ?? ''),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CardActionButton(
                  label: 'WhatsApp',
                  filled: true,
                  onTap: () => AppLauncher.whatsapp(
                    business?.whatsapp ?? '',
                    message: 'Hi, I want to claim offer ${offer.couponCode} from LocalGo.',
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

class _CouponCard extends StatelessWidget {
  const _CouponCard({required this.offer, required this.onCopy});

  final Offer offer;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('COUPON CODE', style: AppTypography.eyebrow),
                    const SizedBox(height: 5),
                    Text(
                      offer.couponCode,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onCopy,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Copy Code',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(Icons.event_available_outlined, size: 15, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(offer.validityText, style: AppTypography.bodyStrong),
              ),
              if (offer.leftCount != null)
                Text(
                  'Only ${offer.leftCount} left',
                  style: AppTypography.label.copyWith(
                    color: AppColors.brandRed,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ValidityRow extends StatelessWidget {
  const _ValidityRow({required this.offer});

  final Offer offer;

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
        children: [
          _TermsRow(label: 'Valid till', value: offer.validityText),
          const Divider(height: 18),
          _TermsRow(label: 'Category', value: offer.categoryTag),
          const Divider(height: 18),
          const _TermsRow(
            label: 'How to redeem',
            value: 'Show this screen or mention the code at billing',
          ),
        ],
      ),
    );
  }
}

class _TermsRow extends StatelessWidget {
  const _TermsRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(label, style: AppTypography.caption),
        ),
        Expanded(child: Text(value, style: AppTypography.bodyStrong)),
      ],
    );
  }
}

class _BusinessBlock extends StatelessWidget {
  const _BusinessBlock({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AppImage(url: business.images.first, width: 54, height: 54),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            business.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.titleSm,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified, size: 14, color: AppColors.verifiedGreen),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${business.tagline} · ${business.area}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          MapPreview(
            latitude: business.latitude,
            longitude: business.longitude,
            height: 120,
            pinLabel: business.name,
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              CardActionButton(
                label: 'View Business',
                filled: true,
                onTap: () => context.go('/business/${business.id}'),
              ),
              const SizedBox(width: 8),
              CardActionButton(
                label: 'Get Directions',
                onTap: () => AppLauncher.directions(
                  business.latitude,
                  business.longitude,
                  label: business.name,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
