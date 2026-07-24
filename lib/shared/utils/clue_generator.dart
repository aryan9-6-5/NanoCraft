class ClueGenerator {
  /// Generates the run-length clues for each row of a given grid.
  /// Empty rows are returned with a clue of [0].
  static List<List<int>> generateRowClues(List<List<bool>> grid) {
    final List<List<int>> clues = [];
    for (final row in grid) {
      final List<int> rowClue = [];
      int currentRun = 0;
      for (final cell in row) {
        if (cell) {
          currentRun++;
        } else {
          if (currentRun > 0) {
            rowClue.add(currentRun);
            currentRun = 0;
          }
        }
      }
      if (currentRun > 0) {
        rowClue.add(currentRun);
      }
      if (rowClue.isEmpty) {
        rowClue.add(0);
      }
      clues.add(rowClue);
    }
    return clues;
  }

  /// Generates the run-length clues for each column of a given grid.
  /// Empty columns are returned with a clue of [0].
  static List<List<int>> generateColumnClues(List<List<bool>> grid) {
    if (grid.isEmpty) return [];
    final int numCols = grid[0].length;
    final int numRows = grid.length;
    final List<List<int>> clues = [];

    for (int col = 0; col < numCols; col++) {
      final List<int> colClue = [];
      int currentRun = 0;
      for (int row = 0; row < numRows; row++) {
        if (grid[row][col]) {
          currentRun++;
        } else {
          if (currentRun > 0) {
            colClue.add(currentRun);
            currentRun = 0;
          }
        }
      }
      if (currentRun > 0) {
        colClue.add(currentRun);
      }
      if (colClue.isEmpty) {
        colClue.add(0);
      }
      clues.add(colClue);
    }
    return clues;
  }
}
