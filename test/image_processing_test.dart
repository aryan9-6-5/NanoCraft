import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:nanocraft/shared/utils/image_processor.dart';

void main() {
  group('ImageProcessor Tests', () {
    test('applyThreshold maps grayscale grid to boolean grid correctly', () {
      final List<List<int>> grayscale = [
        [0, 50, 100],
        [150, 200, 255],
        [127, 128, 129],
      ];

      // With threshold 0.5 (maps to 128), values <= 128 are true (dark)
      final result = ImageProcessor.applyThreshold(grayscale, 0.5);

      expect(result, [
        [true, true, true],
        [false, false, false],
        [true, true, false],
      ]);
    });

    test('preprocessImage decodes, resizes, and grayscales correctly', () {
      // Create a 30x30 image with a white background and a black square in the middle
      final image = img.Image(width: 30, height: 30);
      img.fill(image, color: img.ColorRgb8(255, 255, 255)); // White
      
      // Draw black rectangle in top left
      for (int y = 0; y < 15; y++) {
        for (int x = 0; x < 15; x++) {
          image.setPixel(x, y, img.ColorRgb8(0, 0, 0)); // Black
        }
      }

      final pngBytes = Uint8List.fromList(img.encodePng(image));

      final grayscaleGrid = ImageProcessor.preprocessImage(pngBytes);

      // Verify dimensions
      expect(grayscaleGrid.length, 15);
      expect(grayscaleGrid[0].length, 15);

      // Top-left quadrant (approximate coordinates 0-7) should be dark (close to 0 luminance)
      expect(grayscaleGrid[0][0], lessThan(50));
      // Bottom-right quadrant should be light (close to 255 luminance)
      expect(grayscaleGrid[14][14], greaterThan(200));
    });
  });
}
