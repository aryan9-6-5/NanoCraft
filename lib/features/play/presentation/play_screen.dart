import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_spacing.dart';
import '../../../shared/widgets/nano_button.dart';
import '../../../shared/widgets/nano_dialog.dart';
import '../../authentication/presentation/providers/auth_providers.dart';
import '../../../../shared/utils/clue_generator.dart';
import 'providers/level_providers.dart';
import 'providers/play_controller.dart';

class PlayScreen extends ConsumerStatefulWidget {
  final String levelId;

  const PlayScreen({super.key, required this.levelId});

  @override
  ConsumerState<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends ConsumerState<PlayScreen> {
  int? _lastToggledRow;
  int? _lastToggledCol;
  bool? _isDrawingActive;
  bool _isSuccessDialogShown = false;

  void _handlePan(
    Offset localPosition,
    double gridWidth,
    int gridSize,
    PlayState playState,
    PlayNotifier notifier,
  ) {
    final double cellSize = gridWidth / gridSize;
    final int c = (localPosition.dx / cellSize).floor().clamp(0, gridSize - 1);
    final int r = (localPosition.dy / cellSize).floor().clamp(0, gridSize - 1);

    // Update active highlight coordinates
    notifier.updateActiveCell(r, c);

    if (r == _lastToggledRow && c == _lastToggledCol) return;

    setState(() {
      _lastToggledRow = r;
      _lastToggledCol = c;
    });

    if (_isDrawingActive == null) {
      if (playState.activeTool == 'fill') {
        _isDrawingActive = !playState.playerGrid[r][c];
      } else {
        _isDrawingActive = !playState.playerCrosses[r][c];
      }
    }

    notifier.fillCellDrag(r, c, _isDrawingActive!, playState.activeTool);
  }

  void _handlePanEnd(PlayNotifier notifier) {
    setState(() {
      _lastToggledRow = null;
      _lastToggledCol = null;
      _isDrawingActive = null;
    });
    notifier.updateActiveCell(null, null);
  }

  bool _isRowCompleted(List<bool> row, List<int> clues) {
    final generated = ClueGenerator.generateRowClues([row])[0];
    if (generated.length != clues.length) return false;
    for (int i = 0; i < clues.length; i++) {
      if (generated[i] != clues[i]) return false;
    }
    return true;
  }

  bool _isColCompleted(List<List<bool>> grid, int colIndex, List<int> clues) {
    final List<bool> col = grid.map((row) => row[colIndex]).toList();
    final generated = ClueGenerator.generateRowClues([col])[0];
    if (generated.length != clues.length) return false;
    for (int i = 0; i < clues.length; i++) {
      if (generated[i] != clues[i]) return false;
    }
    return true;
  }

  void _showSuccessDialog(BuildContext context, String title, PlayState playState, PlayNotifier notifier) async {
    if (_isSuccessDialogShown) return;
    _isSuccessDialogShown = true;

    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser != null) {
      await notifier.saveSolveToFirestore(currentUser.uid);
    }

    if (!mounted) return;

    final duration = DateTime.now().difference(playState.startedAt);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final timeStr = minutes > 0 ? '$minutes min $seconds sec' : '$seconds sec';

    final isRound = widget.levelId.contains('_round_');
    String? nextRoundId;
    bool hasNextRound = false;

    if (isRound) {
      final parts = widget.levelId.split('_round_');
      final baseId = parts[0];
      final currentRound = int.tryParse(parts[1]) ?? 1;
      nextRoundId = '${baseId}_round_${currentRound + 1}';

      try {
        final doc = await FirebaseFirestore.instance
            .collection('levels')
            .doc(nextRoundId)
            .get();
        hasNextRound = doc.exists;
      } catch (e) {
        print('Error checking next round: $e');
      }
    }

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.stars_rounded, color: AppColors.success, size: 28),
            const SizedBox(width: AppSpacing.sm),
            const Text('Puzzle Solved!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Congratulations! You solved "$title" successfully.', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Time Taken:'),
                Text(timeStr, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        actions: [
          if (hasNextRound && nextRoundId != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.pushReplacement('/play/$nextRoundId');
              },
              child: const Text('Play Next Round'),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/home');
            },
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final levelAsync = ref.watch(levelDetailsProvider(widget.levelId));
    final puzzleAsync = ref.watch(puzzleDetailsProvider(widget.levelId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Check if both level and puzzle details are loaded
    return levelAsync.when(
      data: (level) {
        if (level == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Level metadata not found.')),
          );
        }

        return puzzleAsync.when(
          data: (puzzle) {
            if (puzzle == null) {
              return Scaffold(
                appBar: AppBar(title: Text(level.title)),
                body: const Center(child: Text('Puzzle grid data not found.')),
              );
            }

            final playState = ref.watch(playProvider);
            final notifier = ref.read(playProvider.notifier);

            // Initialize the notifier if it is not initialized yet or if it has a different puzzle
            if (!notifier.isInitialized || notifier.puzzle.levelId != puzzle.levelId) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                notifier.initialize(puzzle);
              });
              return Scaffold(
                appBar: AppBar(title: Text(level.title)),
                body: const Center(child: CircularProgressIndicator()),
              );
            }

            // Listen for solve state to trigger the success dialog
            if (playState.isSolved && !_isSuccessDialogShown) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showSuccessDialog(context, level.title, playState, notifier);
              });
            }

            final int gridSize = puzzle.grid.length;
            final Color gridFilled = isDark ? AppColors.gridFilledDark : AppColors.gridFilledLight;
            final Color gridEmpty = isDark ? AppColors.gridEmptyDark : AppColors.gridEmptyLight;
            final Color gridLine = isDark ? AppColors.gridLineDark : AppColors.gridLineLight;
            final Color gridLineThick = isDark ? AppColors.gridLineThickDark : AppColors.gridLineThickLight;
            final Color clueCompleted = isDark ? AppColors.clueCompletedDark : AppColors.clueCompletedLight;

            return Scaffold(
              appBar: AppBar(
                title: Text(level.title),
                actions: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded),
                    onSelected: (value) async {
                      if (value == 'reset') {
                        final confirm = await NanoDialog.show(
                          context,
                          title: 'Reset Game?',
                          content: 'Are you sure you want to clear your current progress?',
                          confirmLabel: 'Clear',
                          cancelLabel: 'Cancel',
                          isDestructive: true,
                        );
                        if (confirm == true) {
                          notifier.reset();
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'reset', child: Text('Reset Board')),
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
                      bottom: 100, // floating action bar spacer
                    ),
                    child: Column(
                      children: [
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
                                      final List<int> clues = puzzle.columnClues[c];
                                      final isCompleted = _isColCompleted(playState.playerGrid, c, clues);
                                      final isHighlighted = playState.activeCol == c;

                                      return Container(
                                        width: cellSize,
                                        height: colCluesHeight,
                                        color: isHighlighted
                                            ? colorScheme.primary.withOpacity(0.06)
                                            : Colors.transparent,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: clues.map((val) => Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 0.5),
                                            child: Text(
                                              '$val',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: isCompleted
                                                    ? clueCompleted
                                                    : (isHighlighted ? colorScheme.primary : colorScheme.onSurfaceVariant),
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
                                    // Row Clues
                                    SizedBox(
                                      width: rowCluesWidth,
                                      child: Column(
                                        children: List.generate(gridSize, (r) {
                                          final List<int> clues = puzzle.rowClues[r];
                                          final isCompleted = _isRowCompleted(playState.playerGrid[r], clues);
                                          final isHighlighted = playState.activeRow == r;

                                          return Container(
                                            height: cellSize,
                                            color: isHighlighted
                                                ? colorScheme.primary.withOpacity(0.06)
                                                : Colors.transparent,
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
                                                  color: isCompleted
                                                      ? clueCompleted
                                                      : (isHighlighted ? colorScheme.primary : colorScheme.onSurfaceVariant),
                                                ),
                                              )).toList(),
                                            ),
                                          );
                                        }),
                                      ),
                                    ),

                                    // Interactive Board Grid
                                    GestureDetector(
                                      onPanStart: (d) => _handlePan(d.localPosition, gridWidth, gridSize, playState, notifier),
                                      onPanUpdate: (d) => _handlePan(d.localPosition, gridWidth, gridSize, playState, notifier),
                                      onPanEnd: (_) => _handlePanEnd(notifier),
                                      onTapDown: (details) {
                                        final double localX = details.localPosition.dx;
                                        final double localY = details.localPosition.dy;
                                        final int c = (localX / cellSize).floor().clamp(0, gridSize - 1);
                                        final int r = (localY / cellSize).floor().clamp(0, gridSize - 1);
                                        notifier.toggleCell(r, c);
                                      },
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
                                            final bool isFilled = playState.playerGrid[r][c];
                                            final bool isCrossed = playState.playerCrosses[r][c];

                                            final BorderSide rightBorder = (c + 1) % 5 == 0 && (c + 1) != gridSize
                                                ? BorderSide(color: gridLineThick, width: 1.0)
                                                : BorderSide(color: gridLine, width: 0.5);

                                            final BorderSide bottomBorder = (r + 1) % 5 == 0 && (r + 1) != gridSize
                                                ? BorderSide(color: gridLineThick, width: 1.0)
                                                : BorderSide(color: gridLine, width: 0.5);

                                            // Determine cursor highlight overlay
                                            final bool isCrossHighlighted = playState.activeRow == r || playState.activeCol == c;

                                            return Container(
                                              decoration: BoxDecoration(
                                                color: isFilled
                                                    ? gridFilled
                                                    : (isCrossHighlighted
                                                        ? colorScheme.primary.withOpacity(0.04)
                                                        : gridEmpty),
                                                border: Border(
                                                  right: rightBorder,
                                                  bottom: bottomBorder,
                                                ),
                                              ),
                                              child: isCrossed
                                                  ? Center(
                                                      child: Icon(
                                                        Icons.close_rounded,
                                                        size: cellSize * 0.7,
                                                        color: isDark ? AppColors.gridCrossDark : AppColors.gridCrossLight,
                                                      ),
                                                    )
                                                  : null,
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
                      ],
                    ),
                  ),

                  // Floating Toolbar controls
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Tool Toggles: Fill Pen vs Cross
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ToolToggle(
                                icon: Icons.brush_rounded,
                                isSelected: playState.activeTool == 'fill',
                                onTap: () => notifier.setTool('fill'),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              _ToolToggle(
                                icon: Icons.close_rounded,
                                isSelected: playState.activeTool == 'cross',
                                onTap: () => notifier.setTool('cross'),
                              ),
                            ],
                          ),

                          const VerticalDivider(width: 1, thickness: 1),

                          // Gameplay Actions: Undo / Redo / Hint
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ToolbarAction(
                                icon: Icons.undo_rounded,
                                label: 'Undo',
                                onTap: notifier.canUndo ? () => notifier.undo() : null,
                              ),
                              _ToolbarAction(
                                icon: Icons.redo_rounded,
                                label: 'Redo',
                                onTap: notifier.canRedo ? () => notifier.redo() : null,
                              ),
                              _ToolbarAction(
                                icon: Icons.lightbulb_outline_rounded,
                                label: 'Hint',
                                onTap: () => notifier.useHint(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (err, stack) => Scaffold(
            body: Center(child: Text('Error loading puzzle data: $err')),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Error loading level data: $err')),
      ),
    );
  }
}

class _ToolToggle extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToolToggle({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: isSelected ? colorScheme.primary : Colors.transparent,
      borderRadius: AppSpacing.borderRadiusMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusMd,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm + 2),
          child: Icon(
            icon,
            size: 20,
            color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
          ),
        ),
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
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
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
