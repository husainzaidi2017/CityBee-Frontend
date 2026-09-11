import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/services/share_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_launcher.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/city_picker_sheet.dart';
import '../../../core/widgets/map_preview.dart';
import '../../../core/widgets/pressable.dart';
import '../../../domain/models/user_profile.dart';
import '../../../providers/app_providers.dart';

/// More tab — the unified Account + More experience.
///
/// The top section shows the signed-in profile (tap → Edit Profile) or a
/// "Sign in or Register" card for guests; everything below is the standard
/// More content available to guests and members alike.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final location = ref.watch(selectedLocationProvider);
    final isLoggedIn = ref.watch(authStateProvider);
    final favorites = ref.watch(favoritesProvider);
    final bookmarkCount = favorites.isEmpty
        ? profile.bookmarkCount
        : favorites.length;
    final submissions =
        ref.watch(mySubmissionsProvider).valueOrNull ?? const [];
    final isOwner =
        ref.watch(ownerSummaryProvider).valueOrNull?.hasApprovedBusiness ??
        false;

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Fixed header: title + account card (always visible) ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('More', style: AppTypography.headline),
                  const SizedBox(height: 8),
                  if (isLoggedIn)
                    _SignedInCard(
                      profile: profile,
                      onEdit: () => context.push('/profile/edit'),
                    )
                  else
                    _GuestCard(onLogin: () => context.push('/login')),
                ],
              ),
            ),

            // ── Scrollable everything else ──────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                children: [
                  if (isLoggedIn) ...[
                    _AccountQuickGrid(
                      profile: profile,
                      bookmarkCount: bookmarkCount,
                      onEdit: () => context.push('/profile/edit'),
                      onFavorites: () => context.push('/favorites'),
                      onCoupons: () => context.go('/offers'),
                    ),
                    const SizedBox(height: 10),
                  ],
                  // ── Submission status (listing requests) ───────────
                  // One simple tile: shows pending/needs-changes badge when
                  // relevant, opens the full Submission Status screen.
                  _SubmissionStatusTile(submissions: submissions),
                  const SizedBox(height: 10),

                  // ── CityBee for Business ──────────────────────────
                  _BusinessPromoCard(
                    onListBusiness: () => _openBusinessListing(context),
                  ),
                  const SizedBox(height: 10),

                  // ── Your city tools ───────────────────────────────────
                  _MenuCard(
                    title: 'Your City Tools',
                    children: [
                      _MenuTile(
                        icon: Icons.location_city_outlined,
                        iconColor: AppColors.primary,
                        iconBg: AppColors.primarySoft,
                        label: 'Change City',
                        value:
                            '${location.displayName}, ${location.state ?? ""}',
                        onTap: () => showCityPickerSheet(context),
                      ),
                      _MenuTile(
                        icon: Icons.favorite_border_rounded,
                        iconColor: AppColors.brandRed,
                        iconBg: const Color(0xFFFDECEC),
                        label: 'My Favorites',
                        value: '$bookmarkCount saved places',
                        onTap: () => context.push('/favorites'),
                      ),
                      // Explore lives here for owners (their bottom tab shows
                      // My Business instead of Explore).
                      if (isOwner)
                        _MenuTile(
                          icon: Icons.explore_outlined,
                          iconColor: AppColors.primary,
                          iconBg: AppColors.primarySoft,
                          label: 'Explore City',
                          value: 'Places, food & heritage',
                          onTap: () => context.push('/explore-city'),
                        ),
                      _MenuTile(
                        icon: Icons.map_outlined,
                        iconColor: AppColors.primary,
                        iconBg: AppColors.primarySoft,
                        label: 'Download City Map',
                        value: 'Offline map of ${location.displayName}',
                        onTap: () => _showMapDownloadSheet(
                          context,
                          location.displayName,
                        ),
                      ),
                      _MenuTile(
                        icon: Icons.settings_outlined,
                        iconColor: AppColors.primary,
                        iconBg: AppColors.primarySoft,
                        label: 'Settings',
                        value: 'Notifications & location',
                        onTap: () => context.push('/settings'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ── Refer & earn ──────────────────────────────────────
                  _MenuCard(
                    title: 'Refer & Earn',
                    children: [
                      _MenuTile(
                        icon: Icons.card_giftcard_rounded,
                        iconColor: AppColors.primary,
                        iconBg: AppColors.primarySoft,
                        label: 'Invite Friends',
                        value: 'Get ₹100 per verified friend',
                        onTap: () => ShareService.shareApp(
                          note:
                              'Join me on ${AppConfig.appName} — we both get ₹100 '
                              'in city savings when you sign up!',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ── Support & about ───────────────────────────────────
                  _MenuCard(
                    title: 'Support & About',
                    children: [
                      _MenuTile(
                        icon: Icons.help_outline_rounded,
                        iconColor: AppColors.primary,
                        iconBg: AppColors.primarySoft,
                        label: 'Help & FAQ',
                        onTap: () => context.push('/faq'),
                      ),
                      _MenuTile(
                        icon: Icons.chat_bubble_outline_rounded,
                        iconColor: AppColors.primary,
                        iconBg: AppColors.primarySoft,
                        label: 'Contact Support',
                        value: 'WhatsApp us anytime',
                        onTap: () => context.push('/support'),
                      ),
                      _MenuTile(
                        icon: Icons.info_outline_rounded,
                        iconColor: AppColors.primary,
                        iconBg: AppColors.primarySoft,
                        label: 'About CityBee',
                        onTap: () => context.push('/about'),
                      ),
                      _MenuTile(
                        icon: Icons.shield_outlined,
                        iconColor: AppColors.primary,
                        iconBg: AppColors.primarySoft,
                        label: 'Privacy Policy',
                        onTap: () => context.push('/privacy'),
                      ),
                      _MenuTile(
                        icon: Icons.description_outlined,
                        iconColor: AppColors.primary,
                        iconBg: AppColors.primarySoft,
                        label: 'Terms & Conditions',
                        onTap: () => context.push('/terms'),
                      ),
                      _MenuTile(
                        icon: Icons.star_border_rounded,
                        iconColor: AppColors.primary,
                        iconBg: AppColors.primarySoft,
                        label: 'Rate CityBee',
                        onTap: () => _openPlayStore(context),
                      ),
                    ],
                  ),

                  // ── Logout / Login ────────────────────────────────────
                  const SizedBox(height: 10),
                  if (isLoggedIn)
                    _LogoutTile(onTap: () => _logout(context, ref))
                  else
                    _LoginTile(onTap: () => context.push('/login')),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'CityBee v1.0.0 · Made in ${location.state ?? location.displayName}',
                      style: AppTypography.label.copyWith(fontSize: 10.5),
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

  // ── Actions ────────────────────────────────────────────────────────────
  void _openBusinessListing(BuildContext context) {
    // In-app List Your Business wizard (guests are gated inside the screen).
    context.push('/list-business');
  }

  Future<void> _openPlayStore(BuildContext context) async {
    final ok = await AppLauncher.openWebsite(AppConfig.playStoreUrl);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Play Store.')),
      );
    }
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Log out?', style: AppTypography.titleSm),
        content: Text(
          'You can continue browsing as a guest and sign in again anytime.',
          style: AppTypography.caption,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(authStateProvider.notifier).logout();
    if (!context.mounted) return;
    // Replace the stack with Login — the app never closes on logout, and
    // "Browse as Guest" on the login screen returns straight to Home.
    context.go('/login');
  }

  Future<void> _showMapDownloadSheet(BuildContext context, String cityName) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Offline City Map', style: AppTypography.title),
              const SizedBox(height: 4),
              Text(
                'Explore $cityName without internet — places, bazaars & streets.',
                style: AppTypography.caption,
              ),
              const SizedBox(height: 8),
              MapPreview(
                latitude: 28.8386,
                longitude: 78.7733,
                height: 140,
                pinLabel: '$cityName · 24 MB',
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '$cityName map download queued (offline maps arrive in a future update)',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Download Map',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ── Signed-in account card: identity, stats and quick links ────────────
class _SignedInCard extends StatelessWidget {
  const _SignedInCard({required this.profile, required this.onEdit});

  final UserProfile profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tappable identity row → Edit Profile (press feedback + ripple).
        Pressable(
          onTap: onEdit,
          ripple: true,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppShadows.card,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2.5),
                  ),
                  child: AppAvatar(url: profile.avatarImage, radius: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.name, style: AppTypography.title),
                      const SizedBox(height: 2),
                      Text(
                        '${profile.email} · ${profile.phone}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.label,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryDark,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.military_tech_rounded,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  profile.levelTitle,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accentSoft,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                profile.topPercent,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _AccountQuickGrid extends StatelessWidget {
  const _AccountQuickGrid({
    required this.profile,
    required this.bookmarkCount,
    required this.onEdit,
    required this.onFavorites,
    required this.onCoupons,
  });

  final UserProfile profile;
  final int bookmarkCount;
  final VoidCallback onEdit;
  final VoidCallback onFavorites;
  final VoidCallback onCoupons;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  value: profile.savedAmount,
                  label: 'Saved',
                  icon: Icons.account_balance_wallet_outlined,
                  background: const Color(0xFFFFFCF7),
                  accent: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatTile(
                  value: '$bookmarkCount',
                  label: 'Bookmarks',
                  icon: Icons.bookmark_border_rounded,
                  background: const Color(0xFFF6FDFF),
                  accent: const Color(0xFF168AAD),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatTile(
                  value: '${profile.reviewsGiven}',
                  label: 'Reviews',
                  icon: Icons.star_border_rounded,
                  background: const Color(0xFFFFFCF4),
                  accent: AppColors.starAmber,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.border),
          ),
          Row(
            children: [
              Expanded(
                child: _QuickLinkButton(
                  icon: Icons.edit_square,
                  label: 'Edit Profile',
                  iconBg: const Color(0xFFF4F6FB),
                  iconColor: AppColors.textPrimary,
                  onTap: onEdit,
                ),
              ),
              Expanded(
                child: _QuickLinkButton(
                  icon: Icons.favorite_border_rounded,
                  label: 'Favorites',
                  iconBg: const Color(0xFFFFF1F6),
                  iconColor: AppColors.brandRed,
                  onTap: onFavorites,
                ),
              ),
              Expanded(
                child: _QuickLinkButton(
                  icon: Icons.sell_outlined,
                  label: 'My Offers',
                  iconBg: const Color(0xFFEFFFF8),
                  iconColor: const Color(0xFF0F9F75),
                  onTap: onCoupons,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ── Guest card: sign-in prompt, browsing stays fully available ─────────
class _GuestCard extends StatelessWidget {
  const _GuestCard({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 26,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sign in or Register', style: AppTypography.titleSm),
                const SizedBox(height: 2),
                Text(
                  'Save favorites, claim coupons & sync across devices.',
                  style: AppTypography.label.copyWith(fontSize: 10.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onLogin,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Login',
                style: AppTypography.bodyStrong.copyWith(
                  color: Colors.white,
                  fontSize: 12.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.icon,
    this.background = AppColors.surface,
    this.accent = AppColors.primary,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color background;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
      ),
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 15, color: accent),
          ),
          const SizedBox(height: 5),
          Text(value, style: AppTypography.titleSm.copyWith(fontSize: 13)),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.label.copyWith(fontSize: 10.5),
          ),
        ],
      ),
    );
  }
}

class _QuickLinkButton extends StatelessWidget {
  const _QuickLinkButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconBg = AppColors.primarySoft,
    this.iconColor = AppColors.primary,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconBg;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      ripple: true,
      borderRadius: BorderRadius.circular(13),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
        child: Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label.copyWith(
                fontSize: 10,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Your Business" section — five states:
/// no submission (List Your Business CTA) · pending · rejected (+resubmit)
/// · approved (My Business) · suspended.
/// Compact profile tile: Submission Status with a live count/badge.
class _SubmissionStatusTile extends StatelessWidget {
  const _SubmissionStatusTile({required this.submissions});

  final List<dynamic> submissions;

  @override
  Widget build(BuildContext context) {
    final pending = submissions.where((s) => s.status == 'pending').length;
    final rejected = submissions.where((s) => s.status == 'rejected').length;
    String? badge;
    Color? badgeColor;
    if (rejected > 0) {
      badge = '$rejected need${rejected == 1 ? '' : 's'} changes';
      badgeColor = AppColors.brandRed;
    } else if (pending > 0) {
      badge = '$pending pending';
      badgeColor = AppColors.starAmber;
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        leading: const Icon(
          Icons.assignment_outlined,
          size: 20,
          color: AppColors.primary,
        ),
        title: Text('Submission Status', style: AppTypography.bodyStrong),
        subtitle: badge == null
            ? Text('Track your listing requests', style: AppTypography.label)
            : Text(
                badge,
                style: AppTypography.label.copyWith(
                  color: badgeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          size: 19,
          color: AppColors.textMuted,
        ),
        onTap: () => context.push('/submission-status'),
      ),
    );
  }
}

class _BusinessPromoCard extends StatelessWidget {
  const _BusinessPromoCard({required this.onListBusiness});

  final VoidCallback onListBusiness;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.bannerOrangeTop, AppColors.bannerOrangeBottom],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.storefront,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Text(
                  'CityBee for Business',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'FREE',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'List your shop, create offers & reach 50,000+ local customers.',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onListBusiness,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'List Your Business',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.open_in_new,
                    size: 13,
                    color: AppColors.primaryDark,
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

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.titleSm),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppShadows.card,
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.onTap,
    this.value,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Compact tile: dense vertical padding keeps rows comfortable (>48dp
    // with leading icon) while showing more content per screen.
    return ListTile(
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 13),
      minLeadingWidth: 34,
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 17),
      ),
      title: Text(label, style: AppTypography.bodyStrong),
      subtitle: value == null
          ? null
          : Text(value!, style: AppTypography.label.copyWith(fontSize: 10)),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 19,
        color: AppColors.textMuted,
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      ripple: true,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppShadows.card,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, size: 17, color: AppColors.brandRed),
            SizedBox(width: 7),
            Text(
              'Log Out',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: AppColors.brandRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginTile extends StatelessWidget {
  const _LoginTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      ripple: true,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login_rounded, size: 17, color: Colors.white),
            SizedBox(width: 7),
            Text(
              'Sign in / Register',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
