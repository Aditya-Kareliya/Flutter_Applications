import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import '../my_app_colors/my_app_colors.dart';

abstract final class AppTheme {
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Curve animationCurve = Curves.easeOutCubic;

  static final ThemeData _lightTheme = _buildLight();
  static final ThemeData _darkTheme = _buildDark();

  static ThemeData light() => _lightTheme;
  static ThemeData dark() => _darkTheme;

  static final TextTheme _cachedLightTextTheme = _buildTextTheme(Brightness.light);
  static final TextTheme _cachedDarkTextTheme = _buildTextTheme(Brightness.dark);

  static final TextStyle _lightDialogTitleStyle = GoogleFonts.cormorantGaramond(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.black);
  static final TextStyle _darkDialogTitleStyle = GoogleFonts.cormorantGaramond(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.ivory);
  static final TextStyle _lightDialogContentStyle = GoogleFonts.inter(fontSize: 14.5, height: 1.55, color: const Color(0xDD090909));
  static final TextStyle _darkDialogContentStyle = GoogleFonts.inter(fontSize: 14.5, height: 1.55, color: AppColors.stone);
  static final TextStyle _lightPopupTextStyle = GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.black);
  static final TextStyle _darkPopupTextStyle = GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.ivory);

  static ThemeData _buildLight() {
    final base = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFFAF7F0),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.heritageMaroon,
        brightness: Brightness.light,
      ).copyWith(primary: AppColors.heritageMaroon, onPrimary: AppColors.white, surface: AppColors.white, onSurface: AppColors.black, surfaceTint: Colors.transparent),
    );

    return base.copyWith(
      extensions: const [MyHeritageColors.light],
      textTheme: _cachedLightTextTheme,
      appBarTheme: const AppBarTheme(backgroundColor: AppColors.white, foregroundColor: AppColors.black, elevation: 0, centerTitle: false, surfaceTintColor: Colors.transparent),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 16,
        shadowColor: Colors.black.withValues(alpha: 0.25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0x80C89B3C), width: 1.2),
        ),
        titleTextStyle: _lightDialogTitleStyle,
        contentTextStyle: _lightDialogContentStyle,
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 12,
        shadowColor: Colors.black.withValues(alpha: 0.25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0x80C89B3C), width: 1.2),
        ),
        textStyle: _lightPopupTextStyle,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.stone, thickness: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: _border(AppColors.stone),
        enabledBorder: _border(AppColors.stone),
        focusedBorder: _border(AppColors.heritageMaroon),
      ),
    );
  }

  static ThemeData _buildDark() {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF0F0E0E),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.heritageMaroon,
        brightness: Brightness.dark,
      ).copyWith(primary: AppColors.heritageMaroon, onPrimary: AppColors.white, surface: AppColors.deepMaroon, onSurface: AppColors.white, surfaceTint: Colors.transparent),
    );

    return base.copyWith(
      extensions: const [MyHeritageColors.dark],
      textTheme: _cachedDarkTextTheme,
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: AppColors.stone)),
      appBarTheme: const AppBarTheme(backgroundColor: AppColors.black, foregroundColor: AppColors.white, elevation: 0, centerTitle: false, surfaceTintColor: Colors.transparent),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF171515),
        surfaceTintColor: Colors.transparent,
        elevation: 20,
        shadowColor: Colors.black.withValues(alpha: 0.55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0x80C89B3C), width: 1.2),
        ),
        titleTextStyle: _darkDialogTitleStyle,
        contentTextStyle: _darkDialogContentStyle,
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: const Color(0xFF171515),
        surfaceTintColor: Colors.transparent,
        elevation: 14,
        shadowColor: Colors.black.withValues(alpha: 0.55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0x80C89B3C), width: 1.2),
        ),
        textStyle: _darkPopupTextStyle,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.mutedInk, thickness: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.deepMaroon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: _border(AppColors.mutedInk),
        enabledBorder: _border(AppColors.mutedInk),
        focusedBorder: _border(AppColors.heritageMaroon),
      ),
    );
  }

  static TextTheme _buildTextTheme(Brightness brightness) {
    final foreground = brightness == Brightness.light ? AppColors.black : AppColors.white;
    return TextTheme(
      displayLarge: GoogleFonts.cormorantGaramond(fontSize: 72, height: 0.98, fontWeight: FontWeight.w600, color: foreground),
      displayMedium: GoogleFonts.cormorantGaramond(fontSize: 54, height: 1.0, fontWeight: FontWeight.w600, color: foreground),
      headlineLarge: GoogleFonts.cormorantGaramond(fontSize: 48, height: 1.05, fontWeight: FontWeight.w600, color: foreground),
      headlineMedium: GoogleFonts.cormorantGaramond(fontSize: 34, height: 1.12, fontWeight: FontWeight.w500, color: foreground),
      titleLarge: GoogleFonts.cormorantGaramond(fontSize: 24, height: 1.18, fontWeight: FontWeight.w500, color: foreground),
      bodyLarge: GoogleFonts.inter(fontSize: 18, height: 1.65, color: foreground),
      bodyMedium: GoogleFonts.inter(fontSize: 15, height: 1.65, color: foreground),
      labelLarge: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: foreground),
      labelSmall: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.0, color: foreground),
    );
  }

  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: color),
  );
}
