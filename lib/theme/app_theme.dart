import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // ---- Brand palette (light to deep) ----
  static const Color rose100 = Color(0xFFEB9BB5);
  static const Color rose200 = Color(0xFFDC81A2);
  static const Color rose300 = Color(0xFFCD6A92);
  static const Color rose400 = Color(0xFFBE5583);
  static const Color rose500 = Color(0xFFAF4276);
  static const Color rose600 = Color(0xFFA0316A);
  static const Color rose700 = Color(0xFF912260);

  // ---- Core roles ----
  static const Color background = Color(0xFFFDF3F7); // soft pink tint
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = rose700;
  static const Color primaryLight = rose400;
  static const Color accent = rose200;
  static const Color textPrimary = Color(0xFF3B1028); // deep plum
  static const Color textSecondary = Color(0xFF7D4A65);
  static const Color cardBorder = Color(0xFFF1D3DF);
  static const Color danger = Color(0xFFE57373);

  // ---- Soft tints ----
  static const Color lavender = Color(0xFFF6DCE6);
  static const Color blush = Color(0xFFFBE6EE);
  static const Color ink = Color(0xFF3B1028);

  // ---- Semantic colours (kept distinct on purpose) ----
  static const Color periodRed = Color(0xFFE05C6E);
  static const Color moodYellow = Color(0xFFE8B84B);
  static const Color symptomOrange = Color(0xFFE8935A);
  static const Color ovulationTeal = Color(0xFF5DCFA0);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [rose700, rose400],
  );
}

/// Soft, pink-tinted shadows for a gentle "floating card" look.
/// Usage: BoxDecoration(boxShadow: AppShadows.soft)
class AppShadows {
  static final List<BoxShadow> soft = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.08),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];
}

class AppTextStyles {
  /// Headings: Fredoka, a rounded and friendly face.
  static TextStyle serif({
    double size = 20,
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.textPrimary,
  }) => GoogleFonts.fredoka(fontSize: size, fontWeight: weight, color: color);

  static TextStyle serifItalic({
    double size = 20,
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.textPrimary,
  }) => GoogleFonts.fredoka(
    fontSize: size,
    fontWeight: weight,
    fontStyle: FontStyle.italic,
    color: color,
  );

  static TextStyle label({
    double size = 11,
    Color color = AppColors.textPrimary,
  }) => GoogleFonts.nunito(
    fontSize: size,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: color,
  );

  /// Body text: Nunito, soft and easy to read.
  static TextStyle sans({
    double size = 14,
    FontWeight weight = FontWeight.normal,
    Color color = AppColors.textPrimary,
  }) => GoogleFonts.nunito(fontSize: size, fontWeight: weight, color: color);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.accent,
    onSecondary: Colors.white,
    primaryContainer: AppColors.blush,
    onPrimaryContainer: AppColors.primary,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    error: AppColors.danger,
    outline: AppColors.cardBorder,
    surfaceTint: Colors.transparent,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
  );

  final body = GoogleFonts.nunitoTextTheme(base.textTheme).apply(
    bodyColor: AppColors.textPrimary,
    displayColor: AppColors.textPrimary,
  );
  final textTheme = body.copyWith(
    headlineLarge: GoogleFonts.fredoka(textStyle: body.headlineLarge),
    headlineMedium: GoogleFonts.fredoka(textStyle: body.headlineMedium),
    headlineSmall: GoogleFonts.fredoka(textStyle: body.headlineSmall),
    titleLarge: GoogleFonts.fredoka(textStyle: body.titleLarge),
  );

  const stadium = StadiumBorder();

  return base.copyWith(
    textTheme: textTheme,

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.fredoka(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    ),

    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: AppColors.cardBorder),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: stadium,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        textStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: stadium,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        textStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
        shape: stadium,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        textStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        shape: stadium,
        textStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      hintStyle: GoogleFonts.nunito(
        color: AppColors.textSecondary.withValues(alpha: 0.7),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.primary, width: 1.6),
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.primary,
      contentTextStyle: GoogleFonts.nunito(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      titleTextStyle: GoogleFonts.fredoka(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: AppColors.blush,
      side: BorderSide.none,
      shape: stadium,
      labelStyle: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color?>(
        (states) => states.contains(WidgetState.selected)
            ? Colors.white
            : AppColors.rose100,
      ),
      trackColor: WidgetStateProperty.resolveWith<Color?>(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.primary
            : AppColors.cardBorder,
      ),
      trackOutlineColor: WidgetStateProperty.all<Color?>(Colors.transparent),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color?>(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.primary
            : Colors.transparent,
      ),
      side: BorderSide(color: AppColors.cardBorder, width: 1.6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),

    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.cardBorder,
      thumbColor: AppColors.primary,
      overlayColor: AppColors.primary.withValues(alpha: 0.15),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
    ),

    dividerTheme: DividerThemeData(color: AppColors.cardBorder, space: 1),
  );
}
