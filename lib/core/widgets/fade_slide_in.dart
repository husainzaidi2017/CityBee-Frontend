import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_animation.dart';

/// One-shot entrance animation: fades in while sliding up slightly.
///
/// Give each item an increasing [delay] (e.g. 30 ms × index) for a subtle
/// staggered reveal. Uses only Flutter's built-in animation APIs.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 14),
  });

  final Widget child;

  /// Wait before playing (for staggered grids/lists).
  final Duration delay;

  /// Slide distance; [Offset.zero] fades only.
  final Offset offset;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppAnimation.slow,
  );

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: AppAnimation.curve,
  );

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(widget.offset.dx / 100, widget.offset.dy / 100),
          end: Offset.zero,
        ).animate(_animation),
        child: widget.child,
      ),
    );
  }
}
