import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_spacing.dart';
import '../../../shared/widgets/nano_button.dart';
import '../../../shared/widgets/nano_difficulty_badge.dart';
import '../../../shared/widgets/nano_dialog.dart';
import '../../authentication/presentation/providers/auth_providers.dart';
import '../../../../shared/utils/clue_generator.dart';
import 'providers/create_puzzle_controller.dart';

class PuzzleEditorScreen extends ConsumerStatefulWidget {
  const PuzzleEditorScreen({super.key});

  @override
  ConsumerState<PuzzleEditorScreen> createState() => _PuzzleEditorScreenState();
}

class _PuzzleEditorScreenState extends ConsumerState<PuzzleEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  int? _lastToggledRow;
  int? _lastToggledCol;
  bool? _isDrawingFill;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(createPuzzleProvider);
      _titleController.text = state.title;
      _tagsController.text = state.tags.join(', ');
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _handleBack() async {
    final confirm = await NanoDialog.show(
      context,
      title: 'Leave Editor?',
      content: 'Your draft is auto-saved. You can resume later.',
      confirmLabel: 'Leave',
      cancelLabel: 'Stay',
    );
    if (confirm == true) {
      ref.read(createPuzzleProvider.notifier).changeStep(CreateStep.selectMethod);
    }
  }

  void _handlePan(Offset localPosition, double gridWidth, int gridSize, CreatePuzzleNotifier notifier) {
    final double cellSize = gridWidth / gridSize;
    final int c = (localPosition.dx / cellSize).floor().clamp(0, gridSize - 1);
    final int r = (localPosition.dy / cellSize).floor().clamp(0, gridSize - 1);

    if (r == _lastToggledRow && c == _lastToggledCol) return;

    setState(() {
      _lastToggledRow = r;
      _lastToggledCol = c;
    });

    if (_isDrawingFill == null) {
      _isDrawingFill = !notifier.state.grid[r][c];
    }

    notifier.fillCell(r, c, _isDrawingFill!);
  }

  void _handlePanEnd() {
    setState(() {
      _lastToggledRow = null;
      _lastToggledCol = null;
      _isDrawingFill = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createPuzzleProvider);
    final notifier = ref.read(createPuzzleProvider.notifier);
    final currentUser = ref.watch(currentUserProvider).value;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final int gridSize = state.grid.length;
    final rowClues = ClueGenerator.generateRowClues(state.grid);
    final colClues = ClueGenerator.generateColumnClues(state.grid);

    final Color gridFilled = isDark ? AppColors.gridFilledDark : AppColors.gridFilledLight;
    final Color gridEmpty = isDark ? AppColors.gridEmptyDark : AppColors.gridEmptyLight;
    final Color gridLine = isDark ? AppColors.gridLineDark : AppColors.gridLineLight;
    final Color gridLineThick = isDark ? AppColors.gridLineThickDark : AppColors.gridLineThickLight;
    final Color clueUnresolved = isDark ? AppColors.clueUnresolvedDark : AppColors.clueUnresolvedLight;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _handleBack,
        ),
        title: const Text('Design Nonogram'),
        actions: [
          if (state.isAutoSaved)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_done_outlined, size: 14, color: AppColors.success),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Saved',
                    style: theme.textTheme.labelSmall?.copyWith(color: AppColors.success),
                  ),
                ],
              ),
            ),
          // Overflow menu for destructive actions
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) async {
              if (value == 'reset') {
                final confirm = await NanoDialog.show(
                  context,
                  title: 'Reset Grid?',
                  content: 'This will clear all cells. This action cannot be undone.',
                  confirmLabel: 'Reset',
                  cancelLabel: 'Cancel',
                  isDestructive: true,
                );
                if (confirm == true) notifier.resetGrid();
              } else if (value == 'discard') {
                final confirm = await NanoDialog.show(
                  context,
                  title: 'Discard Draft?',
                  content: 'This will permanently delete your current draft.',
                  confirmLabel: 'Discard',
                  cancelLabel: 'Cancel',
                  isDestructive: true,
                );
                if (confirm == true) await notifier.discardDraft();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'reset', child: Text('Reset Grid')),
              const PopupMenuItem(value: 'discard', child: Text('Discard Draft')),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              top: AppSpacing.sm,
              bottom: 100, // space for floating toolbar
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Board: Clues + Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double totalWidth = constraints.maxWidth;
                    final double rowCluesWidth = totalWidth * 0.22;
                    final double gridWidth = totalWidth * 0.78;
                    final double cellSize = gridWidth / gridSize;
                    final double colCluesHeight = 72;

                    return Column(
                      children: [
                        // Column Clues
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(width: rowCluesWidth),
                            ...List.generate(gridSize, (c) {
                              final List<int> clues = colClues[c];
                              final bool isUnresolved = state.validationResult.unresolvedColumns.contains(c);
                              return SizedBox(
                                width: cellSize,
                                height: colCluesHeight,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: clues.map((val) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 0.5),
                                    child: Text(
                                      '$val',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: isUnresolved
                                            ? clueUnresolved
                                            : colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  )).toList(),
                                ),
                              );
                            }),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),

                        // Row Clues + Grid
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Row clues
                            SizedBox(
                              width: rowCluesWidth,
                              child: Column(
                                children: List.generate(gridSize, (r) {
                                  final List<int> clues = rowClues[r];
                                  final bool isUnresolved = state.validationResult.unresolvedRows.contains(r);
                                  return SizedBox(
                                    height: cellSize,
                                    child: Container(
                                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                                      alignment: Alignment.centerRight,
                                      child: Wrap(
                                        spacing: 2.0,
                                        alignment: WrapAlignment.end,
                                        children: clues.map((val) => Text(
                                          '$val',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: isUnresolved
                                                ? clueUnresolved
                                                : colorScheme.onSurfaceVariant,
                                          ),
                                        )).toList(),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),

                            // Interactive Grid
                            GestureDetector(
                              onPanStart: (d) => _handlePan(d.localPosition, gridWidth, gridSize, notifier),
                              onPanUpdate: (d) => _handlePan(d.localPosition, gridWidth, gridSize, notifier),
                              onPanEnd: (_) => _handlePanEnd(),
                              child: Container(
                                width: gridWidth,
                                height: gridWidth,
                                decoration: BoxDecoration(
                                  border: Border.all(color: gridLineThick, width: 1.5),
                                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                                ),
                                child: GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: gridSize,
                                    crossAxisSpacing: 0,
                                    mainAxisSpacing: 0,
                                  ),
                                  itemCount: gridSize * gridSize,
                                  itemBuilder: (context, index) {
                                    final int r = index ~/ gridSize;
                                    final int c = index % gridSize;
                                    final bool isFilled = state.grid[r][c];

                                    final BorderSide rightBorder = (c + 1) % 5 == 0 && (c + 1) != gridSize
                                        ? BorderSide(color: gridLineThick, width: 1.0)
                                        : BorderSide(color: gridLine, width: 0.5);

                                    final BorderSide bottomBorder = (r + 1) % 5 == 0 && (r + 1) != gridSize
                                        ? BorderSide(color: gridLineThick, width: 1.0)
                                        : BorderSide(color: gridLine, width: 0.5);

                                    return Container(
                                      decoration: BoxDecoration(
                                        color: isFilled ? gridFilled : gridEmpty,
                                        borderRadius: BorderRadius.circular(1.5),
                                        border: Border(
                                          right: rightBorder,
                                          bottom: bottomBorder,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // Title Input
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Puzzle Title',
                    hintText: 'Enter a creative title...',
                  ),
                  onChanged: (title) => notifier.updateTitle(title),
                ),
                const SizedBox(height: AppSpacing.md),

                // Tags Input
                TextField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (comma separated)',
                    hintText: 'pixelart, animal, retro...',
                  ),
                  onChanged: (val) {
                    final tags = val.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                    notifier.updateTags(tags);
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Validation feedback
                if (!state.validationResult.isValid && state.validationResult.errorMessage != null)
                  Container(
                    padding: AppSpacing.cardPadding,
                    decoration: BoxDecoration(
                      color: colorScheme.error.withOpacity(0.06),
                      borderRadius: AppSpacing.borderRadiusMd,
                      border: Border.all(color: colorScheme.error.withOpacity(0.15)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline_rounded, color: colorScheme.error, size: 18),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            state.validationResult.errorMessage!,
                            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.error),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: AppSpacing.lg),

                // Publish button
                NanoButton(
                  label: 'Publish Nonogram',
                  icon: Icons.publish_rounded,
                  isLoading: state.isPublishing,
                  onPressed: (state.validationResult.isValid && !state.isPublishing && currentUser != null)
                      ? () async {
                          final success = await notifier.publishPuzzle(currentUser.uid);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success
                                    ? 'Puzzle published successfully!'
                                    : 'Failed to publish. Please try again.'),
                                backgroundColor: success ? AppColors.success : AppColors.error,
                              ),
                            );
                          }
                        }
                      : null,
                ),
              ],
            ),
          ),

          // Floating Toolbar
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: AppSpacing.borderRadiusXl,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: colorScheme.outlineVariant.withOpacity(0.5),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Difficulty badge
                  NanoDifficultyBadge(difficulty: state.difficulty),
                  const SizedBox(width: AppSpacing.sm),

                  // Undo
                  _ToolbarAction(
                    icon: Icons.undo_rounded,
                    label: 'Undo',
                    onTap: notifier.canUndo ? () => notifier.undo() : null,
                  ),

                  // Redo
                  _ToolbarAction(
                    icon: Icons.redo_rounded,
                    label: 'Redo',
                    onTap: notifier.canRedo ? () => notifier.redo() : null,
                  ),
                ],
              ),
            ),
          ),

          // Publishing overlay
          if (state.isPublishing)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _ToolbarAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ToolbarAction({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isEnabled = onTap != null;

    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppSpacing.borderRadiusSm,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Icon(
              icon,
              size: 22,
              color: isEnabled
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }
}
