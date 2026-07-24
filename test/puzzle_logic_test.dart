import 'package:flutter_test/flutter_test.dart';
import 'package:nanocraft/shared/utils/clue_generator.dart';
import 'package:nanocraft/shared/utils/line_solver.dart';
import 'package:nanocraft/shared/utils/difficulty_calculator.dart';

void main() {
  group('ClueGenerator Tests', () {
    test('5x5 Simple Cross Clue Generation', () {
      // Row 0: F F F F F (5)
      // Row 1: E F E F E (1, 1)
      // Row 2: E E F E E (1)
      // Row 3: E E E E E (0)
      // Row 4: F E E E F (1, 1)
      final grid = [
        [true, true, true, true, true],
        [false, true, false, true, false],
        [false, false, true, false, false],
        [false, false, false, false, false],
        [true, false, false, false, true],
      ];

      final rowClues = ClueGenerator.generateRowClues(grid);
      final colClues = ClueGenerator.generateColumnClues(grid);

      expect(rowClues, [
        [5],
        [1, 1],
        [1],
        [0],
        [1, 1],
      ]);

      expect(colClues, [
        [1, 1],
        [2],
        [1, 1],
        [2],
        [1, 1],
      ]);
    });

    test('All Empty Grid Clue Generation', () {
      final grid = List.generate(10, (_) => List.filled(10, false));
      final rowClues = ClueGenerator.generateRowClues(grid);
      final colClues = ClueGenerator.generateColumnClues(grid);

      for (final clue in rowClues) {
        expect(clue, [0]);
      }
      for (final clue in colClues) {
        expect(clue, [0]);
      }
    });
  });

  group('LineSolver Tests', () {
    test('Uniquely Solvable 5x5 Puzzle', () {
      // Solutions:
      // E E F E E
      // E E F E E
      // F F F F F
      // E E F E E
      // E E F E E
      final rowClues = [[1], [1], [5], [1], [1]];
      final colClues = [[1], [1], [5], [1], [1]];

      final result = LineSolver.checkSolvability(rowClues, colClues, 5);
      expect(result.isSolvable, isTrue);
      expect(result.unresolvedRows, isEmpty);
      expect(result.unresolvedColumns, isEmpty);
    });

    test('Ambiguous 5x5 Puzzle (Stalls)', () {
      // Solutions:
      // F E E E E or E F E E E (ambiguous 2x2 in top-left)
      // E F E E E or F E E E E
      // E E E E E
      // E E E E E
      // E E E E E
      final rowClues = [[1], [1], [0], [0], [0]];
      final colClues = [[1], [1], [0], [0], [0]]; // ambiguous: which cells are filled?

      final result = LineSolver.checkSolvability(rowClues, colClues, 5);
      expect(result.isSolvable, isFalse);
      // Unresolved lines should contain row 0, 1 and columns 0, 1 (where ambiguity lies)
      expect(result.unresolvedRows, contains(0));
      expect(result.unresolvedRows, contains(1));
      expect(result.unresolvedColumns, contains(0));
      expect(result.unresolvedColumns, contains(1));
    });
  });

  group('DifficultyCalculator Tests and Tuning', () {
    test('Evaluate 30 Sample Grids for Threshold Tuning', () {
      final List<List<List<bool>>> samples = [];

      // Generate 30 sample grids with varying fill densities and patterns
      for (int i = 1; i <= 30; i++) {
        final int size = (i % 2 == 0) ? 10 : 15;
        final List<List<bool>> grid = List.generate(size, (r) {
          return List.generate(size, (c) {
            // density increases with i
            final threshold = 0.15 + (i * 0.015);
            return (r * c + i) % 7 < (threshold * 7);
          });
        });
        samples.add(grid);
      }

      print('--- Tuning Distribution Analysis ---');
      int easyCount = 0;
      int mediumCount = 0;
      int hardCount = 0;
      int expertCount = 0;

      for (int i = 0; i < samples.length; i++) {
        final grid = samples[i];
        final rowClues = ClueGenerator.generateRowClues(grid);
        final colClues = ClueGenerator.generateColumnClues(grid);
        final res = DifficultyCalculator.calculateDifficulty(grid, rowClues, colClues);

        print('Grid #${i+1} (${grid.length}x${grid.length}): Score = ${res.score.toStringAsFixed(3)} -> ${res.label.toUpperCase()}');

        switch (res.label) {
          case 'easy':
            easyCount++;
            break;
          case 'medium':
            mediumCount++;
            break;
          case 'hard':
            hardCount++;
            break;
          case 'expert':
            expertCount++;
            break;
        }
      }

      print('Easy: $easyCount, Medium: $mediumCount, Hard: $hardCount, Expert: $expertCount');

      // Check that we have a distribution (at least some easy, medium, hard/expert)
      expect(easyCount + mediumCount + hardCount + expertCount, 30);
      expect(easyCount, greaterThan(0));
      expect(expertCount, greaterThan(0));
    });
  });
}
