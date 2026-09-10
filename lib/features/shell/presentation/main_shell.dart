import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../providers/app_providers.dart';

/// Root scaffold with the persistent 5-tab bottom navigation:
/// Home · Offers · Services · (Explore | My Business) · More.
///
/// Tab 3 is backend-driven: approved business owners see My Business
/// instead of Explore (Explore stays reachable via More → Explore City).
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOwner =
        ref.watch(ownerSummaryProvider).valueOrNull?.hasApprovedBusiness ?? false;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 62,
            child: Row(
              children: [
                _NavItem(
                  icon: AppIcons.homeOutline,
                  activeIcon: AppIcons.home,
                  label: 'Home',
                  selected: navigationShell.currentIndex == 0,
                  onTap: () => _goBranch(0),
                ),
                _NavItem(
                  icon: AppIcons.offersOutline,
                  activeIcon: AppIcons.offers,
                  label: 'Offers',
                  selected: navigationShell.currentIndex == 1,
                  onTap: () => _goBranch(1),
                ),
                _NavItem(
                  icon: AppIcons.servicesOutline,
                  activeIcon: AppIcons.services,
                  label: 'Services',
                  selected: navigationShell.currentIndex == 2,
                  onTap: () => _goBranch(2),
                ),
                _NavItem(
                  icon: isOwner
                      ? AppIcons.businessOutline
                      : AppIcons.exploreOutline,
                  activeIcon:
                      isOwner ? AppIcons.business : AppIcons.explore,
                  label: isOwner ? 'My Business' : 'Explore',
                  selected: navigationShell.currentIndex == 3,
                  onTap: () => _goBranch(3),
                ),
                _NavItem(
                  icon: AppIcons.moreOutline,
                  activeIcon: AppIcons.more,
                  label: 'More',
                  selected: navigationShell.currentIndex == 4,
                  onTap: () => _goBranch(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  /// SVG asset paths (outline + filled variants).
  final String icon;
  final String activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textMuted;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Soft brand pill behind the selected icon.
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: AppIcons.nav(
                    selected ? activeIcon : icon,
                    key: ValueKey(selected),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: color,
                ),
                child: Text(label, maxLines: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
