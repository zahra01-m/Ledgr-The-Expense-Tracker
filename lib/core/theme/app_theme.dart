import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ── Tropical Sunrise Palette ──────────────────────────────────
  static const Color _primary = Color(0xFFFF9E0B);    // Vibrant Orange
  static const Color _secondary = Color(0xFF1CB5AC);  // Tropical Teal
  static const Color _tertiary = Color(0xFFFFC06A);   // Soft Orange
  static const Color _surface = Color(0xFFFFFFFF);    // White
  static const Color _background = Color(0xFFF8FEFD); // Pale Mint Tint
  static const Color _onSurface = Color(0xFF191C1E);  // Near Black for high contrast
  static const Color _error = Color(0xFFBA1A1A);      // Red

  // ── Dark Palette (Derived) ────────────────────────────────────
  static const Color _primaryDark = Color(0xFFFFB74D);
  static const Color _secondaryDark = Color(0xFF4DB6AC);
  static const Color _surfaceDark = Color(0xFF1A1C1E);
  static const Color _backgroundDark = Color(0xFF121416);
  static const Color _onSurfaceDark = Color(0xFFE2E2E6);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: _background,
    colorScheme: ColorScheme.light(
      primary: _primary,
      secondary: _secondary,
      tertiary: _tertiary,
      surface: _surface,
      onSurface: _onSurface,
      error: _error,
      outline: _secondary.withValues(alpha: 0.2),
    ),
    appBarTheme: const AppBarThemeData(
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: _onSurface,
      titleTextStyle: TextStyle(
        color: _onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: _onSurface),
      displayMedium: TextStyle(color: _onSurface),
      displaySmall: TextStyle(color: _onSurface),
      headlineLarge: TextStyle(color: _onSurface),
      headlineMedium: TextStyle(color: _onSurface),
      headlineSmall: TextStyle(color: _onSurface),
      titleLarge: TextStyle(color: _onSurface),
      titleMedium: TextStyle(color: _onSurface),
      titleSmall: TextStyle(color: _onSurface),
      bodyLarge: TextStyle(color: _onSurface),
      bodyMedium: TextStyle(color: _onSurface),
      bodySmall: TextStyle(color: _onSurface),
      labelLarge: TextStyle(color: _onSurface),
      labelMedium: TextStyle(color: _onSurface),
      labelSmall: TextStyle(color: _onSurface),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: _surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: _secondary.withValues(alpha: 0.1)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _surface,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _secondary.withValues(alpha: 0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _secondary.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _primary, width: 2),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _backgroundDark,
    colorScheme: ColorScheme.dark(
      primary: _primaryDark,
      secondary: _secondaryDark,
      surface: _surfaceDark,
      onSurface: _onSurfaceDark,
      error: _error,
    ),
    appBarTheme: const AppBarThemeData(
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: _onSurfaceDark,
      titleTextStyle: TextStyle(
        color: _onSurfaceDark,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: _surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: _onSurfaceDark.withValues(alpha: 0.1)),
      ),
    ),
  );
}
