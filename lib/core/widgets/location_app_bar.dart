import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/city_picker_sheet.dart';
import '../widgets/notifications_sheet.dart';
import 'brand_mark.dart';

/// Shared header of the main tabs:
///
///     CityBee logo                    📍 Location   🔔
///
/// Logo on the left; the location selector sits right beside the
/// notification bell, which hugs the right edge (with safe-area padding).
class LocationAppBar extends ConsumerWidget {
  const LocationAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final city = ref.watch(selectedCityProvider);

    return Material(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              // ── Brand (left) ───────────────────────────────────
              const BrandMark(markSize: 30, wordmarkSize: 19),
              const Spacer(),

              // ── Location (beside the bell) ────────────────────
              GestureDetector(
                onTap: () => showCityPickerSheet(context),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on, size: 13, color: AppColors.brandOrange),
                          const SizedBox(width: 2),
                          Flexible(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 130),
                              child: Text(
                                city.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodyStrong.copyWith(fontSize: 13),
                              ),
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded,
                              size: 15, color: AppColors.textSecondary),
                        ],
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 150),
                        child: Text(
                          city.defaultArea,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.label.copyWith(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Notifications (right edge) ─────────────────────
              GestureDetector(
                onTap: () => showNotificationsSheet(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      const Center(
                        child: Icon(Icons.notifications_none_rounded,
                            size: 20, color: AppColors.textPrimary),
                      ),
                      Positioned(
                        top: 10,
                        right: 11,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.brandRed,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.surface, width: 1.2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
