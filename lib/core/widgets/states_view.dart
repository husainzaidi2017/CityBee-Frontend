import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Loading / empty / error states so screens never render blank.
abstract final class StatesView {
  static Widget loading({String? message}) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.4),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(message, style: AppTypography.caption),
            ],
          ],
        ),
      );

  static Widget empty({
    IconData icon = Icons.search_off,
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
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.textMuted, size: 28),
              ),
              const SizedBox(height: 14),
              Text(message, textAlign: TextAlign.center, style: AppTypography.body),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 14),
                OutlinedButton(
                  onPressed: onAction,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                  child: Text(actionLabel),
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
              const Icon(Icons.wifi_off_rounded, color: AppColors.textMuted, size: 40),
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
