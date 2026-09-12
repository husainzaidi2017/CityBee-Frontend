import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/pressable.dart';
import '../../../core/widgets/states_view.dart';
import '../../../domain/models/owner_business.dart';
import '../../../providers/app_providers.dart';
import 'management_screens.dart';
import '../../../core/widgets/app_icons.dart';
import 'package:iconify_flutter/iconify_flutter.dart';

/// My Business tab body: 1 approved business → dashboard directly;
/// multiple → selector list first. Backend-driven, never hardcoded.
class MyBusinessTab extends ConsumerWidget {
  const MyBusinessTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businesses = ref.watch(myBusinessesProvider);

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Text('My Business', style: AppTypography.headline),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: businesses.when(
                data: (list) {
                  final approved = list.where((b) => b.isApproved).toList();
                  if (approved.length == 1) {
                    // Single approved business → dashboard directly,
                    // WITHOUT its own app bar (the tab already has one).
                    return OwnerBusinessDashboardBody(
                      businessId: approved.first.id,
                      details: ref.watch(
                        ownerBusinessDetailsProvider(approved.first.id),
                      ),
                    );
                  }
                  return _BusinessSelector(businesses: list);
                },
                loading: () =>
                    StatesView.loading(message: 'Loading your businesses…'),
                error: (e, _) => StatesView.error(
                  message:
                      'Could not load your businesses. Check your connection.',
                  onRetry: () => ref.invalidate(myBusinessesProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Business selector for owners with multiple businesses.
class _BusinessSelector extends ConsumerWidget {
  const _BusinessSelector({required this.businesses});

  final List<OwnerBusiness> businesses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final approved = businesses.where((b) => b.isApproved).toList();
    final others = businesses.where((b) => !b.isApproved).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        const Text('Choose a business to manage', style: AppTypography.caption),
        const SizedBox(height: 12),
        for (final b in [...approved, ...others])
          Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: _BusinessRow(business: b),
          ),
        const SizedBox(height: 8),
        // Multiple businesses → also offer adding another.
        _AddAnotherCard(onTap: () => _openListingFlow(context)),
      ],
    );
  }

  void _openListingFlow(BuildContext context) {
    context.push('/list-business');
  }
}

class _BusinessRow extends StatelessWidget {
  const _BusinessRow({required this.business});

  final OwnerBusiness business;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (business.status) {
      'approved' => AppColors.openGreen,
      'pending' || 'draft' => AppColors.starAmber,
      _ => AppColors.brandRed,
    };
    final statusLabel = switch (business.status) {
      'approved' => 'LIVE',
      'pending' => 'PENDING',
      'draft' => 'DRAFT',
      'rejected' => 'NEEDS CHANGES',
      'suspended' => 'SUSPENDED',
      _ => business.status.toUpperCase(),
    };

