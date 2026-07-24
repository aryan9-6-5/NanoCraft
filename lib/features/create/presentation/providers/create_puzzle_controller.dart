import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/utils/clue_generator.dart';
import '../../../../shared/utils/difficulty_calculator.dart';
import '../../../../shared/utils/image_processor.dart';
import '../../../../shared/utils/line_solver.dart';
import '../../../../shared/utils/puzzle_validator.dart';
import '../../../play/domain/entities/level.dart';
import '../../../play/domain/entities/puzzle.dart';
import '../../data/services/draft_service.dart';

enum CreateStep { selectMethod, imagePreprocess, puzzleEditor }

class CreatePuzzleState {
  final List<List<bool>> grid;
  final String title;
  final List<String> tags;
  final String difficulty;
  final double difficultyScore;
  final List<List<int>>? grayscaleGrid;
  final double threshold;
  final PuzzleValidationResult validationResult;
  final bool isAutoSaved;
  final String type; // 'image' or 'text'
  final bool isPublishing;
  final CreateStep step;

  const CreatePuzzleState({
    required this.grid,
    required this.title,
    required this.tags,
    required this.difficulty,
    required this.difficultyScore,
    this.grayscaleGrid,
    required this.threshold,
    required this.validationResult,
    required this.isAutoSaved,
    required this.type,
    required this.isPublishing,
    required this.step,
  });

  CreatePuzzleState copyWith({
    List<List<bool>>? grid,
    String? title,
    List<String>? tags,
    String? difficulty,
    double? difficultyScore,
    List<List<int>>? grayscaleGrid,
    double? threshold,
    PuzzleValidationResult? validationResult,
    bool? isAutoSaved,
    String? type,
    bool? isPublishing,
    CreateStep? step,
  }) {
    return CreatePuzzleState(
      grid: grid ?? this.grid,
      title: title ?? this.title,
      tags: tags ?? this.tags,
      difficulty: difficulty ?? this.difficulty,
      difficultyScore: difficultyScore ?? this.difficultyScore,
      grayscaleGrid: grayscaleGrid ?? this.grayscaleGrid,
      threshold: threshold ?? this.threshold,
      validationResult: validationResult ?? this.validationResult,
      isAutoSaved: isAutoSaved ?? this.isAutoSaved,
      type: type ?? this.type,
      isPublishing: isPublishing ?? this.isPublishing,
      step: step ?? this.step,
    );
  }
}

class CreatePuzzleNotifier extends Notifier<CreatePuzzleState> {
  late final DraftService _draftService;

  final List<List<List<bool>>> _undoStack = [];
  final List<List<List<bool>>> _redoStack = [];

  @override
  CreatePuzzleState build() {
    _draftService = DraftService();
    return CreatePuzzleState(
      grid: List.generate(15, (_) => List.filled(15, false)),
      title: '',
      tags: [],
      difficulty: 'easy',
      difficultyScore: 0.0,
      threshold: 0.5,
      validationResult: const PuzzleValidationResult(isValid: false),
      isAutoSaved: false,
      type: 'image',
      isPublishing: false,
      step: CreateStep.selectMethod,
    );
  }

  void changeStep(CreateStep step) {
    state = state.copyWith(step: step);
  }

  void initNewImagePuzzle(List<List<int>> grayscaleGrid) {
    _undoStack.clear();
    _redoStack.clear();

    final booleanGrid = ImageProcessor.applyThreshold(grayscaleGrid, 0.5);
    final diff = DifficultyCalculator.calculateDifficulty(
      booleanGrid,
      ClueGenerator.generateRowClues(booleanGrid),
      ClueGenerator.generateColumnClues(booleanGrid),
    );
    final val = PuzzleValidator.validatePuzzle(booleanGrid);

    state = CreatePuzzleState(
      grid: booleanGrid,
      title: '',
      tags: [],
      difficulty: diff.label,
      difficultyScore: diff.score,
      grayscaleGrid: grayscaleGrid,
      threshold: 0.5,
      validationResult: val,
      isAutoSaved: false,
      type: 'image',
      isPublishing: false,
      step: CreateStep.imagePreprocess,
    );
  }

