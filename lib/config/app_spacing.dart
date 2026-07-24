import 'package:flutter/material.dart';

/// Consistent spacing scale and radii for NanoCraft's design system.
/// Use these instead of raw numbers to maintain visual rhythm.
abstract final class AppSpacing {
  // ──────────────── Spacing Scale ────────────────
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // ──────────────── Screen Padding ────────────────
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: 20.0,
    vertical: 16.0,
  );
  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(horizontal: 20.0);

  // ──────────────── Border Radii ────────────────
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 28.0;
  static const double radiusFull = 999.0;

  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderRadiusXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius borderRadiusXxl = BorderRadius.all(Radius.circular(radiusXxl));

  // ──────────────── Card Padding ────────────────
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(sm);

  // ──────────────── Elevations ────────────────
  static const double elevationNone = 0.0;
  static const double elevationSm = 1.0;
  static const double elevationMd = 2.0;
  static const double elevationLg = 4.0;
  static const double elevationXl = 8.0;

  // ──────────────── Touch Targets ────────────────
  /// Minimum touch target size per Material accessibility guidelines
  static const double minTouchTarget = 48.0;
}
