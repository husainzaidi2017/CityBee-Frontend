import 'package:flutter/material.dart';

import '../theme/app_animation.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'app_icons.dart';

/// Rounded pill search bar used on Home, Offers, Services, Explore and
/// Listing screens.
///
/// Clean and lightweight: white surface on the soft background with a
/// hairline border — no resting shadow at all. On focus the border tint
/// shifts to brand orange, the search icon scales up and turns orange, and
/// an extremely soft orange glow appears. Pass [onTap] for read-only bars
/// that navigate to search.
class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    super.key,
    required this.hint,
    this.onTap,
    this.controller,
    this.onChanged,
    this.readOnly = false,
    this.autofocus = false,
    this.trailing,
  });

  final String hint;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool readOnly;

  /// Auto-focus (used on the dedicated search screen).
  final bool autofocus;

  /// Optional trailing icon button.
  final Widget? trailing;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus != _focused) {
        setState(() => _focused = _focusNode.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppAnimation.normal,
      curve: AppAnimation.curve,
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: _focused
              ? AppColors.primary.withValues(alpha: 0.55)
              : AppColors.border,
          width: _focused ? 1.4 : 1.1,
        ),
        // Only a whisper of warm glow while focused — never at rest.
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          AnimatedScale(
            scale: _focused ? 1.1 : 1.0,
            duration: AppAnimation.normal,
            curve: AppAnimation.releaseCurve,
            child: AnimatedSwitcher(
              duration: AppAnimation.fast,
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: Iconify(
                AppUiIcons.magnify,
                key: ValueKey(_focused),
                size: 17,
                color: _focused ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              focusNode: _focusNode,
              controller: widget.controller,
              onChanged: widget.onChanged,
              readOnly: widget.readOnly,
              autofocus: widget.autofocus,
              onTap: widget.onTap,
              style: AppTypography.body.copyWith(fontSize: 13.5),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: AppTypography.body.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
                // Fully opt out of the app-wide InputDecorationTheme — its
                // outline + fill would draw a second box inside the pill.
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                filled: false,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (widget.trailing != null) ...[
            widget.trailing!,
            const SizedBox(width: 8),
          ] else
            const SizedBox(width: 14),
        ],
      ),
    );
  }
}
