import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/puzzle.dart';

class PlayState {
  final List<List<bool>> playerGrid;
  final List<List<bool>> playerCrosses;
  final bool isSolved;
  final String activeTool; // 'fill' or 'cross'
  final int? activeRow;
  final int? activeCol;
  final DateTime startedAt;
  final DateTime? completedAt;

  PlayState({
    required this.playerGrid,
    required this.playerCrosses,
    this.isSolved = false,
    this.activeTool = 'fill',
    this.activeRow,
    this.activeCol,
    required this.startedAt,
    this.completedAt,
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
  }) {
    return PlayState(
      playerGrid: playerGrid ?? this.playerGrid,
      playerCrosses: playerCrosses ?? this.playerCrosses,
      isSolved: isSolved ?? this.isSolved,
      activeTool: activeTool ?? this.activeTool,
      activeRow: activeRow, // Nullable to clear highlights
      activeCol: activeCol,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
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

  void toggleCell(int r, int c) {
    if (state.isSolved) return;

    _saveToUndo();
    _redoGridStack.clear();
    _redoCrossStack.clear();

    final grid = state.playerGrid.map((row) => List<bool>.from(row)).toList();
    final crosses = state.playerCrosses.map((row) => List<bool>.from(row)).toList();

    if (state.activeTool == 'fill') {
      grid[r][c] = !grid[r][c];
      if (grid[r][c]) {
        crosses[r][c] = false; // clear cross if filled
      }
    } else {
      crosses[r][c] = !crosses[r][c];
      if (crosses[r][c]) {
        grid[r][c] = false; // clear fill if crossed
      }
    }

    _updateState(grid, crosses);
  }

  void fillCellDrag(int r, int c, bool value, String tool) {
    if (state.isSolved) return;

    final grid = state.playerGrid.map((row) => List<bool>.from(row)).toList();
    final crosses = state.playerCrosses.map((row) => List<bool>.from(row)).toList();

    if (tool == 'fill') {
      if (grid[r][c] == value) return;
      _saveToUndo();
      _redoGridStack.clear();
      _redoCrossStack.clear();
      grid[r][c] = value;
      if (value) crosses[r][c] = false;
    } else {
      if (crosses[r][c] == value) return;
      _saveToUndo();
      _redoGridStack.clear();
      _redoCrossStack.clear();
      crosses[r][c] = value;
      if (value) grid[r][c] = false;
    }

    _updateState(grid, crosses);
  }

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

    _undoStackPush();
    final nextGrid = _redoGridStack.removeLast();
    final nextCrosses = _redoCrossStack.removeLast();

    state = state.copyWith(
      playerGrid: nextGrid,
      playerCrosses: nextCrosses,
    );
  }

  void _undoStackPush() {
    _undoGridStack.add(state.playerGrid.map((row) => List<bool>.from(row)).toList());
    _undoCrossStack.add(state.playerCrosses.map((row) => List<bool>.from(row)).toList());
  }

  void useHint() {
    if (state.isSolved) return;

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

          _updateState(grid, crosses);
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

  void _updateState(List<List<bool>> grid, List<List<bool>> crosses) {
    final solved = _checkSolved(grid);
    state = state.copyWith(
      playerGrid: grid,
      playerCrosses: crosses,
      isSolved: solved,
      completedAt: solved ? DateTime.now() : null,
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
