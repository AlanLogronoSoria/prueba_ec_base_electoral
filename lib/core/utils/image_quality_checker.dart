import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageQualityChecker {
  static Future<bool> isSharp(
    File imageFile, {
    double threshold = 100.0,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(Uint8List.fromList(bytes));
      if (image == null) return false;

      final gray = img.grayscale(image);
      final width = gray.width;
      final height = gray.height;

      final kernel = [
        [-1, -1, -1],
        [-1, 8, -1],
        [-1, -1, -1],
      ];

      double sum = 0;
      double sumSq = 0;
      int count = 0;

      for (int y = 1; y < height - 1; y++) {
        for (int x = 1; x < width - 1; x++) {
          int laplacian = 0;
          for (int ky = -1; ky <= 1; ky++) {
            for (int kx = -1; kx <= 1; kx++) {
              final pixel = gray.getPixel(x + kx, y + ky);
              final grayValue = pixel.r.toInt();
              laplacian += grayValue * kernel[ky + 1][kx + 1];
            }
          }

          sum += laplacian;
          sumSq += laplacian * laplacian;
          count++;
        }
      }

      if (count == 0) return false;

      final mean = sum / count;
      final variance = (sumSq / count) - (mean * mean);

      return variance >= threshold;
    } catch (_) {
      return false;
    }
  }
}
