import 'package:flutter/material.dart';

/// Color theme for a financial app: trustworthy, clear, and professional.
/// Uses deep blue as primary (stability/trust) with teal accent and semantic green/red.
class AppTheme {
  AppTheme._();

  // --- Light theme colors ---
  static const Color _primaryLight = Color(0xFF0D47A1); // Deep blue
  static const Color _onPrimaryLight = Color(0xFFFFFFFF);
  static const Color _primaryContainerLight = Color(0xFFBBDEFB);
  static const Color _onPrimaryContainerLight = Color(0xFF001D35);
  static const Color _secondaryLight = Color(0xFF00695C); // Teal
  static const Color _onSecondaryLight = Color(0xFFFFFFFF);
  static const Color _secondaryContainerLight = Color(0xFFB2DFDB);
  static const Color _onSecondaryContainerLight = Color(0xFF00251A);
  static const Color _surfaceLight = Color(0xFFE2E8F0);
  static const Color _onSurfaceLight = Color(0xFF1A1F26);
  static const Color _surfaceContainerHighestLight = Color(0xFFCBD5E1);
  static const Color _outlineLight = Color(0xFF64748B);
  static const Color _errorLight = Color(0xFFB91C1C);
  static const Color _onErrorLight = Color(0xFFFFFFFF);

  // --- Dark theme colors ---
  static const Color _primaryDark = Color(0xFF90CAF9);
  static const Color _onPrimaryDark = Color(0xFF003258);
  static const Color _primaryContainerDark = Color(0xFF004A77);
  static const Color _onPrimaryContainerDark = Color(0xFFBBDEFB);
  static const Color _secondaryDark = Color(0xFF80CBC4);
  static const Color _onSecondaryDark = Color(0xFF00382E);
  static const Color _secondaryContainerDark = Color(0xFF005048);
  static const Color _onSecondaryContainerDark = Color(0xFFB2DFDB);
  static const Color _surfaceDark = Color(0xFF05080B);
  static const Color _onSurfaceDark = Color(0xFFE2E8F0);
  static const Color _surfaceContainerHighestDark = Color(0xFF151B23);
  static const Color _outlineDark = Color(0xFF94A3B8);
  static const Color _errorDark = Color(0xFFF87171);
  static const Color _onErrorDark = Color(0xFF7F1D1D);

  /// Semantic colors for amounts (use in app, not in ColorScheme).
  static const Color positiveLight = Color(0xFF15803D); // Green
  static const Color positiveDark = Color(0xFF4ADE80);
  static const Color negativeLight = Color(0xFFB91C1C); // Red
  static const Color negativeDark = Color(0xFFF87171);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _primaryLight,
        onPrimary: _onPrimaryLight,
        primaryContainer: _primaryContainerLight,
        onPrimaryContainer: _onPrimaryContainerLight,
        secondary: _secondaryLight,
        onSecondary: _onSecondaryLight,
        secondaryContainer: _secondaryContainerLight,
        onSecondaryContainer: _onSecondaryContainerLight,
        surface: _surfaceLight,
        onSurface: _onSurfaceLight,
        surfaceContainerHighest: _surfaceContainerHighestLight,
        outline: _outlineLight,
        error: _errorLight,
        onError: _onErrorLight,
      ),
      scaffoldBackgroundColor: _surfaceLight,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: _surfaceLight,
        foregroundColor: _onSurfaceLight,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _primaryDark,
        onPrimary: _onPrimaryDark,
        primaryContainer: _primaryContainerDark,
        onPrimaryContainer: _onPrimaryContainerDark,
        secondary: _secondaryDark,
        onSecondary: _onSecondaryDark,
        secondaryContainer: _secondaryContainerDark,
        onSecondaryContainer: _onSecondaryContainerDark,
        surface: _surfaceDark,
        onSurface: _onSurfaceDark,
        surfaceContainerHighest: _surfaceContainerHighestDark,
        outline: _outlineDark,
        error: _errorDark,
        onError: _onErrorDark,
      ),
      scaffoldBackgroundColor: _surfaceDark,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: _surfaceDark,
        foregroundColor: _onSurfaceDark,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: _surfaceContainerHighestDark,
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  /// Use for income/positive amounts. Respects brightness.
  static Color positiveColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? positiveDark : positiveLight;
  }

  /// Use for expense/negative amounts. Respects brightness.
  static Color negativeColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? negativeDark : negativeLight;
  }
}
