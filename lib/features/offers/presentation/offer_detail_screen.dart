import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/share_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_launcher.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/collapsing_detail_header.dart';
import '../../../core/widgets/photo_viewer.dart';
import '../../../core/widgets/map_preview.dart';
import '../../../core/widgets/states_view.dart';
import '../../../domain/models/business.dart';
import '../../../domain/models/offer.dart';
import '../../../providers/app_providers.dart';

/// Full offer details: immersive hero, offer summary, business info,
/// validity, map and call/WhatsApp actions.
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

void _openViewer(BuildContext context, String imageUrl) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => PhotoViewerScreen(imageUrls: [imageUrl]),
    ),
  );
}

class _OfferDetailBody extends StatelessWidget {
  const _OfferDetailBody({required this.offer, required this.business});

  final Offer offer;
  final Business? business;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              // ── Immersive collapsing hero (back · favorite · share) ──
              CollapsingDetailHeader(
                title: offer.title,
                image: offer.image,
                fallbackIcon: Icons.local_offer_rounded,
                onShareTap: () => ShareService.shareOffer(offer),
                onImageTap: (index) => _openViewer(context, offer.image),
                badge: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                sliver: SliverList.list(
                  children: [
                    // ── Offer summary (badge + title + subtitle) ──────
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.title,
                          style: AppTypography.headline.copyWith(fontSize: 20),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${offer.badgeText} ${offer.subtitle}',
                          style: AppTypography.caption.copyWith(
                            fontSize: 12.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),

                    // ── Description + validity ────────────────────────
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
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

                    // ── Business block ────────────────────────────────
                    if (business != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: _BusinessBlock(business: business!),
                      ),
                  ],
                ),
              ),
            ],
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
                  onTap: () async {
                    final ok = await AppLauncher.whatsapp(
                      business?.whatsapp ?? '',
                      message:
                          'Hi, I saw the "${offer.title}" offer on CityBee and would like to know more.',
                    );
                    if (!ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('WhatsApp is not available on this device.')),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
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
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          _TermsRow(label: 'Valid till', value: offer.validityText),
          const Divider(height: 18),
          _TermsRow(label: 'Category', value: offer.categoryTag),
          const Divider(height: 18),
          const _TermsRow(
            label: 'How to redeem',
            value: 'Show this screen at billing to get the discount',
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
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AppImage(url: business.images.firstOrNull ?? '', width: 54, height: 54),
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
          // Contact Details — same labelled table as every record page.
          _ContactTable(
            rows: [
              _Entry(
                'ADDRESS',
                business.address,
                action: 'View Map',
                onTap: () => AppLauncher.directions(
                    business.latitude, business.longitude),
              ),
              if (business.phone.isNotEmpty)
                _Entry(
                  'PHONE',
                  business.phone,
                  action: 'Call',
                  onTap: () => AppLauncher.call(business.phone),
                ),
              if (business.whatsapp.isNotEmpty)
                _Entry(
                  'WHATSAPP',
                  business.whatsapp,
                  action: 'Chat',
                  onTap: () => AppLauncher.whatsapp(business.whatsapp),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Labelled entry of the Contact Details table.
class _Entry {
  const _Entry(this.label, this.value, {this.action, this.onTap});

  final String label;
  final String value;
  final String? action;
  final VoidCallback? onTap;
}

/// Contact Details table: grey uppercase label column + value — matching
/// every other record page.
class _ContactTable extends StatelessWidget {
  const _ContactTable({required this.rows});

  final List<_Entry> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              onTap: rows[i].onTap,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 96,
                    color: AppColors.background,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    child: Text(
                      rows[i].label,
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
                        rows[i].value,
                        style: AppTypography.body.copyWith(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                  if (rows[i].action != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Text(
                        rows[i].action!,
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
    );
  }
}
