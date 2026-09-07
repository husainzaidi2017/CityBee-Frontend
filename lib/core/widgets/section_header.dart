import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Bold section title with optional trailing link ("See All (86) >")
/// matching the screenshot hierarchy.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailingLabel,
    this.onTrailingTap,
    this.subtitle,
    this.underline = false,
  });

  final String title;

  /// e.g. "See All (86) >" — renders as a green link when set.
  final String? trailingLabel;
  final VoidCallback? onTrailingTap;

  /// Optional grey secondary line under the title.
  final String? subtitle;

  /// Red underline accent (used by "Verified Moradabad Deals").
  final bool underline;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.title),
                  if (underline) ...[
                    const SizedBox(height: 3),
                    Container(width: 42, height: 3, color: AppColors.brandRed),
                  ],
                ],
              ),
            ),
            if (trailingLabel != null)
              GestureDetector(
                onTap: onTrailingTap,
                child: Text(
                  trailingLabel!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(subtitle!, style: AppTypography.caption),
        ],
      ],
    );
  }
}