  void updateThreshold(double val) {
    if (state.grayscaleGrid == null) return;

    final booleanGrid = ImageProcessor.applyThreshold(state.grayscaleGrid!, val);
    final diff = DifficultyCalculator.calculateDifficulty(
      booleanGrid,
      ClueGenerator.generateRowClues(booleanGrid),
      ClueGenerator.generateColumnClues(booleanGrid),
    );
    final validation = PuzzleValidator.validatePuzzle(booleanGrid);

    state = state.copyWith(
      grid: booleanGrid,
      threshold: val,
      difficulty: diff.label,
      difficultyScore: diff.score,
      validationResult: validation,
    );
  }

  void toggleCell(int r, int c) {
    _pushUndo(state.grid);
    _redoStack.clear();

    final newGrid = state.grid.map((row) => List<bool>.from(row)).toList();
    newGrid[r][c] = !newGrid[r][c];

    _updateGridState(newGrid);
  }

  void fillCell(int r, int c, bool fill) {
    if (state.grid[r][c] == fill) return;

    _pushUndo(state.grid);
    _redoStack.clear();

    final newGrid = state.grid.map((row) => List<bool>.from(row)).toList();
    newGrid[r][c] = fill;

    _updateGridState(newGrid);
  }

  void resetGrid() {
    _pushUndo(state.grid);
    _redoStack.clear();

    final size = state.grid.length;
    final newGrid = List.generate(size, (_) => List.filled(size, false));

    _updateGridState(newGrid);
  }

  void updateTitle(String title) {
    state = state.copyWith(title: title);
    _triggerAutoSave();
  }

  void updateTags(List<String> tags) {
    state = state.copyWith(tags: tags);
    _triggerAutoSave();
  }

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  void undo() {
    if (_undoStack.isEmpty) return;
    final prev = _undoStack.removeLast();
    _redoStack.add(state.grid.map((row) => List<bool>.from(row)).toList());
    _updateGridState(prev, triggerAutoSave: true);
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    final next = _redoStack.removeLast();
    _undoStack.add(state.grid.map((row) => List<bool>.from(row)).toList());
    _updateGridState(next, triggerAutoSave: true);
  }

  void _pushUndo(List<List<bool>> grid) {
    _undoStack.add(grid.map((row) => List<bool>.from(row)).toList());
    if (_undoStack.length > 20) {
      _undoStack.removeAt(0);
    }
  }

  void _updateGridState(List<List<bool>> newGrid, {bool triggerAutoSave = true}) {
    final diff = DifficultyCalculator.calculateDifficulty(
      newGrid,
      ClueGenerator.generateRowClues(newGrid),
      ClueGenerator.generateColumnClues(newGrid),
    );
    final val = PuzzleValidator.validatePuzzle(newGrid);

    state = state.copyWith(
      grid: newGrid,
      difficulty: diff.label,
      difficultyScore: diff.score,
      validationResult: val,
    );

    if (triggerAutoSave) {
      _triggerAutoSave();
    }
  }

  void _triggerAutoSave() async {
    final map = {
      'grid': state.grid,
      'title': state.title,
      'tags': state.tags,
      'type': state.type,
      'threshold': state.threshold,
      'grayscaleGrid': state.grayscaleGrid,
      'lastModified': DateTime.now().millisecondsSinceEpoch,
    };
    await _draftService.saveDraft(map);
    state = state.copyWith(isAutoSaved: true);
  }

