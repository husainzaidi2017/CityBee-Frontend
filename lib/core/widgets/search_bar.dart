import 'package:flutter/material.dart';

import '../theme/app_animation.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

/// Rounded pill search bar used on Home, Offers, Services, Explore and
/// Listing screens.
///
/// Premium and lightweight: soft surface, hairline border, an extremely
/// subtle shadow, and an animated focus state (border tint + faint glow
/// lift) instead of any heavy dark outline. Pass [onTap] for read-only
/// bars that navigate to search.
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
    final borderColor = _focused
        ? AppColors.primary.withValues(alpha: 0.55)
        : AppColors.border;
    return AnimatedContainer(
      duration: AppAnimation.fast,
      curve: Curves.easeOut,
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: borderColor, width: _focused ? 1.4 : 1.1),
        // Extremely subtle lift on focus — never a dark shadow.
        boxShadow: [
          BoxShadow(
            color: _focused
                ? AppColors.primary.withValues(alpha: 0.10)
                : const Color(0x0A0F172A),
            blurRadius: _focused ? 14 : 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(
            Icons.search_rounded,
            size: 20,
            color: _focused ? AppColors.primary : AppColors.textMuted,
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
                border: InputBorder.none,
                isCollapsed: true,
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
