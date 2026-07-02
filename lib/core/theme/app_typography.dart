import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle plusJakarta({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
    double height = 1.5,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static final TextStyle displayLarge = plusJakarta(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5);
  static final TextStyle displayMedium = plusJakarta(fontSize: 24, fontWeight: FontWeight.w700);
  static final TextStyle headingLarge = plusJakarta(fontSize: 20, fontWeight: FontWeight.w700);
  static final TextStyle headingMedium = plusJakarta(fontSize: 18, fontWeight: FontWeight.w600);
  static final TextStyle headingSmall = plusJakarta(fontSize: 16, fontWeight: FontWeight.w600);
  static final TextStyle bodyLarge = plusJakarta(fontSize: 16, fontWeight: FontWeight.w400);
  static final TextStyle bodyMedium = plusJakarta(fontSize: 14, fontWeight: FontWeight.w400);
  static final TextStyle bodySmall = plusJakarta(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static final TextStyle labelLarge = plusJakarta(fontSize: 14, fontWeight: FontWeight.w600);
  static final TextStyle labelMedium = plusJakarta(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary);
  static final TextStyle buttonLarge = plusJakarta(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textInverse);
  static final TextStyle statValue = plusJakarta(fontSize: 28, fontWeight: FontWeight.w700);
  static final TextStyle statLabel = plusJakarta(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary);
  static final TextStyle caption = plusJakarta(fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textTertiary);
}
