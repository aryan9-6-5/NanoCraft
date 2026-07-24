import 'package:flutter_test/flutter_test.dart';
import 'package:nanocraft/shared/utils/pixel_font.dart';

void main() {
  group('PixelFont Tests', () {
    test('renderText renders empty string as empty grid', () {
      final grid = PixelFont.renderText('');
      expect(grid.length, 10);
      expect(grid[0].length, 10);
      for (final row in grid) {
        expect(row.any((cell) => cell), isFalse);
      }
    });

    test('renderText renders H correctly', () {
      final grid = PixelFont.renderText('H');
      // Centered horizontally: starts at column 3
      // Centered vertically: starts at row 2
      // Check middle row of H (row 4): should be true across cols 3, 4, 5
      expect(grid[4][3], isTrue);
      expect(grid[4][4], isTrue);
      expect(grid[4][5], isTrue);
    });

    test('renderText renders HEL (3 characters) inside 10x10 bounds', () {
      final grid = PixelFont.renderText('HEL');
      expect(grid.length, 10);
      for (final row in grid) {
        expect(row.length, 10);
      }
    });

    test('renderText renders HELL (4 characters) squeezed inside 10x10 bounds', () {
      final grid = PixelFont.renderText('HELL');
      expect(grid.length, 10);
      for (final row in grid) {
        expect(row.length, 10);
      }
    });

    test('renderText renders HELLO (5 characters) squeezed inside 10x10 bounds', () {
      final grid = PixelFont.renderText('HELLO');
      expect(grid.length, 10);
      for (final row in grid) {
        expect(row.length, 10);
      }
    });
  });
}
