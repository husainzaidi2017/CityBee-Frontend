import 'dart:async';

import 'package:flutter/material.dart';

/// Animated category tile (ui-ux-pro-max patterns):
///  - entrance: staggered grid reveal — fade + scale(0.92→1) + slight lift,
///    back-out easing, ~50ms per-tile stagger
///  - press: spring scale-down (tap feedback, not hover — touch app)
///  - icon: gentle emphasis pop when the tile settles
///  - honors the system "remove animations" accessibility flag
class AnimatedCategoryTile extends StatefulWidget {
  const AnimatedCategoryTile({
    super.key,
    required this.index,
    required this.child,
    required this.onTap,
  });

  /// Grid position — drives the stagger delay.
  final int index;
  final Widget child;
  final VoidCallback onTap;

  @override
  State<AnimatedCategoryTile> createState() => _AnimatedCategoryTileState();
}

class _AnimatedCategoryTileState extends State<AnimatedCategoryTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _reveal;
  late final Animation<double> _pop;
  Timer? _staggerTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    // back.out(1.4) equivalent — playful settle.
    _reveal = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    // Icon emphasis: mid-flight pop that settles to 1.
    _pop = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.18)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.18, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 55,
      ),
    ]).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1.0)),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reduced-motion: show the final state immediately, no tweens.
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce) {
      _controller.value = 1;
    } else {
      // Stagger: cap the total so long grids don't feel sluggish.
      final delay = Duration(milliseconds: (widget.index.clamp(0, 12)) * 50);
      _staggerTimer = Timer(delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _staggerTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _reveal,
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _controller,
          curve: const Interval(0, 0.6, curve: Curves.easeOut),
        ),
        child: _PressableTile(
          onTap: widget.onTap,
          child: ScaleTransition(scale: _pop, child: widget.child),
        ),
      ),
    );
  }
}

/// Tap feedback: quick spring scale-down while pressed (touch-first —
/// no hover reliance), returns with a bouncy release.
class _PressableTile extends StatefulWidget {
  const _PressableTile({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  State<_PressableTile> createState() => _PressableTileState();
}

class _PressableTileState extends State<_PressableTile> {
  double _scale = 1.0;

  void _set(bool down) => setState(() => _scale = down ? 0.94 : 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _set(true),
      onTapUp: (_) {
        _set(false);
        widget.onTap();
      },
      onTapCancel: () => _set(false),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
