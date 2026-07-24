/// A 3x5 pixel bitmap font for rendering text onto a 10x10 Nonogram grid.
abstract final class PixelFont {
  static const Map<String, List<List<bool>>> fontMap = {
    'A': [
      [false, true, false],
      [true, false, true],
      [true, true, true],
      [true, false, true],
      [true, false, true],
    ],
    'B': [
      [true, true, false],
      [true, false, true],
      [true, true, false],
      [true, false, true],
      [true, true, false],
    ],
    'C': [
      [false, true, true],
      [true, false, false],
      [true, false, false],
      [true, false, false],
      [false, true, true],
    ],
    'D': [
      [true, true, false],
      [true, false, true],
      [true, false, true],
      [true, false, true],
      [true, true, false],
    ],
    'E': [
      [true, true, true],
      [true, false, false],
      [true, true, false],
      [true, false, false],
      [true, true, true],
    ],
    'F': [
      [true, true, true],
      [true, false, false],
      [true, true, false],
      [true, false, false],
      [true, false, false],
    ],
    'G': [
      [false, true, true],
      [true, false, false],
      [true, false, true],
      [true, false, true],
      [false, true, true],
    ],
    'H': [
      [true, false, true],
      [true, false, true],
      [true, true, true],
      [true, false, true],
      [true, false, true],
    ],
    'I': [
      [true, true, true],
      [false, true, false],
      [false, true, false],
      [false, true, false],
      [true, true, true],
    ],
    'J': [
      [false, false, true],
      [false, false, true],
      [false, false, true],
      [true, false, true],
      [false, true, false],
    ],
    'K': [
      [true, false, true],
      [true, false, true],
      [true, true, false],
      [true, false, true],
      [true, false, true],
    ],
    'L': [
      [true, false, false],
      [true, false, false],
      [true, false, false],
      [true, false, false],
      [true, true, true],
    ],
    'M': [
      [true, false, true],
      [true, true, true],
      [true, false, true],
      [true, false, true],
      [true, false, true],
    ],
    'N': [
      [true, false, true],
      [true, true, true],
      [true, true, true],
      [true, false, true],
      [true, false, true],
    ],
    'O': [
      [false, true, false],
      [true, false, true],
      [true, false, true],
      [true, false, true],
      [false, true, false],
    ],
    'P': [
      [true, true, false],
      [true, false, true],
      [true, true, false],
      [true, false, false],
      [true, false, false],
    ],
    'Q': [
      [false, true, false],
      [true, false, true],
      [true, false, true],
      [true, true, true],
      [false, true, true],
    ],
    'R': [
      [true, true, false],
      [true, false, true],
      [true, true, false],
      [true, false, true],
      [true, false, true],
    ],
    'S': [
      [false, true, true],
      [true, false, false],
      [false, true, false],
      [false, false, true],
      [true, true, false],
    ],
    'T': [
      [true, true, true],
      [false, true, false],
      [false, true, false],
      [false, true, false],
      [false, true, false],
    ],
    'U': [
      [true, false, true],
      [true, false, true],
      [true, false, true],
      [true, false, true],
      [false, true, false],
    ],
    'V': [
      [true, false, true],
      [true, false, true],
      [true, false, true],
      [true, false, true],
      [false, true, false],
    ],
    'W': [
      [true, false, true],
      [true, false, true],
      [true, false, true],
      [true, true, true],
      [true, false, true],
    ],
    'X': [
      [true, false, true],
      [true, false, true],
      [false, true, false],
      [true, false, true],
      [true, false, true],
    ],
    'Y': [
      [true, false, true],
      [true, false, true],
      [false, true, false],
      [false, true, false],
      [false, true, false],
    ],
    'Z': [
      [true, true, true],
      [false, false, true],
      [false, true, false],
      [true, false, false],
      [true, true, true],
    ],
    '0': [
      [true, true, true],
      [true, false, true],
      [true, false, true],
      [true, false, true],
      [true, true, true],
    ],
    '1': [
      [false, true, false],
      [true, true, false],
      [false, true, false],
      [false, true, false],
      [true, true, true],
    ],
    '2': [
      [true, true, true],
      [false, false, true],
      [true, true, true],
      [true, false, false],
      [true, true, true],
    ],
    '3': [
      [true, true, true],
      [false, false, true],
      [true, true, true],
      [false, false, true],
      [true, true, true],
    ],
    '4': [
      [true, false, true],
      [true, false, true],
      [true, true, true],
      [false, false, true],
      [false, false, true],
    ],
    '5': [
      [true, true, true],
      [true, false, false],
      [true, true, true],
      [false, false, true],
      [true, true, true],
    ],
    '6': [
      [true, true, true],
      [true, false, false],
      [true, true, true],
      [true, false, true],
      [true, true, true],
    ],
    '7': [
      [true, true, true],
      [false, false, true],
      [false, true, false],
      [false, true, false],
      [false, true, false],
    ],
    '8': [
      [true, true, true],
      [true, false, true],
      [true, true, true],
      [true, false, true],
      [true, true, true],
    ],
    '9': [
      [true, true, true],
      [true, false, true],
      [true, true, true],
      [false, false, true],
      [true, true, true],
    ],
    ' ': [
      [false, false, false],
      [false, false, false],
      [false, false, false],
      [false, false, false],
      [false, false, false],
    ],
  };

