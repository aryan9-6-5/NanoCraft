class DifficultyResult {
  final double score;
  final String label;

  const DifficultyResult({
    required this.score,
    required this.label,
  });
}

class DifficultyCalculator {
  // Weights for scoring components
  static const double weightFill = 1.0;
  static const double weightClues = 1.5;
  static const double weightFrag = 2.0;

  // Threshold boundaries for classifications
  static const double easyThreshold = 7.5;
  static const double mediumThreshold = 10.0;
  static const double hardThreshold = 12.5;

  /// Computes the difficulty details of a Nonogram puzzle based on fill variance,
  /// clue counts, and line fragmentation.
  static DifficultyResult calculateDifficulty(
    List<List<bool>> grid,
    List<List<int>> rowClues,
    List<List<int>> colClues,
  ) {
    if (grid.isEmpty) {
      return const DifficultyResult(score: 0.0, label: 'easy');
    }

    final int gridSize = grid.length;
    int filledCells = 0;
    for (final row in grid) {
      for (final cell in row) {
        if (cell) filledCells++;
      }
    }

    final int totalCells = gridSize * gridSize;
    final double fillRatio = filledCells / totalCells;
    
    // fillScore: 1.0 at balanced 50% fill, down to 0.0 at 0% or 100% fill.
    final double fillScore = 1.0 - 2.0 * (fillRatio - 0.5).abs();

    int totalClueGroups = 0;
    for (final clue in rowClues) {
      for (final val in clue) {
        if (val > 0) totalClueGroups++;
      }
    }
    for (final clue in colClues) {
      for (final val in clue) {
        if (val > 0) totalClueGroups++;
      }
    }

    // Ratio of active clue groups to grid lines
    final double clueRatio = totalClueGroups / (gridSize * 2);

    // Average fragmentation per row/column
    final double avgFragmentation = totalClueGroups / (gridSize * 2);

    final double score = (weightFill * fillScore) +
        (weightClues * clueRatio) +
        (weightFrag * avgFragmentation);

    String label;
    if (score < easyThreshold) {
      label = 'easy';
    } else if (score < mediumThreshold) {
      label = 'medium';
    } else if (score < hardThreshold) {
      label = 'hard';
    } else {
      label = 'expert';
    }

    return DifficultyResult(score: score, label: label);
  }
}
