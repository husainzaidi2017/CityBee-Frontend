import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_image.dart';
import 'city_picker_sheet.dart';
import 'notifications_sheet.dart';

/// LocalGo brand mark: orange pin tile + wordmark ("Go" in accent color).
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.tileSize = 34});

  final double tileSize;

  @override
  Widget build(BuildContext context) {
    final iconSize = tileSize == 34 ? 20.0 : 16.0;
    final fontSize = tileSize == 34 ? 18.0 : 16.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: tileSize,
          height: tileSize,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.location_on, color: Colors.white, size: iconSize),
        ),
        const SizedBox(width: 7),
        Text.rich(
          TextSpan(
            text: 'Local',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
            children: [
              TextSpan(
                text: 'Go',
                style: TextStyle(color: AppColors.accent),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// White app bar with brand mark, tappable city selector, notification bell
/// and profile avatar — the shared header of every main tab.
class LocationAppBar extends ConsumerWidget {
  const LocationAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final city = ref.watch(selectedCityProvider);
    final profile = ref.watch(userProfileProvider);

    return Material(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              const BrandMark(),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => showCityPickerSheet(context),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on, size: 13, color: AppColors.accent),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              city.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodyStrong.copyWith(fontSize: 13),
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded, size: 15, color: AppColors.textSecondary),
                        ],
                      ),
                      Text(
                        city.defaultArea,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.label.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => showNotificationsSheet(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      const Center(child: Icon(Icons.notifications_none_rounded, size: 19, color: AppColors.textPrimary)),
                      Positioned(
                        top: 9,
                        right: 10,
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
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => context.go('/more'),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  padding: const EdgeInsets.all(1.5),
                  child: AppAvatar(url: profile.avatarImage, radius: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
