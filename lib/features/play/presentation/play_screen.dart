import 'dart:async';
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
  bool _isSuccessDialogShown = false;
  bool _isGameOverDialogShown = false;

  Timer? _gameTimer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _elapsedSeconds = 0;
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        final playState = ref.read(playProvider);
        if (ref.read(playProvider.notifier).isInitialized && !playState.isSolved && !playState.isGameOver) {
          setState(() {
            _elapsedSeconds++;
          });
        }
      }
    });
  }

  void _interpolateAndStroke(
    int r0,
    int c0,
    int r1,
    int c1,
    PlayNotifier notifier,
    String tool,
  ) {
    int dr = (r1 - r0).abs();
    int dc = (c1 - c0).abs();
    int sr = r0 < r1 ? 1 : -1;
    int sc = c0 < c1 ? 1 : -1;
    int err = dr - dc;

    int r = r0;
    int c = c0;

    while (true) {
      notifier.updateStroke(r, c, tool);

      if (r == r1 && c == c1) break;
      int e2 = 2 * err;
      if (e2 > -dc) {
        err -= dc;
        r += sr;
      }
      if (e2 < dr) {
        err += dr;
        c += sc;
      }
    }
  }

  void _handlePanStart(
    Offset localPosition,
    double gridWidth,
    int gridSize,
    PlayState playState,
    PlayNotifier notifier,
  ) {
    final double cellSize = gridWidth / gridSize;
    final int c = (localPosition.dx / cellSize).floor().clamp(0, gridSize - 1);
    final int r = (localPosition.dy / cellSize).floor().clamp(0, gridSize - 1);

    setState(() {
      _lastToggledRow = r;
      _lastToggledCol = c;
    });

    notifier.updateActiveCell(r, c);
    notifier.beginStroke(r, c, playState.activeTool);
  }

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

    notifier.updateActiveCell(r, c);

    if (_lastToggledRow == null || _lastToggledCol == null) {
      _handlePanStart(localPosition, gridWidth, gridSize, playState, notifier);
    } else if (r != _lastToggledRow || c != _lastToggledCol) {
      _interpolateAndStroke(
        _lastToggledRow!,
        _lastToggledCol!,
        r,
        c,
        notifier,
        playState.activeTool,
      );
      setState(() {
        _lastToggledRow = r;
        _lastToggledCol = c;
      });
    }
  }

  void _handlePanEnd(PlayNotifier notifier) {
    setState(() {
      _lastToggledRow = null;
      _lastToggledCol = null;
    });
    notifier.updateActiveCell(null, null);
    notifier.endStroke();
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

  void _showGameOverDialog(BuildContext context, String title, PlayNotifier notifier) async {
    if (_isGameOverDialogShown) return;
    _isGameOverDialogShown = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sentiment_very_dissatisfied_rounded, color: AppColors.error, size: 36),
            const SizedBox(width: AppSpacing.sm),
            const Text('Game Over', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) => const Icon(Icons.star_rounded, color: Colors.grey, size: 40)),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'You ran out of lives on "$title". Try again to solve it!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isGameOverDialogShown = false;
                _isSuccessDialogShown = false;
              });
              notifier.reset();
              _startTimer();
            },
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isGameOverDialogShown = false;
                _isSuccessDialogShown = false;
              });
              context.go('/home');
            },
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
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

    final int stars = playState.lives;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Column(
          children: [
            const Icon(Icons.stars_rounded, color: AppColors.success, size: 48),
            const SizedBox(height: AppSpacing.xs),
            const Text('Puzzle Solved!', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final isStarWon = index < stars;
                return Icon(
                  Icons.star_rounded,
                  color: isStarWon ? Colors.amber : Colors.grey.shade300,
                  size: 44,
                );
              }),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Congratulations! You solved "$title" successfully.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Time Taken:'),
                Text(timeStr, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Lives Remaining:'),
                Text('$stars/3', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
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

            // Listen for Game Over state to trigger the failure dialog
            if (playState.isGameOver && !_isGameOverDialogShown) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showGameOverDialog(context, level.title, notifier);
              });
            }

            final int gridSize = puzzle.grid.length;
            final Color gridFilled = isDark ? AppColors.gridFilledDark : AppColors.gridFilledLight;
            final Color gridEmpty = isDark ? AppColors.gridEmptyDark : AppColors.gridEmptyLight;
            final Color gridLine = isDark ? AppColors.gridLineDark : AppColors.gridLineLight;
            final Color gridLineThick = isDark ? AppColors.gridLineThickDark : AppColors.gridLineThickLight;
            final Color clueCompleted = isDark ? AppColors.clueCompletedDark : AppColors.clueCompletedLight;

            final int minutes = _elapsedSeconds ~/ 60;
            final int seconds = _elapsedSeconds % 60;
            final String timerStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

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
                          _startTimer();
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
                        // HUD Dashboard Banner
                        Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.outlineVariant.withOpacity(0.5),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Remaining Lives
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.favorite_rounded, color: Colors.red, size: 20),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${playState.lives}/3',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ],
                              ),

                              // Stars Indicator
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(3, (index) {
                                  final isStarWon = index < playState.lives;
                                  return Icon(
                                    Icons.star_rounded,
                                    color: isStarWon ? Colors.amber : colorScheme.onSurface.withOpacity(0.2),
                                    size: 24,
                                  );
                                }),
                              ),

                              // Live Game Timer
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.timer_rounded, size: 20),
                                  const SizedBox(width: 4),
                                  Text(
                                    timerStr,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

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
                                            final bool isErrorCell = playState.errorCellRow == r && playState.errorCellCol == c;

                                            return Container(
                                              decoration: BoxDecoration(
                                                color: isErrorCell
                                                    ? colorScheme.error.withOpacity(0.8)
                                                    : (isFilled
                                                        ? gridFilled
                                                        : (isCrossHighlighted
                                                            ? colorScheme.primary.withOpacity(0.04)
                                                            : gridEmpty)),
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
                                                  : (isErrorCell
                                                      ? Center(
                                                          child: Icon(
                                                            Icons.error_outline_rounded,
                                                            size: cellSize * 0.7,
                                                            color: Colors.white,
                                                          ),
                                                        )
                                                      : null),
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
                          // Tool Toggles: Fill Pen vs Cross vs Eraser
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
                              const SizedBox(width: AppSpacing.xs),
                              _ToolToggle(
                                icon: Icons.delete_outline_rounded,
                                isSelected: playState.activeTool == 'eraser',
                                onTap: () => notifier.setTool('eraser'),
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
