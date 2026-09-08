import 'package:flutter/material.dart';

import '../theme/app_animation.dart';

/// The app's standard touch-feedback wrapper.
///
/// While pressed: subtle scale-down (default 0.97) plus an optional soft
/// shadow change; releases smoothly with a hint of spring. Wrap any
/// tappable card/button for consistent, premium interaction.
///
/// Set [ripple] for opaque surfaces (buttons, tiles) where an InkWell
/// splash reads well; leave it off for gradient/image cards where a
/// clipped splash would look wrong.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.onTap,
    required this.child,
    this.pressedScale = 0.97,
    this.enabled = true,
    this.ripple = false,
    this.borderRadius,
  });

  final VoidCallback? onTap;
  final Widget child;

  /// Scale factor applied while the widget is pressed.
  final double pressedScale;

  final bool enabled;

  /// Whether to also show a Material ripple (best on plain surfaces).
  final bool ripple;

  /// Clip corner for the ripple.
  final BorderRadius? borderRadius;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  void _set(bool value) {
    if (_pressed != value && mounted) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = widget.borderRadius ?? BorderRadius.circular(12);

    Widget content = AnimatedScale(
      scale: _pressed ? widget.pressedScale : 1.0,
      duration: _pressed ? AppAnimation.fast : AppAnimation.normal,
      curve: _pressed ? AppAnimation.curve : AppAnimation.releaseCurve,
      child: widget.child,
    );

    if (widget.ripple) {
      content = Material(
        color: Colors.transparent,
        borderRadius: effectiveBorderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.enabled ? widget.onTap : null,
          borderRadius: effectiveBorderRadius,
          child: content,
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.enabled ? (_) => _set(true) : null,
      onTapCancel: () => _set(false),
      onTapUp: (_) => _set(false),
      onTap: widget.ripple ? null : (widget.enabled ? widget.onTap : null),
      child: content,
    );
  }
}
