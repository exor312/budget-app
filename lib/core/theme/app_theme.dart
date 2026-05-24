import 'package:flutter/material.dart';
import 'color_tokens.dart';
import 'text_styles.dart';

/// Fortuna app theme configuration.
class FortunaTheme {
  FortunaTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: FortunaColors.primary,
        onPrimary: FortunaColors.onPrimary,
        primaryContainer: FortunaColors.primaryContainer,
        onPrimaryContainer: FortunaColors.onPrimaryContainer,
        secondary: FortunaColors.secondary,
        onSecondary: FortunaColors.onSecondary,
        secondaryContainer: FortunaColors.secondaryContainer,
        onSecondaryContainer: FortunaColors.onSecondaryContainer,
        tertiary: FortunaColors.tertiaryFixedDim,
        onTertiary: FortunaColors.onTertiary,
        tertiaryContainer: FortunaColors.tertiaryContainer,
        onTertiaryContainer: FortunaColors.onTertiaryContainer,
        error: FortunaColors.error,
        onError: FortunaColors.onError,
        errorContainer: FortunaColors.errorContainer,
        onErrorContainer: FortunaColors.onErrorContainer,
        surface: FortunaColors.surface,
        onSurface: FortunaColors.onSurface,
        onSurfaceVariant: FortunaColors.onSurfaceVariant,
        outline: FortunaColors.outline,
        outlineVariant: FortunaColors.outlineVariant,
        surfaceContainerLowest: FortunaColors.surfaceContainerLowest,
        surfaceContainer: FortunaColors.surfaceContainer,
        surfaceContainerHigh: FortunaColors.surfaceContainerHigh,
        surfaceContainerHighest: FortunaColors.surfaceContainerHighest,
      ),
      scaffoldBackgroundColor: FortunaColors.surface,
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        displayLarge: FortunaTextStyles.displayLarge,
        headlineLarge: FortunaTextStyles.headlineLg,
        headlineMedium: FortunaTextStyles.titleMd,
        titleMedium: FortunaTextStyles.titleMd,
        bodyLarge: FortunaTextStyles.bodyLg,
        bodyMedium: FortunaTextStyles.bodySm,
        labelLarge: FortunaTextStyles.labelCaps,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: FortunaColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: FortunaColors.primary.withValues(alpha: 0.05),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: FortunaColors.surface,
        foregroundColor: FortunaColors.onSurface,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: FortunaColors.primary,
        foregroundColor: FortunaColors.onPrimary,
        elevation: 6,
        shape: CircleBorder(),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: FortunaColors.primary,
          foregroundColor: FortunaColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FortunaColors.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: FortunaColors.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: FortunaColors.outlineVariant, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      dividerTheme: const DividerThemeData(
        color: FortunaColors.outlineVariant,
        thickness: 1,
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: FortunaColors.darkPrimary,
        onPrimary: FortunaColors.darkOnPrimary,
        primaryContainer: FortunaColors.darkPrimaryContainer,
        onPrimaryContainer: FortunaColors.darkOnPrimaryContainer,
        secondary: FortunaColors.darkSecondary,
        onSecondary: FortunaColors.darkOnSecondary,
        secondaryContainer: FortunaColors.darkSecondaryContainer,
        onSecondaryContainer: FortunaColors.darkOnSecondaryContainer,
        tertiary: FortunaColors.darkTertiary,
        onTertiary: FortunaColors.darkOnTertiary,
        tertiaryContainer: FortunaColors.darkTertiaryContainer,
        onTertiaryContainer: FortunaColors.darkOnTertiaryContainer,
        error: FortunaColors.darkError,
        onError: FortunaColors.darkOnError,
        errorContainer: FortunaColors.darkErrorContainer,
        onErrorContainer: FortunaColors.darkOnErrorContainer,
        surface: FortunaColors.darkSurface,
        onSurface: FortunaColors.darkOnSurface,
        onSurfaceVariant: FortunaColors.darkOnSurfaceVariant,
        outline: FortunaColors.darkOutline,
        outlineVariant: FortunaColors.darkOutlineVariant,
        surfaceContainerLowest: FortunaColors.darkSurfaceContainerLowest,
        surfaceContainer: FortunaColors.darkSurfaceContainer,
        surfaceContainerHigh: FortunaColors.darkSurfaceContainerHigh,
        surfaceContainerHighest: FortunaColors.darkSurfaceContainerHighest,
      ),
      scaffoldBackgroundColor: FortunaColors.darkSurface,
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        displayLarge: FortunaTextStyles.displayLarge,
        headlineLarge: FortunaTextStyles.headlineLg,
        headlineMedium: FortunaTextStyles.titleMd,
        titleMedium: FortunaTextStyles.titleMd,
        bodyLarge: FortunaTextStyles.bodyLg,
        bodyMedium: FortunaTextStyles.bodySm,
        labelLarge: FortunaTextStyles.labelCaps,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: FortunaColors.darkSurfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: Colors.black.withValues(alpha: 0.2),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: FortunaColors.darkSurface,
        foregroundColor: FortunaColors.darkOnSurface,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: FortunaColors.darkPrimary,
        foregroundColor: FortunaColors.darkOnPrimary,
        elevation: 6,
        shape: CircleBorder(),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: FortunaColors.darkPrimary,
          foregroundColor: FortunaColors.darkOnPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FortunaColors.darkSurfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: FortunaColors.darkPrimary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: FortunaColors.darkOutlineVariant, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      dividerTheme: const DividerThemeData(
        color: FortunaColors.darkOutlineVariant,
        thickness: 1,
      ),
    );
  }
}
