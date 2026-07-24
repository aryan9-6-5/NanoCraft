import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_spacing.dart';
import '../../../shared/widgets/nano_button.dart';
import 'providers/create_puzzle_controller.dart';

class ImagePreprocessScreen extends ConsumerWidget {
  const ImagePreprocessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createPuzzleProvider);
    final notifier = ref.read(createPuzzleProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final Color gridFilled = isDark ? AppColors.gridFilledDark : AppColors.gridFilledLight;
    final Color gridEmpty = isDark ? AppColors.gridEmptyDark : AppColors.gridEmptyLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => notifier.changeStep(CreateStep.selectMethod),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Adjust Threshold', style: theme.textTheme.titleLarge),
            ],
          ),
        ),

        // Help text
        Padding(
          padding: AppSpacing.screenHorizontal,
          child: Text(
            'Drag the slider to adjust the contrast. Dark areas will become filled cells in the puzzle grid.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // 15x15 Preview Grid
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                margin: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: AppSpacing.borderRadiusXl,
                  border: Border.all(
                    color: colorScheme.outlineVariant,
                    width: 0.5,
                  ),
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 15,
                    crossAxisSpacing: 1.5,
                    mainAxisSpacing: 1.5,
                  ),
                  itemCount: 225,
                  itemBuilder: (context, index) {
                    final int r = index ~/ 15;
                    final int c = index % 15;
                    final bool isFilled = state.grid[r][c];

                    return Container(
                      decoration: BoxDecoration(
                        color: isFilled ? gridFilled : gridEmpty,
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),

        // Threshold Slider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Lighter', style: theme.textTheme.labelSmall),
                  Text(
                    'Threshold: ${(state.threshold * 100).round()}%',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                  Text('Darker', style: theme.textTheme.labelSmall),
                ],
              ),
              Slider(
                value: state.threshold,
                onChanged: (val) => notifier.updateThreshold(val),
              ),
            ],
          ),
        ),

        // Confirm button
        Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
          ),
          child: NanoButton(
            label: 'Confirm & Edit Grid',
            icon: Icons.check_rounded,
            onPressed: () => notifier.changeStep(CreateStep.puzzleEditor),
          ),
        ),
      ],
    );
  }
}
