import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_image.dart';
import '../../../providers/app_providers.dart';

/// More tab: profile card with level badge, savings stats, LocalGo for
/// Business, city tools, referral, support links and logout.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final city = ref.watch(selectedCityProvider);
    final favorites = ref.watch(favoritesProvider);

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          children: [
            Text('More', style: AppTypography.headline),
            const SizedBox(height: 14),

            // ── Profile card ──────────────────────────────────────
            _ProfileCard(
              name: profile.name,
              handle: profile.handle,
              levelTitle: profile.levelTitle,
              topPercent: profile.topPercent,
              avatar: profile.avatarImage,
            ),
            const SizedBox(height: 12),

            // ── Savings stats ─────────────────────────────────────
            _StatsRow(
              savedAmount: profile.savedAmount,
              bookmarkCount: favorites.isEmpty ? profile.bookmarkCount : favorites.length,
              reviewsGiven: profile.reviewsGiven,
            ),
            const SizedBox(height: 16),

            // ── LocalGo for Business ──────────────────────────────
            const _BusinessPromoCard(),
            const SizedBox(height: 16),

            // ── Your city tools ───────────────────────────────────
            _MenuCard(
              title: 'Your City Tools',
              children: [
                _MenuTile(
                  icon: Icons.location_city_outlined,
                  iconColor: AppColors.primary,
                  iconBg: AppColors.primarySoft,
                  label: 'Change City',
                  value: '${city.name}, ${city.state}',
                  onTap: () => context.go('/'),
                ),
                _MenuTile(
                  icon: Icons.favorite_border_rounded,
                  iconColor: AppColors.brandRed,
                  iconBg: const Color(0xFFFDECEC),
                  label: 'My Favorites',
                  value: '${favorites.isEmpty ? profile.bookmarkCount : favorites.length} saved places',
                  onTap: () => context.go('/favorites'),
                ),
                _MenuTile(
                  icon: Icons.map_outlined,
                  iconColor: AppColors.catHotel,
                  iconBg: AppColors.catHotelSoft,
                  label: 'Download City Map',
                  value: 'Offline map of ${city.name}',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Refer & earn ──────────────────────────────────────
            _MenuCard(
              title: 'Refer & Earn',
              children: [
                _MenuTile(
                  icon: Icons.card_giftcard_rounded,
                  iconColor: AppColors.accent,
                  iconBg: AppColors.accentSoft,
                  label: 'Invite Friends',
                  value: 'Get ₹100 per verified friend',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Support ───────────────────────────────────────────
            _MenuCard(
              title: 'Support',
              children: [
                _MenuTile(
                  icon: Icons.help_outline_rounded,
                  iconColor: AppColors.catDoctor,
                  iconBg: AppColors.catDoctorSoft,
                  label: 'Help & FAQ',
                  onTap: () {},
                ),
                _MenuTile(
                  icon: Icons.chat_bubble_outline_rounded,
                  iconColor: AppColors.primary,
                  iconBg: AppColors.primarySoft,
                  label: 'Contact Support',
                  value: 'WhatsApp us anytime',
                  onTap: () {},
                ),
                _MenuTile(
                  icon: Icons.star_border_rounded,
                  iconColor: AppColors.starAmber,
                  iconBg: const Color(0xFFFEF5E3),
                  label: 'Rate LocalGo',
                  onTap: () {},
                ),
                _MenuTile(
                  icon: Icons.description_outlined,
                  iconColor: AppColors.textSecondary,
                  iconBg: AppColors.background,
                  label: 'Terms & Privacy',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Logout ────────────────────────────────────────────
            _LogoutTile(onTap: () {}),
            const SizedBox(height: 14),
            Center(
              child: Text(
                'LocalGo v1.0.0 · Made in ${city.nickname} 💚',
                style: AppTypography.label.copyWith(fontSize: 9.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.handle,
    required this.levelTitle,
    required this.topPercent,
    required this.avatar,
  });

  final String name;
  final String handle;
  final String levelTitle;
  final String topPercent;
  final String avatar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2.5),
            ),
            child: AppAvatar(url: avatar, radius: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.title),
                const SizedBox(height: 2),
                Text(handle, style: AppTypography.label),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.military_tech_rounded,
                              size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            levelTitle,
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentSoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        topPercent,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.savedAmount,
    required this.bookmarkCount,
    required this.reviewsGiven,
  });

  final String savedAmount;
  final int bookmarkCount;
  final int reviewsGiven;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            value: savedAmount,
            label: 'Saved with LocalGo',
            icon: Icons.savings_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            value: '$bookmarkCount',
            label: 'Bookmarks',
            icon: Icons.bookmark_border_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            value: '$reviewsGiven',
            label: 'Reviews Given',
            icon: Icons.rate_review_outlined,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label, required this.icon});

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(height: 5),
          Text(
            value,
            style: AppTypography.titleSm.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.label.copyWith(fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class _BusinessPromoCard extends StatelessWidget {
  const _BusinessPromoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.bannerGreenTop, AppColors.bannerGreenBottom],
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
                child: const Icon(Icons.storefront, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Text(
                  'LocalGo for Business',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
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
                    fontSize: 9,
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
            onTap: () {},
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
                  Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primaryDark),
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
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
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
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 13),
      shape: Border.all(color: Colors.transparent),
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
      trailing: const Icon(Icons.chevron_right_rounded,
          size: 19, color: AppColors.textMuted),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
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