    return Pressable(
      onTap: business.isApproved
          ? () => context.push('/my-business/${business.id}')
          : null,
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 60,
                height: 60,
                child: AppImage(
                  url: business.primaryImage,
                  fallbackIcon: AppUiIcons.storefront_outline,
                ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleSm,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (business.kind.isNotEmpty) _kindLabel(business.kind),
                      if (business.area.isNotEmpty) business.area,
                      if (business.cityName.isNotEmpty) business.cityName,
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (business.isApproved) ...[
                        Iconify(
                          AppUiIcons.star,
                          size: 11,
                          color: AppColors.starAmber,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${business.rating}',
                          style: AppTypography.label.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${business.activeOffers} offers',
                          style: AppTypography.label,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (business.isApproved)
              Iconify(
                AppUiIcons.chevron_right,
                color: AppColors.textMuted, size: 14),
          ],
        ),
      ),
    );
  }

  String _kindLabel(String kind) {
    final text = kind.replaceAll('_', ' ').trim();
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

class _AddAnotherCard extends StatelessWidget {
  const _AddAnotherCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Iconify(
              AppUiIcons.store_plus,
              size: 15,
              color: AppColors.primary,
            ),
            SizedBox(width: 8),
            Text(
              'Add Another Business',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Standalone dashboard PAGE (pushed route) — wrapped in a Scaffold with
/// an app bar so it renders on its own (fixes the black screen when owners
/// with multiple businesses tap one in the selector).
class OwnerBusinessDashboardPage extends ConsumerWidget {
  const OwnerBusinessDashboardPage({super.key, required this.businessId});

  final String businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('My Business', style: AppTypography.title),
        leading: IconButton(
          icon: AppUiIcons.show(AppUiIcons.back, size: 15),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: OwnerBusinessDashboardBody(
        businessId: businessId,
        details: ref.watch(ownerBusinessDetailsProvider(businessId)),
      ),
    );
  }
}

/// Dashboard content without its own Scaffold — embedded in the tab for
/// single-business owners (no double header) and inside the Page above.
class OwnerBusinessDashboardBody extends ConsumerWidget {
  const OwnerBusinessDashboardBody({
    super.key,
    required this.businessId,
    required this.details,
  });

  final String businessId;
  final AsyncValue<OwnerBusinessDetails?> details;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return details.when(
      data: (business) {
        if (business == null) {
          return StatesView.empty(
            icon: AppUiIcons.storefront_outline,
            message: 'This business is no longer available.',
          );
        }
        return _Dashboard(details: business);
      },
      loading: () => StatesView.loading(message: 'Loading dashboard…'),
      error: (e, _) => StatesView.error(
        message: 'Could not load this business. Please try again.',
        onRetry: () => ref.invalidate(ownerBusinessDetailsProvider(businessId)),
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.details});

  final OwnerBusinessDetails details;

  @override
  Widget build(BuildContext context) {
    final isRestaurant = details.kind == 'restaurant';
    final isDoctor = details.kind == 'doctor';
    final isHotel = details.kind == 'hotel';
    final isSalon = details.kind == 'salon' || details.kind == 'service';
    final activeOffers = details.offers
        .where((o) => o.phase == 'active')
        .length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        // ── Summary card ─────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 68,
                      height: 68,
                      child: AppImage(
                        url:
                            details.images
                                .where((i) => i.isPrimary)
                                .firstOrNull
                                ?.url ??
                            (details.images.isNotEmpty
                                ? details.images.first.url
                                : ''),
                        fallbackIcon: AppUiIcons.storefront_outline,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          details.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.titleSm,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          [
                            // Business KIND (e.g. Salon, Hotel, Doctor) —
                            // what the owner set, not the category slug.
                            details.kind.isNotEmpty
                                ? details.kind[0].toUpperCase() +
                                      details.kind.substring(1)
                                : null,
                            if (details.cityName.isNotEmpty) details.cityName,
                          ].whereType<String>().join(' · '),
                          style: AppTypography.caption,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _StatusChip(status: details.status),
                            if (details.isVerified) ...[
                              const SizedBox(width: 6),
                              Iconify(
                                AppUiIcons.check_decagram,
                                size: 15,
                                color: AppColors.verifiedGreen,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (details.status != 'approved') ...[
                const SizedBox(height: 10),
                _StatusNotice(details: details),
              ],
              const SizedBox(height: 12),
              // Quick actions
              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon: AppUiIcons.plus_circle_outline,
                      label: 'Add Offer',
                      onTap: () => _openOffers(context),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _QuickAction(
                      icon: AppUiIcons.pencil_outline,
                      label: 'Edit Profile',
                      onTap: () => _openEditProfile(context),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _QuickAction(
                      icon: AppUiIcons.camera_outline,
                      label: 'Photos',
                      onTap: () => _openPhotos(context),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _QuickAction(
                      icon: AppUiIcons.eye_outline,
                      label: 'View Profile',
                      onTap: () => _openPublicProfile(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ── Manage (one merged section: business + category + offers) ──
        _ManageSection(
          title: 'Manage',
          tiles: [
            _ManageTile(
              AppUiIcons.information_outline,
              'Business Information',
              _openEditProfile,
            ),
            _ManageTile(AppUiIcons.clock_outline, 'Business Hours', _openHours),
            _ManageTile(
              AppUiIcons.image_multiple_outline,
              'Photos (${details.images.length})',
              _openPhotos,
            ),
            if (isRestaurant)
              _ManageTile(AppUiIcons.silverware_fork_knife, 'Menu', _openMenu),
            if (isRestaurant)
              _ManageTile(
                AppUiIcons.food,
                'Restaurant Details',
                _openRestaurantDetails,
              ),
            if (isDoctor)
              _ManageTile(
                AppUiIcons.medical_bag,
                'Professional Details',
                _openDoctorDetails,
              ),
            if (isHotel)
              _ManageTile(
                AppUiIcons.bed_outline,
                'Hotel Details',
                _openHotelDetails,
              ),
            if (isSalon)
              _ManageTile(
                AppUiIcons.palette_outline,
                'Services',
                _openServices,
              ),
            _ManageTile(
              AppUiIcons.comment_edit_outline,
              'Reviews (${details.reviewCount})',
              _openReviews,
            ),
            _ManageTile(
              AppUiIcons.tag_outline,
              'Offers ($activeOffers)',
              _openOffers,
            ),
            _ManageTile(
              AppUiIcons.plus_circle_outline,
              'Create New Offer',
              _openOffers,
            ),
          ],
        ),
      ],
    );
  }

  void _openPublicProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PublicProfileRedirect(slug: details.slug),
      ),
    );
  }

  void _openEditProfile(BuildContext context) =>
      _push(context, EditBusinessProfileScreen(details: details));
  void _openHours(BuildContext context) =>
      _push(context, BusinessHoursScreen(details: details));
  void _openPhotos(BuildContext context) =>
      _push(context, BusinessPhotosScreen(details: details));
  void _openReviews(BuildContext context) =>
      _push(context, BusinessReviewsScreen(details: details));
  void _openMenu(BuildContext context) =>
      _push(context, RestaurantMenuScreen(details: details));
  void _openRestaurantDetails(BuildContext context) =>
      _push(context, RestaurantDetailsScreen(details: details));
  void _openDoctorDetails(BuildContext context) =>
      _push(context, DoctorDetailsScreen(details: details));
  void _openHotelDetails(BuildContext context) =>
      _push(context, HotelDetailsScreen(details: details));
  void _openServices(BuildContext context) =>
      _push(context, BusinessServicesScreen(details: details));
  void _openOffers(BuildContext context) =>
      _push(context, ManageOffersScreen(details: details));

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

/// Status chip: LIVE / PENDING / NEEDS CHANGES / SUSPENDED.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'approved' => ('LIVE', AppColors.openGreen),
      'pending' => ('PENDING REVIEW', AppColors.starAmber),
      'rejected' => ('NEEDS CHANGES', AppColors.brandRed),
      'suspended' => ('SUSPENDED', AppColors.brandRed),
      _ => (status.toUpperCase(), AppColors.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _StatusNotice extends StatelessWidget {
  const _StatusNotice({required this.details});

  final OwnerBusinessDetails details;

  @override
  Widget build(BuildContext context) {
    final (title, body) = switch (details.status) {
      'pending' => (
        'Under review',
        'Your listing is being reviewed. It will go live once approved.',
      ),
      'rejected' => (
        'Your listing needs changes',
        details.rejectionReason.isNotEmpty
            ? details.rejectionReason
            : 'Please review your business details and resubmit.',
      ),
      'suspended' => (
        'Listing not visible',
        'Your public listing is currently not visible to customers.',
      ),
      _ => ('', ''),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.bodyStrong),
          const SizedBox(height: 3),
          Text(body, style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.95,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Iconify(icon, size: 17, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label.copyWith(
                color: AppColors.textPrimary,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManageTile {
  const _ManageTile(this.icon, this.label, this.onTap);
  final String icon;
  final String label;
  final void Function(BuildContext context) onTap;
}

class _ManageSection extends StatelessWidget {
  const _ManageSection({required this.title, required this.tiles});

  final String title;
  final List<_ManageTile> tiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.titleSm),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    indent: 56,
                    color: AppColors.divider,
                  ),
                ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                  leading: Iconify(
                    tiles[i].icon,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  title: Text(tiles[i].label, style: AppTypography.bodyStrong),
                  trailing: Iconify(
                    AppUiIcons.chevron_right,
                    size: 19,
                    color: AppColors.textMuted,
                  ),
                  onTap: () => tiles[i].onTap(context),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Opens the SAME public business detail screen customers see.
class _PublicProfileRedirect extends StatelessWidget {
  const _PublicProfileRedirect({required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    // Delegates to the existing consumer route on the next frame so the
    // push happens outside build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pop();
      context.push('/business/$slug');
    });
    return const SizedBox.shrink();
  }
}
