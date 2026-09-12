import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';

/// Signature micro-animation per category (ui-ux-pro-max motion presets,
/// Flutter equivalents). Transform/opacity only — compositor-friendly;
/// one-shot on entrance (no infinite loops, per the skill's guidance);
/// snaps to the final state under reduced-motion.
enum IconMove {
  /// back.out(1.4) overshoot + settle — default for most categories.
  pop,
  /// Heartbeat: double-pulse, then settle — doctors/hospital.
  pulse,
  /// Drop from above with a bounce — restaurants/food.
  drop,
  /// Gentle float up like a balloon, then settle — hotels.
  float,
  /// Snip-wiggle rotation, like scissors working — salons/barbers.
  snip,
  /// Sparkle spin (full turn with overshoot) — shops/malls/fashion.
  spin,
  /// Horizontal excited wiggle — bars/cafes/cinemas.
  wiggle,
}

class AnimatedCategoryIcon extends StatefulWidget {
  const AnimatedCategoryIcon({
    super.key,
    required this.icon,
    required this.move,
    this.size = 42,
    this.color,
    this.delay = const Duration(milliseconds: 300),
  });

  final String icon;
  final IconMove move;
  final double size;
  final Color? color;

  /// Extra delay after the tile reveal so the icon move reads separately.
  final Duration delay;

  @override
  State<AnimatedCategoryIcon> createState() => _AnimatedCategoryIconState();
}

class _AnimatedCategoryIconState extends State<AnimatedCategoryIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _delayTimer;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1; // final state, no tweens
    } else {
      _delayTimer = Timer(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glyph = Iconify(widget.icon, size: widget.size, color: widget.color);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        switch (widget.move) {
          case IconMove.pulse:
            return Transform.scale(scale: _pulse(_controller.value), child: child);
          case IconMove.drop:
            return Transform.translate(
              offset: Offset(0, -14 * (1 - _dropCurve(_controller.value))),
              child: child,
            );
          case IconMove.float:
            return Transform.translate(
              offset: Offset(0, 12 * (1 - _controller.value)),
              child: child,
            );
          case IconMove.snip:
            return Transform.rotate(angle: _snipAngle(_controller.value), child: child);
          case IconMove.spin:
            return Transform.rotate(angle: _spinAngle(_controller.value), child: child);
          case IconMove.wiggle:
            return Transform.translate(
              offset: Offset(_wiggleX(_controller.value), 0),
              child: child,
            );
          case IconMove.pop:
            return Transform.scale(scale: _backOut(_controller.value), child: child);
        }
      },
      child: glyph,
    );
  }

  // ── Motion curves (skill presets: back.out(1.4) & friends) ─────────

  /// back.out(1.4): overshoot past 1 then settle.
  static double _backOut(double t) {
    if (t >= 1) return 1;
    const s = 1.4;
    final u = t - 1;
    return 1 + u * u * ((s + 1) * u + s);
  }

  /// Heartbeat: 1 → 1.15 → 1 → 1.12 → 1.
  static double _pulse(double t) {
    if (t >= 1) return 1;
    if (t < 0.3) return 1 + 0.15 * _easeOut(t / 0.3);
    if (t < 0.5) return 1.15 - 0.15 * ((t - 0.3) / 0.2);
    if (t < 0.7) return 1 + 0.12 * _easeOut((t - 0.5) / 0.2);
    return 1.12 - 0.12 * ((t - 0.7) / 0.3);
  }

  /// Drop-in: fast fall, small bounce, settle.
  static double _dropCurve(double t) {
    if (t >= 1) return 1;
    if (t < 0.6) return _easeOut(t / 0.6) * 0.85;
    if (t < 0.85) return 0.85 + 0.15 * _backOut((t - 0.6) / 0.25);
    return 1;
  }

  /// Scissors snip: small alternating rotations fading to 0.
  static double _snipAngle(double t) {
    if (t >= 1) return 0;
    return 0.35 * (1 - t) * _sinWave(t * 3.5);
  }

  /// Sparkle spin: one full turn with back.out settle (ends at 2π ≡ 0).
  static double _spinAngle(double t) {
    if (t >= 1) return 0;
    return 2 * 3.14159265 * _backOut(t);
  }

  /// Excited horizontal wiggle, fading amplitude.
  static double _wiggleX(double t) {
    if (t >= 1) return 0;
    return 6 * (1 - t) * _sinWave(t * 4);
  }

  static double _easeOut(double t) => 1 - (1 - t) * (1 - t);
  static double _sinWave(double x) => x - (x * x * x) / 6; // small-angle sin
}
