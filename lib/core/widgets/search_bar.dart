import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// Rounded search bar used on Home, Offers, Services, Explore and Listing
/// screens. Pass [onTap] for read-only bars that navigate to search.
class AppSearchBar extends StatelessWidget {
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

  /// Optional trailing icon button (e.g. mic or list/map toggle handled
  /// outside the bar itself).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.border, width: 1.1),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, size: 19, color: AppColors.textMuted),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                readOnly: readOnly,
                autofocus: autofocus,
                onTap: onTap,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
