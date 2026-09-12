import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'app_icons.dart';
import 'skeleton.dart';

/// Loading / empty / error states so screens never render blank.
abstract final class StatesView {
  /// Content loading: a shimmer skeleton shaped like the incoming page
  /// (header image card + rows), with the message as a subtle caption.
  static Widget loading({String? message}) => SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: SkeletonCard(height: 180, width: double.infinity, imageHeight: 180, radius: 18),
            ),
            const SizedBox(height: 12),
            const SkeletonList(itemCount: 3, itemHeight: 108),
            if (message != null) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(message, style: AppTypography.caption),
              ),
            ],
          ],
        ),
      );

  static Widget empty({
    String icon = AppUiIcons.magnify_remove_outline,
    String message = 'Nothing here yet.',
    String? actionLabel,
    VoidCallback? onAction,
  }) =>
      Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Iconify(AppUiIcons.magnify_remove_outline, color: AppColors.primary, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(color: AppColors.textSecondary),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: onAction,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  icon: Iconify(icon, size: 14),
                  label: Text(actionLabel),
                ),
              ],
            ],
          ),
        ),
      );

  static Widget error({required String message, VoidCallback? onRetry}) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Iconify(AppUiIcons.wifi_strength_off_outline, color: AppColors.textMuted, size: 34),
              const SizedBox(height: 14),
              Text(message, textAlign: TextAlign.center, style: AppTypography.body),
              if (onRetry != null) ...[
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: onRetry,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      );
}
