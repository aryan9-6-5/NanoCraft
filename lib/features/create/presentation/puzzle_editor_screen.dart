import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/create_puzzle_controller.dart';
import '../../../shared/widgets/scaffold_with_nav_bar.dart';
import '../../authentication/presentation/providers/auth_providers.dart';
import '../../../../shared/utils/clue_generator.dart';

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

    final int gridSize = state.grid.length;
    final rowClues = ClueGenerator.generateRowClues(state.grid);
    final colClues = ClueGenerator.generateColumnClues(state.grid);

    return WillPopScope(
      onWillPop: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard Draft?'),
            content: const Text('Are you sure you want to discard this creation? Unsaved modifications will be lost.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Discard'),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await notifier.discardDraft();
        }
        return confirm ?? false;
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: const Text('Design Nonogram'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Discard Draft?'),
                      content: const Text('Are you sure you want to discard this creation? Unsaved modifications will be lost.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Discard'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await notifier.discardDraft();
                  }
                },
              ),
              actions: [
                if (state.isAutoSaved)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      children: [
                        Icon(Icons.cloud_done_outlined, size: 16, color: Colors.green),
                        SizedBox(width: 4),
                        Text('Saved', style: TextStyle(color: Colors.green, fontSize: 12)),
                      ],
                    ),
                  ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Board Clues and Grid Layout
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double totalWidth = constraints.maxWidth;
                      // Reserve 25% for row clues, 75% for the grid
                      final double rowCluesWidth = totalWidth * 0.25;
                      final double gridWidth = totalWidth * 0.75;
                      final double cellSize = gridWidth / gridSize;
                      // Column clues height: max 5 runs on a 15x15 -> ~80px max height
                      final double colCluesHeight = 80;

                      return Column(
                        children: [
                          // Column Clues row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(width: rowCluesWidth), // spacer
                              ...List.generate(gridSize, (c) {
                                final List<int> clues = colClues[c];
                                final bool isUnresolved = state.validationResult.unresolvedColumns.contains(c);
                                return SizedBox(
                                  width: cellSize,
                                  height: colCluesHeight,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: clues.map((val) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 1.0),
                                      child: Text(
                                        '$val',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isUnresolved ? Colors.redAccent : Colors.grey[400],
                                        ),
                                      ),
                                    )).toList(),
                                  ),
                                );
                              }),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Row Clues + Interactive Grid
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Row Clues
                              SizedBox(
                                width: rowCluesWidth,
                                child: Column(
                                  children: List.generate(gridSize, (r) {
                                    final List<int> clues = rowClues[r];
                                    final bool isUnresolved = state.validationResult.unresolvedRows.contains(r);
                                    return SizedBox(
                                      height: cellSize,
                                      child: Container(
                                        padding: const EdgeInsets.only(right: 8),
                                        alignment: Alignment.centerRight,
                                        child: Wrap(
                                          spacing: 3.0,
                                          alignment: WrapAlignment.end,
                                          children: clues.map((val) => Text(
                                            '$val',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: isUnresolved ? Colors.redAccent : Colors.grey[400],
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
                                onPanStart: (details) => _handlePan(details.localPosition, gridWidth, gridSize, notifier),
                                onPanUpdate: (details) => _handlePan(details.localPosition, gridWidth, gridSize, notifier),
                                onPanEnd: (_) => _handlePanEnd(),
                                child: Container(
                                  width: gridWidth,
                                  height: gridWidth,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade800, width: 2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: GridView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: gridSize,
                                      crossAxisSpacing: 1.0,
                                      mainAxisSpacing: 1.0,
                                    ),
                                    itemCount: gridSize * gridSize,
                                    itemBuilder: (context, index) {
                                      final int r = index ~/ gridSize;
                                      final int c = index % gridSize;
                                      final bool isFilled = state.grid[r][c];

                                      // Draw thick lines every 5 cells for Nonogram legibility
                                      final BorderSide rightBorder = (c + 1) % 5 == 0 && (c + 1) != gridSize
                                          ? BorderSide(color: Colors.grey.shade600, width: 1.5)
                                          : BorderSide(color: Colors.grey.shade800, width: 0.5);

                                      final BorderSide bottomBorder = (r + 1) % 5 == 0 && (r + 1) != gridSize
                                          ? BorderSide(color: Colors.grey.shade600, width: 1.5)
                                          : BorderSide(color: Colors.grey.shade800, width: 0.5);

                                      return Container(
                                        decoration: BoxDecoration(
                                          color: isFilled
                                              ? const Color(0xFF2563EB) // Primary color
                                              : const Color(0xFF1E1E24), // Empty color
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

                  const SizedBox(height: 16),

                  // Difficulty & Controls (Undo / Redo / Reset)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        label: Text(
                          'Difficulty: ${state.difficulty.toUpperCase()}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: const Color(0xFF1E1E24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.undo),
                            onPressed: notifier.canUndo ? () => notifier.undo() : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.redo),
                            onPressed: notifier.canRedo ? () => notifier.redo() : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () => notifier.resetGrid(),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Title & Tags Input Fields
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Puzzle Title',
                      hintText: 'Enter a creative title...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (title) => notifier.updateTitle(title),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _tagsController,
                    decoration: InputDecoration(
                      labelText: 'Tags (comma separated)',
                      hintText: 'pixelart, animal, retro...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (val) {
                      final tags = val.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                      notifier.updateTags(tags);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Validation Message Feedback
                  if (!state.validationResult.isValid && state.validationResult.errorMessage != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.redAccent),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              state.validationResult.errorMessage!,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Publish Action Button
                  ElevatedButton(
                    onPressed: (state.validationResult.isValid && !state.isPublishing && currentUser != null)
                        ? () async {
                            final success = await notifier.publishPuzzle(currentUser.uid);
                            if (success) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Puzzle published successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to publish puzzle. Please try again.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Publish Nonogram', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
          if (state.isPublishing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
