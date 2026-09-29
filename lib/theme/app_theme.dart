import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFFF4ECFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF8B5FBF);
  static const Color accent = Color(0xFFD988AC);
  static const Color textPrimary = Color(0xFF2A1D3A);
  static const Color textSecondary = Color(0xFF6B5C7A);
  static const Color cardBorder = Color(0xFFE0D3EC);

  // Accent colors for Home screen redesign
  static const Color periodRed = Color(0xFFE05C6E);
  static const Color moodYellow = Color(0xFFE8B84B);
  static const Color symptomOrange = Color(0xFFE8935A);

  // Accent color for Ovulation screen
  static const Color ovulationTeal = Color(0xFF5DCFA0);
}

class AppTextStyles {
  static TextStyle serif({
    double size = 20,
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.textPrimary,
  }) {
    return GoogleFonts.playfairDisplay(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  // ✅ FIXED — removed the accidental `required List<Expanded> children` parameter
  static TextStyle sans({
    double size = 14,
    FontWeight weight = FontWeight.normal,
    Color color = AppColors.textPrimary,
  }) {
    return GoogleFonts.dmSans(fontSize: size, fontWeight: weight, color: color);
  }
}

ThemeData buildAppTheme() {
  return ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onPrimary: Colors.white,
    ),
    fontFamily: GoogleFonts.dmSans().fontFamily,
    useMaterial3: true,
  );
}
