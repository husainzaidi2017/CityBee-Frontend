import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Section title with optional trailing link ("See All (86) →"),
/// the app-wide reusable header for every Home/Explore/Offers section.
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

  /// e.g. "See All (86)" — renders as a brand link with a trailing chevron.
  final String? trailingLabel;
  final VoidCallback? onTrailingTap;

  /// Optional grey secondary line under the title.
  final String? subtitle;

  /// Brand underline accent (used by "Verified Deals" headers).
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
                  Text(
                    title,
                    style: AppTypography.title.copyWith(fontSize: 18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (underline) ...[
                    const SizedBox(height: 4),
                    Container(width: 42, height: 3, color: AppColors.brandRed),
                  ],
                ],
              ),
            ),
            if (trailingLabel != null)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTrailingTap,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        trailingLabel!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 1),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
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
