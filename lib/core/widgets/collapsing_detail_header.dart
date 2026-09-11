import 'dart:ui';
import 'package:flutter/material.dart';

import '../theme/app_animation.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/app_image.dart';
import '../widgets/pressable.dart';

/// Shared collapsing header for ALL detail pages (business, offer, place).
///
/// • Immersive hero image at ~0.62 of screen width (≈1.5× the old fixed
///   ~240 px), `BoxFit.cover` with proper clipping — never distorted.
/// • Top action row: Back (left), Favorite + Share (right).
/// • Native collapsing behavior via [SliverAppBar]: scrolling down shrinks
///   the image into a clean white bar with the page title; scrolling up
///   expands it again. Icons stay usable in both states.
///
/// The title fade and icon style transition are driven by the scroll
/// offset — smooth, subtle, never abrupt.
class CollapsingDetailHeader extends StatelessWidget {
  const CollapsingDetailHeader({
    super.key,
    required this.title,
    required this.image,
    this.imageList = const [],
    this.fallbackIcon = Icons.image_outlined,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.onShareTap,
    this.badge,
    this.onPageChanged,
    this.pageIndex = 0,
    this.onImageTap,
  });

  /// Page title shown once the header collapses.
  final String title;

  /// Single hero image. Ignored when [imageList] has entries.
  final String image;

  /// Multiple images → swipeable hero carousel with page dots.
  final List<String> imageList;

  final IconData fallbackIcon;

  /// Whether the favorite heart is currently active.
  final bool isFavorite;

  /// Optional — when null the heart is hidden.
  final VoidCallback? onFavoriteTap;

  /// Share action (always shown).
  final VoidCallback? onShareTap;

  /// Optional badge overlaid at the bottom-left of the hero.
  final Widget? badge;

  /// Carousel callbacks.
  final ValueChanged<int>? onPageChanged;
  final int pageIndex;

  /// Tap a hero photo → open the full-screen zoomable viewer. When null,
  /// photos are not tappable. Receives the tapped image index.
  final void Function(int index)? onImageTap;

