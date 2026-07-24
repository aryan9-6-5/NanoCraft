import 'package:flutter/material.dart';
import '../../../config/app_spacing.dart';
import '../../../shared/widgets/nano_card.dart';
import '../../../shared/widgets/nano_difficulty_badge.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
      ),
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search hint
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: AppSpacing.borderRadiusMd,
                border: Border.all(
                  color: colorScheme.outlineVariant,
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Search puzzles by name, tags, or creator...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Text('Recent Puzzles', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),

            // Sample puzzle list
            Expanded(
              child: ListView.separated(
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final difficulties = ['Easy', 'Medium', 'Hard'];
                  final icons = [Icons.grid_on_rounded, Icons.grid_view_rounded, Icons.apps_rounded];

                  return NanoCard(
                    onTap: () {
                      // Navigate to play screen
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.08),
                            borderRadius: AppSpacing.borderRadiusMd,
                          ),
                          child: Icon(
                            icons[index],
                            color: colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sample Puzzle #${index + 1}',
                                style: theme.textTheme.titleSmall,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'By Creator • 15×15',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        NanoDifficultyBadge(difficulty: difficulties[index]),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
