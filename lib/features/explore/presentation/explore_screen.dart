import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/app_spacing.dart';
import '../../../shared/widgets/nano_card.dart';
import '../../../shared/widgets/nano_difficulty_badge.dart';
import '../../../shared/widgets/nano_empty_state.dart';
import '../../play/presentation/providers/level_providers.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelsAsync = ref.watch(levelsStreamProvider);
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
            // Search field container
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

            // Real puzzle list from stream provider
            Expanded(
              child: levelsAsync.when(
                data: (levels) {
                  if (levels.isEmpty) {
                    return NanoEmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No puzzles found',
                      subtitle: 'Be the first to design and publish a Nonogram puzzle!',
                      actionLabel: 'Create Puzzle',
                      onAction: () => context.go('/create'),
                    );
                  }

                  return ListView.separated(
                    itemCount: levels.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final level = levels[index];
                      return NanoCard(
                        onTap: () {
                          // Navigate to play screen using router push
                          context.push('/play/${level.levelId}');
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
                                level.gridSize == 10
                                    ? Icons.grid_on_rounded
                                    : Icons.apps_rounded,
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
                                    level.title,
                                    style: theme.textTheme.titleSmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    '${level.gridSize}×${level.gridSize} • Published by Creator',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            NanoDifficultyBadge(difficulty: level.difficulty),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (err, stack) => NanoEmptyState(
                  icon: Icons.error_outline_rounded,
                  title: 'Error loading levels',
                  subtitle: '$err',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
