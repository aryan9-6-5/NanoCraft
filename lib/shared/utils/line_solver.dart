enum CellSolverState { unknown, empty, filled }

class SolverResult {
  final bool isSolvable;
  final List<int> unresolvedRows;
  final List<int> unresolvedColumns;

  const SolverResult({
    required this.isSolvable,
    required this.unresolvedRows,
    required this.unresolvedColumns,
  });
}

class LineSolver {
  /// Runs the constraint propagation solvability check.
  /// If fully solvable by logic alone (no guessing), returns a successful result.
  /// Otherwise, returns a failure result with lists of unresolved row and column indices.
  static SolverResult checkSolvability(
    List<List<int>> rowClues,
    List<List<int>> colClues,
    int gridSize,
  ) {
    // Initialize the board with 'unknown'
    final List<List<CellSolverState>> board = List.generate(
      gridSize,
      (_) => List.filled(gridSize, CellSolverState.unknown),
    );

    bool changed = true;
    while (changed) {
      changed = false;

      // Check rows
      for (int r = 0; r < gridSize; r++) {
        final line = board[r];
        if (_solveLine(rowClues[r], line)) {
          changed = true;
        }
      }

      // Check columns
      for (int c = 0; c < gridSize; c++) {
        final List<CellSolverState> line = List.generate(gridSize, (r) => board[r][c]);
        if (_solveLine(colClues[c], line)) {
          changed = true;
          // Apply changes back to board
          for (int r = 0; r < gridSize; r++) {
            board[r][c] = line[r];
          }
        }
      }
    }

    // Identify unresolved lines
    final List<int> unresolvedRows = [];
    final List<int> unresolvedCols = [];

    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (board[r][c] == CellSolverState.unknown) {
          if (!unresolvedRows.contains(r)) unresolvedRows.add(r);
          if (!unresolvedCols.contains(c)) unresolvedCols.add(c);
        }
      }
    }

    final bool isSolvable = unresolvedRows.isEmpty && unresolvedCols.isEmpty;

    return SolverResult(
      isSolvable: isSolvable,
      unresolvedRows: unresolvedRows,
      unresolvedColumns: unresolvedCols,
    );
  }

  /// Solves a single line using clues and current solver state.
  /// Modifies [line] in-place with resolved cell states.
  /// Returns [true] if any cell was updated from 'unknown' to 'filled' or 'empty'.
  static bool _solveLine(List<int> clues, List<CellSolverState> line) {
    final int lineLength = line.length;

    // Edge case: empty clue or [0]
    if (clues.isEmpty || (clues.length == 1 && clues[0] == 0)) {
      bool changed = false;
      for (int i = 0; i < lineLength; i++) {
        if (line[i] == CellSolverState.unknown) {
          line[i] = CellSolverState.empty;
          changed = true;
        }
      }
      return changed;
    }

    // Generate all valid configurations consistent with the current line state
    final List<List<bool>> validConfigs = [];
    final List<bool> currentConfig = List.filled(lineLength, false);

    _generateConfigurations(
      0,
      0,
      currentConfig,
      clues,
      line,
      validConfigs,
    );

    if (validConfigs.isEmpty) {
      // Conflict or invalid line state.
      return false;
    }

    // Intersect valid configurations
    bool changed = false;
    for (int i = 0; i < lineLength; i++) {
      if (line[i] == CellSolverState.unknown) {
        bool allFilled = true;
        bool allEmpty = true;

        for (final config in validConfigs) {
          if (config[i]) {
            allEmpty = false;
          } else {
            allFilled = false;
          }
        }

        if (allFilled) {
          line[i] = CellSolverState.filled;
          changed = true;
        } else if (allEmpty) {
          line[i] = CellSolverState.empty;
          changed = true;
        }
      }
    }

    return changed;
  }

  /// Recursive backtracking helper to find all valid board combinations for a single line
  /// which do not conflict with the existing constraints in [lineConstraint].
  static void _generateConfigurations(
    int clueIndex,
    int startPos,
    List<bool> currentConfig,
    List<int> clues,
    List<CellSolverState> lineConstraint,
    List<List<bool>> results,
  ) {
    if (clueIndex == clues.length) {
      // Ensure no remaining cells are forced to be filled
      for (int i = startPos; i < lineConstraint.length; i++) {
        if (lineConstraint[i] == CellSolverState.filled) {
          return;
        }
      }
      results.add(List.from(currentConfig));
      return;
    }

    final int currentClue = clues[clueIndex];
    int remainingSpace = 0;
    for (int i = clueIndex; i < clues.length; i++) {
      remainingSpace += clues[i];
      if (i < clues.length - 1) remainingSpace += 1;
    }

    final int maxStart = lineConstraint.length - remainingSpace;

    for (int p = startPos; p <= maxStart; p++) {
      // 1. Cells before the current clue placement must not be filled
      bool valid = true;
      for (int i = startPos; i < p; i++) {
        if (lineConstraint[i] == CellSolverState.filled) {
          valid = false;
          break;
        }
      }
      if (!valid) continue;

      // 2. Cells within current clue placement must not be empty
      for (int i = p; i < p + currentClue; i++) {
        if (lineConstraint[i] == CellSolverState.empty) {
          valid = false;
          break;
        }
      }
      if (!valid) continue;

      // 3. Cell immediately following the placed clue must not be filled (must be empty/spacer)
      final int nextPos = p + currentClue;
      if (nextPos < lineConstraint.length) {
        if (lineConstraint[nextPos] == CellSolverState.filled) {
          valid = false;
        }
      }
      if (!valid) continue;

      // Place clue
      for (int i = p; i < p + currentClue; i++) {
        currentConfig[i] = true;
      }

      // Recurse
      _generateConfigurations(
        clueIndex + 1,
        nextPos + 1,
        currentConfig,
        clues,
        lineConstraint,
        results,
      );

      // Backtrack
      for (int i = p; i < p + currentClue; i++) {
        currentConfig[i] = false;
      }
    }
  }
}
