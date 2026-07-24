import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_spacing.dart';

/// Difficulty badge chip with semantic color coding.
/// Automatically colors based on difficulty label.
class NanoDifficultyBadge extends StatelessWidget {
  final String difficulty;
  final double? fontSize;

  const NanoDifficultyBadge({
    super.key,
    required this.difficulty,
    this.fontSize,
  });

  Color get _color {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppColors.difficultyEasy;
      case 'medium':
        return AppColors.difficultyMedium;
      case 'hard':
        return AppColors.difficultyHard;
      case 'expert':
        return AppColors.difficultyExpert;
      default:
        return AppColors.difficultyEasy;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(color: _color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: TextStyle(
          fontSize: fontSize ?? 11,
          fontWeight: FontWeight.w600,
          color: _color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
