import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
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
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  DateTime? _lastBackAt;

  /// Back behaves like the nav buttons: detail routes pop, any other
  /// tab returns Home, and only Home itself runs double-back-to-exit
  /// (first back prompts; a second back within 2s exits with the system
  /// exit animation).
  void _handleBack(BuildContext context) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
      return;
    }
    // On any tab other than Home, back switches to Home (like tapping
    // the Home nav button).
    if (widget.navigationShell.currentIndex != 0) {
      _goBranch(0);
      return;
    }
    final now = DateTime.now();
    if (_lastBackAt != null &&
        now.difference(_lastBackAt!) <= const Duration(seconds: 2)) {
      SystemNavigator.pop(); // system exit animation
      return;
    }
    _lastBackAt = now;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Iconify(AppUiIcons.logout, size: 16, color: Colors.white),
              SizedBox(width: 8),
              Text('Press back again to exit'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 84),
          backgroundColor: const Color(0xFF1F2937),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final isOwner =
        ref.watch(ownerSummaryProvider).valueOrNull?.hasApprovedBusiness ?? false;

    // Web keeps the browser's normal back behavior.
    if (kIsWeb) {
      return Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: _buildNavBar(isOwner),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack(context);
      },
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: _buildNavBar(isOwner),
      ),
    );
  }

  /// The 5-tab bottom navigation bar.
  Widget _buildNavBar(bool isOwner) {
    return Container(
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
                selected: widget.navigationShell.currentIndex == 0,
                onTap: () => _goBranch(0),
              ),
              _NavItem(
                icon: AppIcons.offersOutline,
                activeIcon: AppIcons.offers,
                label: 'Offers',
                selected: widget.navigationShell.currentIndex == 1,
                onTap: () => _goBranch(1),
              ),
              _NavItem(
                icon: AppIcons.servicesOutline,
                activeIcon: AppIcons.services,
                label: 'Services',
                selected: widget.navigationShell.currentIndex == 2,
                onTap: () => _goBranch(2),
              ),
              _NavItem(
                icon: isOwner ? AppIcons.businessOutline : AppIcons.exploreOutline,
                activeIcon: isOwner ? AppIcons.business : AppIcons.explore,
                label: isOwner ? 'My Business' : 'Explore',
                selected: widget.navigationShell.currentIndex == 3,
                onTap: () => _goBranch(3),
              ),
              _NavItem(
                icon: AppIcons.moreOutline,
                activeIcon: AppIcons.more,
                label: 'More',
                selected: widget.navigationShell.currentIndex == 4,
                onTap: () => _goBranch(4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
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

  /// Iconify data (outline + filled variants).
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
                    color: color,
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
