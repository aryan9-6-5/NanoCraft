import 'package:flutter_test/flutter_test.dart';
import 'package:nanocraft/shared/utils/puzzle_validator.dart';

void main() {
  group('PuzzleValidator Tests', () {
    test('Empty board fails validation', () {
      final grid = List.generate(15, (_) => List.filled(15, false));
      final result = PuzzleValidator.validatePuzzle(grid);

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('at least one filled cell'));
    });

    test('Completely filled board fails validation', () {
      final grid = List.generate(15, (_) => List.filled(15, true));
      final result = PuzzleValidator.validatePuzzle(grid);

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('cannot be completely filled'));
    });

    test('Invalid dimensions fail validation', () {
      final grid = List.generate(12, (_) => List.filled(12, true));
      final result = PuzzleValidator.validatePuzzle(grid);

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('Invalid puzzle dimensions'));
    });

    test('Solvable puzzle passes validation', () {
      // 15x15 uniquely solvable cross shape
      final grid = List.generate(15, (r) {
        return List.generate(15, (c) => r == 7 || c == 7);
      });

      final result = PuzzleValidator.validatePuzzle(grid);
      expect(result.isValid, isTrue);
      expect(result.errorMessage, isNull);
    });

    test('Ambiguous puzzle fails validation and returns unresolved indices', () {
      // Ambiguous top-left 2x2 grid, with rest of the 15x15 empty
      final grid = List.generate(15, (r) => List.filled(15, false));
      grid[0][0] = true;
      grid[1][1] = true;
      // This checkerboard 2x2 can also be [0][1]=true and [1][0]=true for the same clues ([1], [1])
      
      final result = PuzzleValidator.validatePuzzle(grid);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('ambiguous'));
      expect(result.unresolvedRows, contains(0));
      expect(result.unresolvedRows, contains(1));
      expect(result.unresolvedColumns, contains(0));
      expect(result.unresolvedColumns, contains(1));
    });
  });
}
