import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nanocraft/features/play/presentation/providers/play_controller.dart';
import 'package:nanocraft/features/play/domain/entities/puzzle.dart';

void main() {
  group('PlayNotifier Tests', () {
    late Puzzle samplePuzzle;

    setUp(() {
      samplePuzzle = Puzzle(
        levelId: 'test_level',
        grid: [
          [true, false],
          [false, true],
        ],
        rowClues: [[1], [1]],
        columnClues: [[1], [1]],
      );
    });

    test('Initializes with 3 lives and correct grid dimensions', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(playProvider.notifier);
      notifier.initialize(samplePuzzle);

      final state = container.read(playProvider);
      expect(state.lives, equals(3));
      expect(state.isGameOver, isFalse);
      expect(state.playerGrid.length, equals(2));
      expect(state.playerGrid[0], equals([false, false]));
    });

    test('Correct fill does not decrement lives and sets fill mark', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(playProvider.notifier);
      notifier.initialize(samplePuzzle);

      // (0,0) should be true (filled) in solution
      notifier.beginStroke(0, 0, 'fill');
      notifier.endStroke();

      final state = container.read(playProvider);
      expect(state.lives, equals(3));
      expect(state.playerGrid[0][0], isTrue);
      expect(state.playerCrosses[0][0], isFalse);
    });

    test('Incorrect fill decrements lives, triggers error flag, and does not persist fill', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(playProvider.notifier);
      notifier.initialize(samplePuzzle);

      // (0,1) should be false (empty) in solution
      notifier.beginStroke(0, 1, 'fill');
      notifier.endStroke();

      final state = container.read(playProvider);
      expect(state.lives, equals(2));
      expect(state.playerGrid[0][1], isFalse); // not permanently filled
      expect(state.errorCellRow, equals(0));
      expect(state.errorCellCol, equals(1));
    });

    test('Crossing cells does not affect lives count', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(playProvider.notifier);
      notifier.initialize(samplePuzzle);

      // Place cross at (0,1)
      notifier.beginStroke(0, 1, 'cross');
      notifier.endStroke();

      var state = container.read(playProvider);
      expect(state.lives, equals(3)); // unchanged
      expect(state.playerCrosses[0][1], isTrue);

      // Try crossing (0,0) which should be filled
      notifier.beginStroke(0, 0, 'cross');
      notifier.endStroke();

      state = container.read(playProvider);
      expect(state.lives, equals(3)); // unchanged
      expect(state.playerCrosses[0][0], isTrue);
    });

    test('Eraser tool clears fills and crosses', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(playProvider.notifier);
      notifier.initialize(samplePuzzle);

      // Fill correct cell
      notifier.beginStroke(0, 0, 'fill');
      notifier.endStroke();

      // Cross empty cell
      notifier.beginStroke(0, 1, 'cross');
      notifier.endStroke();

      var state = container.read(playProvider);
      expect(state.playerGrid[0][0], isTrue);
      expect(state.playerCrosses[0][1], isTrue);

      // Erase both
      notifier.beginStroke(0, 0, 'eraser');
      notifier.endStroke();
      notifier.beginStroke(0, 1, 'eraser');
      notifier.endStroke();

      state = container.read(playProvider);
      expect(state.playerGrid[0][0], isFalse);
      expect(state.playerCrosses[0][1], isFalse);
    });

    test('Losing all lives triggers game over state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(playProvider.notifier);
      notifier.initialize(samplePuzzle);

      // 3 incorrect fills
      notifier.beginStroke(0, 1, 'fill');
      notifier.endStroke();
      notifier.beginStroke(0, 1, 'fill');
      notifier.endStroke();
      notifier.beginStroke(0, 1, 'fill');
      notifier.endStroke();

      final state = container.read(playProvider);
      expect(state.lives, equals(0));
      expect(state.isGameOver, isTrue);
    });
  });
}
