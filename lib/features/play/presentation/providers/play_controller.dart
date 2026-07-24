import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/puzzle.dart';

class PlayState {
  final List<List<bool>> playerGrid;
  final List<List<bool>> playerCrosses;
  final bool isSolved;
  final String activeTool; // 'fill', 'cross', 'eraser'
  final int? activeRow;
  final int? activeCol;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int lives;
  final bool isGameOver;
  final int? errorCellRow;
  final int? errorCellCol;

  PlayState({
    required this.playerGrid,
    required this.playerCrosses,
    this.isSolved = false,
    this.activeTool = 'fill',
    this.activeRow,
    this.activeCol,
    required this.startedAt,
    this.completedAt,
    this.lives = 3,
    this.isGameOver = false,
    this.errorCellRow,
    this.errorCellCol,
  });

  PlayState copyWith({
    List<List<bool>>? playerGrid,
    List<List<bool>>? playerCrosses,
    bool? isSolved,
    String? activeTool,
    int? activeRow,
    int? activeCol,
    DateTime? startedAt,
    DateTime? completedAt,
    int? lives,
    bool? isGameOver,
    int? errorCellRow,
    int? errorCellCol,
    bool clearErrorCell = false,
  }) {
    return PlayState(
      playerGrid: playerGrid ?? this.playerGrid,
      playerCrosses: playerCrosses ?? this.playerCrosses,
      isSolved: isSolved ?? this.isSolved,
      activeTool: activeTool ?? this.activeTool,
      activeRow: activeRow,
      activeCol: activeCol,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      lives: lives ?? this.lives,
      isGameOver: isGameOver ?? this.isGameOver,
      errorCellRow: clearErrorCell ? null : (errorCellRow ?? this.errorCellRow),
      errorCellCol: clearErrorCell ? null : (errorCellCol ?? this.errorCellCol),
    );
  }
}

class PlayNotifier extends Notifier<PlayState> {
  late Puzzle puzzle;
  bool _isInitialized = false;

  final List<List<List<bool>>> _undoGridStack = [];
  final List<List<List<bool>>> _undoCrossStack = [];
  final List<List<List<bool>>> _redoGridStack = [];
  final List<List<List<bool>>> _redoCrossStack = [];

  // Drag stroke tracking
  final Set<String> _visitedCells = {};
  bool _strokeActionValue = true; // true = add/fill, false = remove/clear

  @override
  PlayState build() {
    return PlayState(
      playerGrid: [],
      playerCrosses: [],
      startedAt: DateTime.now(),
    );
  }

  bool get isInitialized => _isInitialized;

  void initialize(Puzzle p) {
    puzzle = p;
    _isInitialized = true;
    _undoGridStack.clear();
    _undoCrossStack.clear();
    _redoGridStack.clear();
    _redoCrossStack.clear();

    state = PlayState(
      playerGrid: List.generate(p.grid.length, (_) => List.filled(p.grid.length, false)),
      playerCrosses: List.generate(p.grid.length, (_) => List.filled(p.grid.length, false)),
      startedAt: DateTime.now(),
      lives: 3,
      isGameOver: false,
    );
  }

  bool get canUndo => _undoGridStack.isNotEmpty;
  bool get canRedo => _redoGridStack.isNotEmpty;

  void setTool(String tool) {
    state = state.copyWith(activeTool: tool);
  }

  void updateActiveCell(int? r, int? c) {
    state = state.copyWith(activeRow: r, activeCol: c);
  }

  // ──────────────── stroke Gameplay Actions ────────────────

  void beginStroke(int r, int c, String tool) {
    if (state.isSolved || state.isGameOver) return;

    // Save state at the beginning of the stroke for a single undo entry
    _saveToUndo();
    _redoGridStack.clear();
    _redoCrossStack.clear();

    _visitedCells.clear();

    // Determine target action value
    if (tool == 'fill') {
      _strokeActionValue = true;
    } else if (tool == 'cross') {
      // If currently crossed, drag removes cross. Otherwise, adds cross.
      _strokeActionValue = !state.playerCrosses[r][c];
    } else if (tool == 'eraser') {
      _strokeActionValue = false; // eraser always removes marks
    }

    _processCellInStroke(r, c, tool);
  }

  void updateStroke(int r, int c, String tool) {
    if (state.isSolved || state.isGameOver) return;
    _processCellInStroke(r, c, tool);
  }

  void endStroke() {
    _visitedCells.clear();
  }

  void _processCellInStroke(int r, int c, String tool) {
    final String key = '${r}_$c';
    if (_visitedCells.contains(key)) return;
    _visitedCells.add(key);

    final grid = state.playerGrid.map((row) => List<bool>.from(row)).toList();
    final crosses = state.playerCrosses.map((row) => List<bool>.from(row)).toList();
    int newLives = state.lives;

    final targetSolutionValue = puzzle.grid[r][c];

    if (tool == 'fill') {
      // Fill tool only places fills
      if (grid[r][c]) return; // already filled

      if (targetSolutionValue) {
        // Correct fill
        grid[r][c] = true;
        crosses[r][c] = false;
      } else {
        // Mistake! Target cell should be empty. Decrement life and trigger error flash
        newLives--;
        _triggerErrorFlash(r, c);
      }
    } else if (tool == 'cross') {
      // Cross tool places or removes crosses. Never consumes lives.
      if (_strokeActionValue) {
        if (!crosses[r][c]) {
          crosses[r][c] = true;
          grid[r][c] = false;
        }
      } else {
        crosses[r][c] = false;
      }
    } else if (tool == 'eraser') {
      // Eraser removes all user marks. Never consumes lives.
      grid[r][c] = false;
      crosses[r][c] = false;
    }

    _updateState(grid, crosses, newLives);
  }

