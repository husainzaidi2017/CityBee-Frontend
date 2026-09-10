import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// Filled pill button (primary green or white on green banners).
class PrimaryPillButton extends StatelessWidget {
  const PrimaryPillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.backgroundColor = AppColors.primary,
    this.foregroundColor = Colors.white,
    this.borderColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.fontSize = 13.5,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final EdgeInsets padding;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: padding,
          decoration: borderColor == null
              ? null
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: borderColor!),
                ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 15, color: foregroundColor), const SizedBox(width: 6)],
              Text(
                label,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact action button used inside card rows (Call / Route / WhatsApp).
/// Icon + label, ~40px tall — comfortable thumb target. `filled` renders
/// the single primary CTA in brand orange.
class CardActionButton extends StatelessWidget {
  const CardActionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.filled = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onTap;
  final bool filled;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final background = filled ? AppColors.primary : AppColors.background;
    final foreground = filled ? Colors.white : AppColors.textPrimary;
    return Expanded(
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(11),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              border: filled ? null : Border.all(color: AppColors.border, width: 1.1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 15, color: filled ? foreground : AppColors.primary),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular floating icon button with soft shadow (share, heart, bookmark…).
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 34,
    this.background = Colors.white,
    this.iconColor = AppColors.textPrimary,
    this.shadow = true,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color background;
  final Color iconColor;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: background,
        boxShadow: shadow
            ? const [BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 3))]
            : null,
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, size: size * 0.5, color: iconColor),
        padding: EdgeInsets.zero,
        constraints: BoxConstraints.tightFor(width: size, height: size),
        splashRadius: size * 0.6,
      ),
    );
  }
}

/// Veg / non-veg indicator dot used on menu items.
class VegDot extends StatelessWidget {
  const VegDot({super.key, required this.isVeg});

  final bool isVeg;

  @override
  Widget build(BuildContext context) {
    final color = isVeg ? const Color(0xFF15803D) : const Color(0xFFB91C1C);
    return Container(
      width: 13,
      height: 13,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.4),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Center(
        child: Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      ),
    );
  }
}
