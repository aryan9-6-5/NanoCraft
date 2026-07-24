import 'clue_generator.dart';
import 'line_solver.dart';

class PuzzleValidationResult {
  final bool isValid;
  final String? errorMessage;
  final List<int> unresolvedRows;
  final List<int> unresolvedColumns;

  const PuzzleValidationResult({
    required this.isValid,
    this.errorMessage,
    this.unresolvedRows = const [],
    this.unresolvedColumns = const [],
  });
}

class PuzzleValidator {
  /// Validates the puzzle solution grid dimensions, filled states, and uniqueness of logical solution.
  static PuzzleValidationResult validatePuzzle(List<List<bool>> grid) {
    if (grid.isEmpty) {
      return const PuzzleValidationResult(
        isValid: false,
        errorMessage: 'Puzzle board is empty.',
      );
    }

    final int gridSize = grid.length;
    // 1. Dimensions check (must be square 10x10 or 15x15)
    if (gridSize != 10 && gridSize != 15) {
      return PuzzleValidationResult(
        isValid: false,
        errorMessage: 'Invalid puzzle dimensions: ${gridSize}x$gridSize. Board must be 10x10 or 15x15.',
      );
    }
    for (final row in grid) {
      if (row.length != gridSize) {
        return const PuzzleValidationResult(
          isValid: false,
          errorMessage: 'Invalid board shape. Grid must be square.',
        );
      }
    }

    // 2. State checks: at least one filled cell, not completely filled
    int filledCount = 0;
    for (final row in grid) {
      for (final cell in row) {
        if (cell) filledCount++;
      }
    }

    final int totalCells = gridSize * gridSize;
    if (filledCount == 0) {
      return const PuzzleValidationResult(
        isValid: false,
        errorMessage: 'The puzzle must have at least one filled cell.',
      );
    }
    if (filledCount == totalCells) {
      return const PuzzleValidationResult(
        isValid: false,
        errorMessage: 'The puzzle cannot be completely filled.',
      );
    }

    // 3. Clue generation
    final rowClues = ClueGenerator.generateRowClues(grid);
    final colClues = ClueGenerator.generateColumnClues(grid);

    // 4. Solvability Check
    final solverResult = LineSolver.checkSolvability(rowClues, colClues, gridSize);

    if (!solverResult.isSolvable) {
      return PuzzleValidationResult(
        isValid: false,
        errorMessage: 'The puzzle is ambiguous (not solvable by logic alone). Please edit to make it solvable.',
        unresolvedRows: solverResult.unresolvedRows,
        unresolvedColumns: solverResult.unresolvedColumns,
      );
    }

    return const PuzzleValidationResult(isValid: true);
  }
}
