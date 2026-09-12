import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'skeleton.dart';
import 'app_icons.dart';
import 'package:iconify_flutter/iconify_flutter.dart';

/// Network image with graceful placeholder and offline fallback so lists
/// never show broken image icons.
///
/// • Loading: subtle skeleton surface that fades into the image.
/// • Error: polished brand fallback (soft tint + category icon) — never a
///   harsh colored block.
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackIcon = AppUiIcons.storefront_outline,
    this.memCacheWidth = 1080,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String fallbackIcon;

  /// Decodes the image at most this wide (px) — big uploads render as
  /// small KB in memory and load fast on phones.
  final int? memCacheWidth;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: memCacheWidth,
      fadeInDuration: const Duration(milliseconds: 280),
      fadeOutDuration: const Duration(milliseconds: 120),
      placeholder: (_, __) => SkeletonBox(
        width: width,
        height: height ?? double.infinity,
        radius: 0,
      ),
      errorWidget: (_, __, ___) => _Fallback(icon: fallbackIcon),
    );
  }
}

/// Soft brand-tinted fallback with a category icon — used when the image
/// fails to load or the URL is empty.
class _Fallback extends StatelessWidget {
  const _Fallback({required this.icon});

  final String icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primarySoft,
      child: Center(
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.85),
            shape: BoxShape.circle,
          ),
          child: Iconify(icon, color: AppColors.primary, size: 17),
        ),
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