  /// Base expanded height for the hero. ~0.62 of screen width ≈ 1.5× the
  /// previous fixed height on common devices.
  static double heroHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).width * 0.62;

  @override
  Widget build(BuildContext context) {
    final expandedHeight = heroHeight(context);
    final images = imageList.isNotEmpty ? imageList : [image];
    final canFavorite = onFavoriteTap != null;

    return SliverAppBar(
      pinned: true,
      expandedHeight: expandedHeight,
      leading: const SizedBox.shrink(),
      leadingWidth: 0,
      titleSpacing: 0,
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      // No Material shadow under the collapsed app bar — the content's own
      // card shadows must not glow out from under the hero.
      shadowColor: Colors.transparent,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final currentHeight = constraints.biggest.height;
          final t = ((currentHeight - kToolbarHeight) /
                  (expandedHeight - kToolbarHeight))
              .clamp(0.0, 1.0);

          final isExpanded = t > 0.35;
          final titleOpacity = 1 - (t * 2).clamp(0.0, 1.0).toDouble();

          return Stack(
            fit: StackFit.expand,
            children: [
              // ── Hero image ────────────────────────────────────────────
              if (isExpanded)
                Positioned.fill(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (images.length > 1)
                        // Blurred cover-crop of the current photo as the
                        // backdrop (ImageFiltered — cheap, never blurs the
                        // sharp photo above it), sharp photo contained on
                        // top, swipeable PageView.
                        _BlurredBackdrop(
                          url: images[pageIndex.clamp(0, images.length - 1)],
                        )
                      else
                        GestureDetector(
                          onTap:
                              onImageTap != null ? () => onImageTap!(0) : null,
                          child: AppImage(
                            url: image,
                            fallbackIcon: fallbackIcon,
                            fit: BoxFit.cover,
                          ),
                        ),

                      if (images.length > 1)
                        PageView.builder(
                          onPageChanged: onPageChanged,
                          itemCount: images.length,
                          itemBuilder: (context, i) => GestureDetector(
                            // Tap → full-screen zoomable viewer.
                            onTap:
                                onImageTap != null ? () => onImageTap!(i) : null,
                            child: Center(
                              child: AppImage(
                                url: images[i],
                                fallbackIcon: fallbackIcon,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),

                      // Soft gradient so the overlay text/badge reads well.
                      // IgnorePointer: without it the full-size gradient box
                      // sits ABOVE the PageView in the Stack and eats every
                      // swipe — the carousel gets stuck on page 1.
                      const Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: [0, 0.55, 1],
                                colors: [
                                  Color(0x40000000),
                                  Colors.transparent,
                                  Color(0x59000000),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      if (images.length > 1)
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: IgnorePointer(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (var i = 0; i < images.length; i++)
                                  AnimatedContainer(
                                    duration: AppAnimation.fast,
                                    curve: AppAnimation.curve,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    width: i == pageIndex ? 18 : 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: i == pageIndex
                                          ? Colors.white
                                          : Colors.white54,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                      if (badge != null)
                        Positioned(left: 16, bottom: 14, child: badge!),
                    ],
                  ),
                ),

              // ── Collapsed bar: title + divider fade in ──────────────
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: kToolbarHeight + MediaQuery.paddingOf(context).top,
                child: IgnorePointer(
                  child: Container(
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.fromLTRB(56, 0, 16, 8),
                    child: Opacity(
                      opacity: titleOpacity,
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.title.copyWith(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Action icons: back · favorite · share ───────────────
              Positioned(
                top: MediaQuery.paddingOf(context).top + 6,
                left: 10,
                right: 10,
                child: Row(
                  children: [
                    _HeaderIcon(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.of(context).maybePop(),
                      // Over the image: frosted chip; collapsed: soft chip.
                      expanded: isExpanded,
                    ),
                    const Spacer(),
                    if (canFavorite)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _HeaderIcon(
                          icon: isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          onTap: onFavoriteTap,
                          expanded: isExpanded,
                          tint: isFavorite ? AppColors.primary : null,
                        ),
                      ),
                    _HeaderIcon(
                      icon: Icons.ios_share_rounded,
                      onTap: onShareTap,
                      expanded: isExpanded,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Professional circular action chip used across all detail headers and
/// search surfaces: 34px target, backdrop blur over imagery, soft surface
/// chip on the collapsed bar.
class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.icon,
    required this.onTap,
    required this.expanded,
    this.tint,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool expanded;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final fg = tint ?? (expanded ? Colors.white : AppColors.textPrimary);
    return Pressable(
      onTap: onTap,
      pressedScale: 0.92,
      child: AnimatedContainer(
        duration: AppAnimation.fast,
        curve: AppAnimation.curve,
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: expanded
              ? Colors.black.withValues(alpha: 0.28)
              : AppColors.background,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: fg),
      ),
    );
  }
}

/// Blurred, cover-cropped backdrop for the multi-image hero — the current
/// photo fills the frame (blurred) behind the contained sharp version.
///
/// Uses ImageFiltered (blurs ONLY its own child) — BackdropFilter here
/// blurred the whole hero layer including the sharp photo above it.
class _BlurredBackdrop extends StatelessWidget {
  const _BlurredBackdrop({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Blurred cover-cropped image FILLING the whole hero (the
        // letterbox sides behind a contained portrait photo are the image
        // itself, blurred — never flat grey). CLIPPED so the scaled blur
        // can never paint outside the hero box (no orange shadow bleed).
        ClipRect(
          child: Transform.scale(
            scale: 1.15,
            child: ImageFiltered(
              imageFilter:
                  ImageFilter.blur(sigmaX: 28, sigmaY: 28, tileMode: TileMode.decal),
              child: AppImage(
                url: url,
                // fill: stretches a 540-wide portrait to frame width —
                // acceptable here because the result is heavily blurred
                // background texture, not the sharp photo.
                fit: BoxFit.fill,
                memCacheWidth: 480,
              ),
            ),
          ),
        ),
        // Dark veil so the sharp photo and dots read clearly on top.
        Container(color: Colors.black.withValues(alpha: 0.30)),
      ],
    );
  }
}
