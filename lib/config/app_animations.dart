import 'package:flutter/animation.dart';

/// Animation constants for NanoCraft's design system.
/// Keeps all durations and curves consistent across the app.
abstract final class AppAnimations {
  // ──────────────── Durations ────────────────
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);
  static const Duration pageTransition = Duration(milliseconds: 250);

  // ──────────────── Curves ────────────────
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve emphasizedCurve = Curves.easeOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve decelerateCurve = Curves.decelerate;
}
