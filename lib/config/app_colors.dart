import 'package:flutter/material.dart';

/// Semantic color tokens for NanoCraft's design system.
/// All colors are accessed through these constants — never hardcode hex values in widgets.
abstract final class AppColors {
  // ──────────────── Brand ────────────────
  static const Color brandPrimary = Color(0xFF6C63FF);
  static const Color brandSecondary = Color(0xFF26A69A);

  // ──────────────── Light Theme ────────────────
  static const Color lightSurface = Color(0xFFF8F8FC);
  static const Color lightSurfaceContainer = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerHigh = Color(0xFFF0F0F6);
  static const Color lightSurfaceDim = Color(0xFFE8E8EE);
  static const Color lightOnSurface = Color(0xFF1A1A2E);
  static const Color lightOnSurfaceVariant = Color(0xFF5A5A72);
  static const Color lightOutline = Color(0xFFD0D0DC);
  static const Color lightOutlineVariant = Color(0xFFE4E4EE);

  // ──────────────── Dark Theme ────────────────
  static const Color darkSurface = Color(0xFF0F0F14);
  static const Color darkSurfaceContainer = Color(0xFF1A1A22);
  static const Color darkSurfaceContainerHigh = Color(0xFF242430);
  static const Color darkSurfaceDim = Color(0xFF121218);
  static const Color darkOnSurface = Color(0xFFE8E8F0);
  static const Color darkOnSurfaceVariant = Color(0xFF9898A8);
  static const Color darkOutline = Color(0xFF3A3A48);
  static const Color darkOutlineVariant = Color(0xFF2A2A36);

  // ──────────────── Text ────────────────
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF5A5A72);
  static const Color lightTextTertiary = Color(0xFF8A8A9E);

  static const Color darkTextPrimary = Color(0xFFE8E8F0);
  static const Color darkTextSecondary = Color(0xFF9898A8);
  static const Color darkTextTertiary = Color(0xFF6A6A7E);

  // ──────────────── Semantic ────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF42A5F5);

  // ──────────────── Puzzle Grid ────────────────
  static const Color gridFilledLight = Color(0xFF3D3852);
  static const Color gridFilledDark = Color(0xFF8B85FF);
  static const Color gridEmptyLight = Color(0xFFFFFFFF);
  static const Color gridEmptyDark = Color(0xFF1A1A22);
  static const Color gridLineLight = Color(0xFFE0E0EA);
  static const Color gridLineDark = Color(0xFF2A2A36);
  static const Color gridLineThickLight = Color(0xFFB8B8C8);
  static const Color gridLineThickDark = Color(0xFF4A4A58);
  static const Color gridCrossLight = Color(0xFFCCC8D8);
  static const Color gridCrossDark = Color(0xFF5A5A6E);

  // Interactive glow — only used during placement animations
  static const Color gridFilledGlow = Color(0x336C63FF);

  // Clue states
  static const Color clueActiveLight = Color(0xFF6C63FF);
  static const Color clueActiveDark = Color(0xFF8B85FF);
  static const Color clueCompletedLight = Color(0xFFB8B8C8);
  static const Color clueCompletedDark = Color(0xFF4A4A58);
  static const Color clueUnresolvedLight = Color(0xFFEF5350);
  static const Color clueUnresolvedDark = Color(0xFFEF5350);

  // Difficulty
  static const Color difficultyEasy = Color(0xFF4CAF50);
  static const Color difficultyMedium = Color(0xFFFFA726);
  static const Color difficultyHard = Color(0xFFEF5350);
  static const Color difficultyExpert = Color(0xFF7B1FA2);
}
