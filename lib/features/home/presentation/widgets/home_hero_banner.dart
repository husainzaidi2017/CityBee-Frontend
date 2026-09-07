import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Green gradient promotional banner at the top of the Home screen.
class HomeHeroBanner extends StatelessWidget {
  const HomeHeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bannerGreenTop, AppColors.bannerGreenBottom],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          // Decorative translucent circles.
          Positioned(
            right: -26,
            top: -30,
            child: _circle(110, Colors.white.withValues(alpha: 0.08)),
          ),
          Positioned(
            right: 22,
            bottom: -36,
            child: _circle(80, Colors.white.withValues(alpha: 0.07)),
          ),
          Positioned(
            right: 8,
            top: 14,
            child: Icon(Icons.local_offer_rounded,
                size: 54, color: Colors.white.withValues(alpha: 0.16)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'LIMITED-TIME DEALS',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Big Local Offers',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Flat 20–50% off at 86+ verified stores nearby',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/offers'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Explore Offers',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primaryDark),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  GestureDetector(
                    onTap: () => context.go('/offers'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        'All Live',
                        style: AppTypography.bodyStrong.copyWith(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
