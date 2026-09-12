import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';

/// Lightweight shimmer skeleton system (no external package).
///
/// Wrap a subtree (the whole app, via [MaterialApp.builder]) in [Shimmer];
/// every [SkeletonBox] below it shares that single animation controller, so
/// even long lists animate cheaply. Without a [Shimmer] ancestor the boxes
/// render as calm static surfaces — still a valid skeleton.
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child});

  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ShimmerScope(
      controller: _controller,
      child: widget.child,
    );
  }
}

class _ShimmerScope extends InheritedWidget {
  const _ShimmerScope({required this.controller, required super.child});

  final AnimationController controller;

  @override
  bool updateShouldNotify(_ShimmerScope oldWidget) =>
      controller != oldWidget.controller;
}

/// Base skeleton block: a rounded rectangle painted with a sweeping
/// highlight. Compose cards, rails and lists out of these.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width = double.infinity,
    this.height = 14,
    this.radius = 8,
    this.margin,
  });

  final double? width;
  final double height;
  final double radius;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_ShimmerScope>();
    final base = AppColors.divider;
    const highlight = Colors.white;

    Widget box = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(radius),
      ),
    );

    if (scope == null) return box;

    return AnimatedBuilder(
      animation: scope.controller,
      builder: (context, child) {
        // Sweep position 0 → 1; the highlight stop rides along it.
        final t = scope.controller.value;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: const Alignment(-1, 0),
              end: const Alignment(1, 0),
              colors: [base, highlight, base],
              stops: [0, t.clamp(0.05, 0.95), 1],
            ),
          ),
          child: child,
        );
      },
      child: box,
    );
  }
}

/// Surface card skeleton: bordered card with an optional image block on top
/// and a couple of text lines below — the shape of business/offer cards.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({
    super.key,
    this.width = 236,
    this.height = 196,
    this.imageHeight = 118,
    this.radius = 16,
  });

  final double width;
  final double height;
  final double imageHeight;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image flexes so the text block always fits the fixed card
          // height (a fixed imageHeight overflows short cards by ~19px).
          Expanded(
            child: SkeletonBox(height: imageHeight, radius: 0),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(
                    width: width * 0.6, height: 13, radius: 6),
                const SizedBox(height: 8),
                SkeletonBox(
                    width: width * 0.4, height: 10, radius: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal rail of skeleton cards (offers rail, places rail, …).
class SkeletonRail extends StatelessWidget {
  const SkeletonRail({
    super.key,
    this.height = 196,
    this.itemWidth = 236,
    this.indented = false,
    this.itemCount = 2,
  });

  final double height;
  final double itemWidth;

  /// Whether the rail is inside screen padding (adds horizontal padding).
  final bool indented;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: indented ? 0 : 16),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) =>
            SkeletonCard(width: itemWidth, height: height - 2),
      ),
    );
  }
}

/// Vertical list of compact skeleton cards (popular businesses, deals, …).
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.itemCount = 3,
    this.itemHeight = 116,
    this.horizontalPadding = 0,
  });

  final int itemCount;
  final double itemHeight;

  /// Outer horizontal margin when the list sits inside screen padding.
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < itemCount; i++)
          Padding(
            padding: EdgeInsets.only(
              left: horizontalPadding,
              right: horizontalPadding,
              bottom: i == itemCount - 1 ? 0 : 12,
            ),
            child: _RowCard(height: itemHeight),
          ),
      ],
    );
  }
}

class _RowCard extends StatelessWidget {
  const _RowCard({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          SkeletonBox(width: 92, height: double.infinity, radius: AppRadius.md),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(width: 150, height: 13, radius: 6),
                const SizedBox(height: 9),
                const SkeletonBox(width: 100, height: 10, radius: 5),
                const SizedBox(height: 9),
                const SkeletonBox(width: 190, height: 10, radius: 5),
                const Spacer(),
                Row(
                  children: const [
                    SkeletonBox(width: 70, height: 26, radius: 9),
                    SizedBox(width: 7),
                    SkeletonBox(width: 70, height: 26, radius: 9),
                    SizedBox(width: 7),
                    SkeletonBox(width: 70, height: 26, radius: 9),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Grid of tile skeletons (category grid on Home).
class SkeletonGrid extends StatelessWidget {
  const SkeletonGrid({
    super.key,
    this.tiles = 8,
    this.columns = 4,
    this.tileHeight = 84,
    this.spacing = 12,
  });

  final int tiles;
  final int columns;
  final double tileHeight;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var row = 0; row < (tiles / columns).ceil(); row++)
          Padding(
            padding: EdgeInsets.only(bottom: row == (tiles / columns).ceil() - 1 ? 0 : spacing),
            child: Row(
              children: [
                for (var col = 0; col < columns; col++)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: col == columns - 1 ? 0 : spacing),
                      child: SkeletonBox(height: tileHeight, radius: AppRadius.lg),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
