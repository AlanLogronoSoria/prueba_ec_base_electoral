import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._();

  static String get defaultPassword =>
      dotenv.env['DEFAULT_PASSWORD'] ?? 'Cambiar123!';
  static double get laplacianThreshold =>
      double.tryParse(dotenv.env['LAPLACIAN_THRESHOLD'] ?? '') ?? 100.0;
  static int get minSufragantes =>
      int.tryParse(dotenv.env['MIN_SUFRAGANTES'] ?? '') ?? 0;
  static int get maxSufragantes =>
      int.tryParse(dotenv.env['MAX_SUFRAGANTES'] ?? '') ?? 500;
}