  /// Renders a string of up to 5 alphanumeric characters onto a 10x10 grid.
  /// If the text is 3 characters or fewer, it is drawn with full 3x5 resolution.
  /// If the text is 4 or 5 characters, it is drawn with a squeezed 2x5 resolution.
  /// Vertically, the letters are centered (starting at row 2).
  static List<List<bool>> renderText(String text) {
    final String cleanText = text.toUpperCase();
    final int charCount = cleanText.length.clamp(0, 5);

    // Initialize 10x10 empty grid
    final grid = List.generate(10, (_) => List.filled(10, false));

    if (charCount == 0) return grid;

    // Get character bitmaps
    final List<List<List<bool>>> bitmaps = [];
    for (int i = 0; i < charCount; i++) {
      final char = cleanText[i];
      bitmaps.add(fontMap[char] ?? fontMap[' ']!);
    }

    const int startRow = 2; // vertically centered (5 rows high, leaves 2 top, 3 bottom)

    if (charCount <= 3) {
      // Use full 3x5 layout
      int startCol = 0;
      int spacing = 0;

      if (charCount == 1) {
        startCol = 3;
      } else if (charCount == 2) {
        startCol = 1;
        spacing = 1;
      } else {
        startCol = 0;
        spacing = 0;
      }

      for (int i = 0; i < charCount; i++) {
        final bitmap = bitmaps[i];
        final int charStartCol = startCol + i * (3 + spacing);

        for (int r = 0; r < 5; r++) {
          for (int c = 0; c < 3; c++) {
            final targetRow = startRow + r;
            final targetCol = charStartCol + c;
            if (targetRow < 10 && targetCol < 10) {
              grid[targetRow][targetCol] = bitmap[r][c];
            }
          }
        }
      }
    } else {
      // Use squeezed 2x5 layout (for 4 or 5 characters)
      // Width of 2 per character, 0 spacing.
      // Total width: 4 chars -> 8 columns (starts at col 1). 5 chars -> 10 columns (starts at col 0).
      final int startCol = charCount == 4 ? 1 : 0;

      for (int i = 0; i < charCount; i++) {
        final bitmap = bitmaps[i];
        final int charStartCol = startCol + i * 2;

        for (int r = 0; r < 5; r++) {
          // Column 0 of squeezed is Column 0 of original
          final c0 = bitmap[r][0];
          // Column 1 of squeezed is Column 2 of original or Column 1 of original
          final c1 = bitmap[r][2] || bitmap[r][1];

          final targetRow = startRow + r;
          if (targetRow < 10) {
            if (charStartCol < 10) grid[targetRow][charStartCol] = c0;
            if (charStartCol + 1 < 10) grid[targetRow][charStartCol + 1] = c1;
          }
        }
      }
    }

    return grid;
  }
}
