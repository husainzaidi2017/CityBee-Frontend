import 'package:flutter/animation.dart';

/// Centralized motion constants so every interaction feels the same.
///
/// Usage: wrap with [AnimatedContainer]/[AnimatedScale]/[AnimatedSwitcher]
/// and pick [fast], [normal] or [slow] instead of hand-writing durations.
abstract final class AppAnimation {
  /// Micro feedback (press scale, color swaps).
  static const Duration fast = Duration(milliseconds: 150);

  /// Standard state transitions (focus, selection).
  static const Duration normal = Duration(milliseconds: 200);

  /// Deliberate movement (page jumps, reveal animations).
  static const Duration slow = Duration(milliseconds: 250);

  /// Default curve — snappy start, gentle landing.
  static const Cubic curve = Curves.easeOut;

  /// Slightly springy release for press feedback.
  static const Cubic releaseCurve = Curves.easeOutBack;
}
