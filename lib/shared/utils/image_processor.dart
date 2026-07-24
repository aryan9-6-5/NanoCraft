import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageProcessor {
  /// Decodes, resizes to 15x15, and calculates a 2D grid of 0-255 grayscale values.
  static List<List<int>> preprocessImage(Uint8List imageBytes) {
    final img.Image? decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      throw Exception('Failed to decode image');
    }

    // Resize to 15x15
    final img.Image resized = img.copyResize(decoded, width: 15, height: 15);

    final List<List<int>> grayscaleGrid = List.generate(
      15,
      (_) => List.filled(15, 0),
    );

    for (int y = 0; y < 15; y++) {
      for (int x = 0; x < 15; x++) {
        final pixel = resized.getPixel(x, y);
        // image package version 4.x supports pixel.r, pixel.g, pixel.b
        final num r = pixel.r;
        final num g = pixel.g;
        final num b = pixel.b;
        final int luminance = (0.299 * r + 0.587 * g + 0.114 * b).round();
        grayscaleGrid[y][x] = luminance;
      }
    }

    return grayscaleGrid;
  }

  /// Thresholds 2D grayscale pixel grid (0-255) into a 2D boolean grid.
  /// thresholdValue is a normalized double (0.0 to 1.0) which maps to [0, 255].
  /// Pixels with luminance *below* or equal to the threshold are true (filled/dark).
  /// Pixels with luminance *above* the threshold are false (empty/light).
  static List<List<bool>> applyThreshold(List<List<int>> grayscaleGrid, double thresholdValue) {
    if (grayscaleGrid.isEmpty) return [];
    final int size = grayscaleGrid.length;
    final int thresholdInt = (thresholdValue * 255).round();

    final List<List<bool>> booleanGrid = List.generate(
      size,
      (_) => List.filled(size, false),
    );

    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        // Darker pixels (lower luminance) should be filled cells (true)
        booleanGrid[y][x] = grayscaleGrid[y][x] <= thresholdInt;
      }
    }

    return booleanGrid;
  }
}