  void _triggerErrorFlash(int r, int c) {
    state = state.copyWith(errorCellRow: r, errorCellCol: c);
    Timer(const Duration(milliseconds: 600), () {
      if (state.errorCellRow == r && state.errorCellCol == c) {
        state = state.copyWith(clearErrorCell: true);
      }
    });
  }

  // Legacy fallback compatibility methods
  void toggleCell(int r, int c) {
    beginStroke(r, c, state.activeTool);
    endStroke();
  }

  void fillCellDrag(int r, int c, bool value, String tool) {
    updateStroke(r, c, tool);
  }

  // ──────────────── Undo / Redo ────────────────

  void undo() {
    if (!canUndo) return;

    _redoGridStack.add(state.playerGrid.map((row) => List<bool>.from(row)).toList());
    _redoCrossStack.add(state.playerCrosses.map((row) => List<bool>.from(row)).toList());

    final prevGrid = _undoGridStack.removeLast();
    final prevCrosses = _undoCrossStack.removeLast();

    state = state.copyWith(
      playerGrid: prevGrid,
      playerCrosses: prevCrosses,
    );
  }

  void redo() {
    if (!canRedo) return;

    _undoGridStack.add(state.playerGrid.map((row) => List<bool>.from(row)).toList());
    _undoCrossStack.add(state.playerCrosses.map((row) => List<bool>.from(row)).toList());

    final nextGrid = _redoGridStack.removeLast();
    final nextCrosses = _redoCrossStack.removeLast();

    state = state.copyWith(
      playerGrid: nextGrid,
      playerCrosses: nextCrosses,
    );
  }

  void useHint() {
    if (state.isSolved || state.isGameOver) return;

    final target = puzzle.grid;
    final current = state.playerGrid;

    for (int r = 0; r < target.length; r++) {
      for (int c = 0; c < target[r].length; c++) {
        if (current[r][c] != target[r][c]) {
          _saveToUndo();
          final grid = current.map((row) => List<bool>.from(row)).toList();
          final crosses = state.playerCrosses.map((row) => List<bool>.from(row)).toList();

          grid[r][c] = target[r][c];
          crosses[r][c] = false;

          _updateState(grid, crosses, state.lives);
          return;
        }
      }
    }
  }

  void reset() {
    _saveToUndo();
    final size = puzzle.grid.length;
    state = state.copyWith(
      playerGrid: List.generate(size, (_) => List.filled(size, false)),
      playerCrosses: List.generate(size, (_) => List.filled(size, false)),
      isSolved: false,
      lives: 3,
      isGameOver: false,
      clearErrorCell: true,
    );
  }

  void _saveToUndo() {
    _undoGridStack.add(state.playerGrid.map((row) => List<bool>.from(row)).toList());
    _undoCrossStack.add(state.playerCrosses.map((row) => List<bool>.from(row)).toList());
    if (_undoGridStack.length > 50) {
      _undoGridStack.removeAt(0);
      _undoCrossStack.removeAt(0);
    }
  }

  void _updateState(List<List<bool>> grid, List<List<bool>> crosses, int newLives) {
    final solved = _checkSolved(grid);
    final gameOver = newLives <= 0;
    state = state.copyWith(
      playerGrid: grid,
      playerCrosses: crosses,
      isSolved: solved,
      lives: newLives.clamp(0, 3),
      isGameOver: gameOver,
      completedAt: (solved || gameOver) ? DateTime.now() : null,
    );
  }

  bool _checkSolved(List<List<bool>> grid) {
    final target = puzzle.grid;
    for (int r = 0; r < target.length; r++) {
      for (int c = 0; c < target[r].length; c++) {
        if (grid[r][c] != target[r][c]) {
          return false;
        }
      }
    }
    return true;
  }

  Future<void> saveSolveToFirestore(String userId) async {
    try {
      final now = DateTime.now();
      
      // Increment solved count in users doc
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'solvedLevels': FieldValue.increment(1),
        'updatedAt': Timestamp.fromDate(now),
      });

      // Track the play attempt
      final playId = FirebaseFirestore.instance.collection('plays').doc().id;
      await FirebaseFirestore.instance.collection('plays').doc(playId).set({
        'playId': playId,
        'userId': userId,
        'levelId': puzzle.levelId,
        'startedAt': Timestamp.fromDate(state.startedAt),
        'completedAt': Timestamp.fromDate(state.completedAt ?? now),
        'durationSeconds': (state.completedAt ?? now).difference(state.startedAt).inSeconds,
      });
    } catch (e) {
      print('Failed to save play solve to Firestore: $e');
    }
  }
}

final playProvider = NotifierProvider<PlayNotifier, PlayState>(() {
  return PlayNotifier();
});
