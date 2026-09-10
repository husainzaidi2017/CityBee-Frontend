import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';

/// The app-wide card container: white surface, 16px radius, soft elevation —
/// NO hairline border. This is the one card style used across every screen
/// so content groups by depth instead of outlines.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius = AppRadius.lg,
    this.color,
    this.onTap,
    this.clipBehavior = Clip.none,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? color;

  /// Wraps the card in an ink ripple when set.
  final VoidCallback? onTap;
  final Clip clipBehavior;

  /// Shared decoration so custom Containers can match exactly.
  static BoxDecoration decoration({Color? color, double radius = AppRadius.lg}) =>
      BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: AppShadows.card,
      );

  @override
  Widget build(BuildContext context) {
    final body = Container(
      margin: margin,
      clipBehavior: clipBehavior,
      decoration: decoration(color: color, radius: radius),
      child: padding == null ? child : Padding(padding: padding!, child: child),
    );
    if (onTap == null) return body;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: body,
      ),
    );
  }
}
