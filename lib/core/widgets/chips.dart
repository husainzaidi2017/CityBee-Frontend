import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

/// Chip selection styles used across the app.
enum ChipStyle { dark, green, outline }

/// Filter chip exactly matching the designs: near-black pill when selected,
/// soft outline when not.
class SelectChip extends StatelessWidget {
  const SelectChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.style = ChipStyle.dark,
    this.showCheck = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ChipStyle style;
  final bool showCheck;

  @override
  Widget build(BuildContext context) {
    final Color activeBg;
    final Color activeFg;
    switch (style) {
      case ChipStyle.dark:
        activeBg = AppColors.chipDark;
        activeFg = AppColors.chipDarkText;
      case ChipStyle.green:
        activeBg = AppColors.primary;
        activeFg = Colors.white;
      case ChipStyle.outline:
        activeBg = AppColors.primary;
        activeFg = Colors.white;
    }

    final fg = selected ? activeFg : AppColors.textPrimary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        height: 38,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? activeBg : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? activeBg : AppColors.border,
            width: 1.1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showCheck && selected) ...[
              Icon(Icons.check, size: 15, color: fg),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Applied-filter chip with an ✕ to remove it (listing screens).
class RemovableFilterChip extends StatelessWidget {
  const RemovableFilterChip({
    super.key,
    required this.label,
    required this.onRemoved,
  });

  final String label;
  final VoidCallback onRemoved;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(left: 12, right: 2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border, width: 1.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.bodyStrong.copyWith(fontSize: 12),
          ),
          InkWell(
            onTap: onRemoved,
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Icon(Icons.close, size: 14, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal scrolling chip rail. Height leaves breathing room above and
/// below the 38px chip so borders/shadows are never clipped.
class ChipRail extends StatelessWidget {
  const ChipRail({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final List<Widget> children;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: children.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) => Center(child: children[index]),
      ),
    );
  }
}