  Future<void> discardDraft() async {
    await _draftService.clearDraft();
    _undoStack.clear();
    _redoStack.clear();
    state = CreatePuzzleState(
      grid: List.generate(15, (_) => List.filled(15, false)),
      title: '',
      tags: [],
      difficulty: 'easy',
      difficultyScore: 0.0,
      threshold: 0.5,
      validationResult: const PuzzleValidationResult(isValid: false),
      isAutoSaved: false,
      type: 'image',
      isPublishing: false,
      step: CreateStep.selectMethod,
    );
  }

  Future<bool> loadLatestDraft() async {
    final draft = await _draftService.loadLatestDraft();
    if (draft == null) return false;

    try {
      final type = draft['type'] as String? ?? 'image';
      final title = draft['title'] as String? ?? '';
      final tags = List<String>.from(draft['tags'] ?? []);
      final threshold = draft['threshold'] as double? ?? 0.5;

      final gridRaw = draft['grid'] as List;
      final grid = gridRaw.map((row) => List<bool>.from(row as List)).toList();

      List<List<int>>? grayscaleGrid;
      if (draft['grayscaleGrid'] != null) {
        final grayRaw = draft['grayscaleGrid'] as List;
        grayscaleGrid = grayRaw.map((row) => List<int>.from(row as List)).toList();
      }

      final diff = DifficultyCalculator.calculateDifficulty(
        grid,
        ClueGenerator.generateRowClues(grid),
        ClueGenerator.generateColumnClues(grid),
      );
      final val = PuzzleValidator.validatePuzzle(grid);

      _undoStack.clear();
      _redoStack.clear();

      state = CreatePuzzleState(
        grid: grid,
        title: title,
        tags: tags,
        difficulty: diff.label,
        difficultyScore: diff.score,
        grayscaleGrid: grayscaleGrid,
        threshold: threshold,
        validationResult: val,
        isAutoSaved: true,
        type: type,
        isPublishing: false,
        step: CreateStep.puzzleEditor,
      );
      return true;
    } catch (e) {
      print('Failed to restore draft: $e');
      return false;
    }
  }

  Future<bool> publishPuzzle(String userId) async {
    if (!state.validationResult.isValid) return false;

    state = state.copyWith(isPublishing: true);

    try {
      final now = DateTime.now();
      final levelId = FirebaseFirestore.instance.collection('levels').doc().id;

      // 1. Create Level metadata
      final level = Level(
        levelId: levelId,
        creatorId: userId,
        title: state.title.trim().isEmpty ? 'Untitled Nonogram' : state.title.trim(),
        type: state.type,
        gridSize: state.grid.length,
        difficulty: state.difficulty,
        difficultyScore: state.difficultyScore,
        likes: 0,
        plays: 0,
        tags: state.tags,
        createdAt: now,
      );

      // 2. Create Puzzle data (clues + grid solution)
      final rowClues = ClueGenerator.generateRowClues(state.grid);
      final colClues = ClueGenerator.generateColumnClues(state.grid);
      final puzzle = Puzzle(
        levelId: levelId,
        grid: state.grid,
        rowClues: rowClues,
        columnClues: colClues,
      );

      // Write in a batch to Firestore
      final batch = FirebaseFirestore.instance.batch();
      batch.set(
        FirebaseFirestore.instance.collection('levels').doc(levelId),
        level.toMap(),
      );
      batch.set(
        FirebaseFirestore.instance.collection('puzzles').doc(levelId),
        puzzle.toMap(),
      );

      // Increment createdLevels in user doc
      batch.update(
        FirebaseFirestore.instance.collection('users').doc(userId),
        {
          'createdLevels': FieldValue.increment(1),
          'updatedAt': Timestamp.fromDate(now),
        },
      );

      await batch.commit();

      // Clear draft locally
      await discardDraft();

      state = state.copyWith(isPublishing: false);
      return true;
    } catch (e) {
      print('Error publishing puzzle: $e');
      state = state.copyWith(isPublishing: false);
      return false;
    }
  }
}

final createPuzzleProvider = NotifierProvider<CreatePuzzleNotifier, CreatePuzzleState>(() {
  return CreatePuzzleNotifier();
});
