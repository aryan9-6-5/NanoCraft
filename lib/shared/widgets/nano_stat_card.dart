import 'package:flutter/material.dart';
import '../../config/app_spacing.dart';

/// A stat display card with icon, value, and label.
/// Used in Profile and Home for displaying Created/Solved counts.
class NanoStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const NanoStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: AppSpacing.borderRadiusLg,
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: theme.textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}
