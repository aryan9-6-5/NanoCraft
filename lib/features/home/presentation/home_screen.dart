import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/app_spacing.dart';
import '../../../shared/widgets/nano_card.dart';
import '../../../shared/widgets/nano_empty_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            NanoCard(
              child: NanoEmptyState(
                icon: Icons.auto_awesome_outlined,
                title: 'Coming soon',
                subtitle: 'New puzzles created by the community will appear here.',
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
