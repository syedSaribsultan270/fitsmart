import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors_extension.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

class AppTheme {
  static ThemeData dark({Color? accent}) {
    final ext = AppColorsExtension.dark(accentColor: accent);
    return _build(ext, Brightness.dark);
  }

  static ThemeData light({Color? accent}) {
    final ext = AppColorsExtension.light(accentColor: accent);
    return _build(ext, Brightness.light);
  }

  static ThemeData _build(AppColorsExtension c, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: c.bgPrimary,
      extensions: [c],
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: c.lime,
        secondary: c.cyan,
        tertiary: c.coral,
        surface: c.surfaceCard,
        error: c.error,
        onPrimary: c.textInverse,
        onSecondary: c.textInverse,
        onSurface: c.textPrimary,
        onError: c.textPrimary,
      ),
      fontFamily: 'Inter',
      textTheme: TextTheme(
        displayLarge: AppTypography.display.copyWith(color: c.textPrimary),
        displayMedium: AppTypography.h1.copyWith(color: c.textPrimary),
        displaySmall: AppTypography.h2.copyWith(color: c.textPrimary),
        headlineMedium: AppTypography.h3.copyWith(color: c.textPrimary),
        bodyLarge: AppTypography.body.copyWith(color: c.textPrimary),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: c.textPrimary),
        bodySmall: AppTypography.caption.copyWith(color: c.textSecondary),
        labelSmall: AppTypography.overline.copyWith(color: c.textTertiary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.bgPrimary,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness:
              isDark ? Brightness.dark : Brightness.light,
        ),
        titleTextStyle: AppTypography.h3.copyWith(color: c.textPrimary),
        centerTitle: false,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: c.bgSecondary,
        selectedItemColor: c.lime,
        unselectedItemColor: c.textTertiary,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      cardTheme: CardThemeData(
        color: c.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: c.surfaceCardBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: c.surfaceInputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: c.surfaceInputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: c.lime, width: 1.5),
        ),
        labelStyle: AppTypography.caption.copyWith(color: c.textSecondary),
        hintStyle: AppTypography.caption.copyWith(color: c.textTertiary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: c.surfaceCardBorder,
        thickness: 1,
        space: 0,
      ),
      iconTheme: IconThemeData(
        color: c.textSecondary,
        size: 24,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.lime,
          foregroundColor: c.textInverse,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.cyan,
          textStyle: AppTypography.bodyMedium,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.bgElevated,
        contentTextStyle: AppTypography.body.copyWith(color: c.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.bgTertiary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        titleTextStyle: AppTypography.h3.copyWith(color: c.textPrimary),
        contentTextStyle: AppTypography.body.copyWith(color: c.textPrimary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.bgSecondary,
        modalBackgroundColor: c.bgSecondary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.lime,
        linearTrackColor: c.surfaceCardBorder,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: c.lime,
        inactiveTrackColor: c.surfaceCardBorder,
        thumbColor: c.lime,
        overlayColor: c.limeGlow,
      ),
    );
  }
}
