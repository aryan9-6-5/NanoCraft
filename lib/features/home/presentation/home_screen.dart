import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/app_spacing.dart';
import '../../../shared/widgets/nano_card.dart';
import '../../../shared/widgets/nano_difficulty_badge.dart';
import '../../../shared/widgets/nano_empty_state.dart';
import '../../play/presentation/providers/level_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final levelsAsync = ref.watch(levelsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NanoCraft'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back!',
              style: theme.textTheme.headlineLarge,
            ),
            const SizedBox(height: AppSpacing.lg),

            _SectionHeader(title: 'Continue Playing'),
            const SizedBox(height: AppSpacing.sm),
            NanoCard(
              child: NanoEmptyState(
                icon: Icons.play_circle_outline_rounded,
                title: 'No levels in progress',
                subtitle: 'Start solving puzzles and your progress will appear here.',
                actionLabel: 'Explore Puzzles',
                onAction: () => context.go('/explore'),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            _SectionHeader(title: 'New Levels'),
            const SizedBox(height: AppSpacing.sm),
            levelsAsync.when(
              data: (levels) {
                if (levels.isEmpty) {
                  return NanoCard(
                    child: NanoEmptyState(
                      icon: Icons.auto_awesome_outlined,
                      title: 'No puzzles published yet',
                      subtitle: 'Go to the Create tab and publish your first Nonogram!',
                      actionLabel: 'Create Puzzle',
                      onAction: () => context.go('/create'),
                    ),
                  );
                }

                // Show top 3 recent puzzles
                final recentLevels = levels.take(3).toList();
                return Column(
                  children: recentLevels.map((level) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: NanoCard(
                      onTap: () => context.push('/play/${level.levelId}'),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.08),
                              borderRadius: AppSpacing.borderRadiusMd,
                            ),
                            child: Icon(
                              level.gridSize == 10
                                  ? Icons.grid_on_rounded
                                  : Icons.apps_rounded,
                              color: colorScheme.primary,
                              size: 20,
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
                                  '${level.gridSize}×${level.gridSize}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          NanoDifficultyBadge(difficulty: level.difficulty),
                        ],
                      ),
                    ),
                  )).toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, stack) => Center(
                child: Text('Error loading recent levels: $err'),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            _SectionHeader(title: 'Community Picks'),
            const SizedBox(height: AppSpacing.sm),
            NanoCard(
              child: NanoEmptyState(
                icon: Icons.emoji_events_outlined,
                title: 'Curated puzzles',
                subtitle: 'Handpicked Nonograms from the community.',
              ),
            ),

            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}
