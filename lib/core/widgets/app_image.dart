import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Network image with graceful placeholder and offline fallback so lists
/// never show broken image icons.
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.storefront_outlined,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => const ColoredBox(
        color: AppColors.surfaceAlt,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      errorWidget: (_, __, ___) => _Fallback(icon: fallbackIcon),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primarySoft,
      child: Center(
        child: Icon(icon, color: AppColors.primary, size: 28),
      ),
    );
  }
}

/// Circular avatar with cached image and initials fallback.
class AppAvatar extends StatelessWidget {
  const AppAvatar({super.key, required this.url, this.radius = 16, this.fallback = 'LG'});

  final String url;
  final double radius;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primarySoft,
      foregroundColor: AppColors.primary,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => Center(
            child: Text(
              fallback,
              style: TextStyle(fontSize: radius * 0.8, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
    );
  }
}
