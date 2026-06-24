import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's theme choice across app restarts using
/// SharedPreferences. Defaults to system preference on first launch.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadSavedTheme();
  }

  static const _prefKey = 'theme_mode';

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    switch (saved) {
      case 'dark':
        state = ThemeMode.dark;
        break;
      case 'light':
        state = ThemeMode.light;
        break;
      case 'system':
        state = ThemeMode.system;
        break;
      default:
        state = ThemeMode.light; // Default to Light mode
    }
  }

  /// Flips between light and dark. If currently following system,
  /// flips relative to the platform's current brightness.
  Future<void> toggle(Brightness platformBrightness) async {
    final isCurrentlyDark = state == ThemeMode.dark ||
        (state == ThemeMode.system && platformBrightness == Brightness.dark);
    await setThemeMode(isCurrentlyDark ? ThemeMode.light : ThemeMode.dark);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, mode.name);
  }
}

final themeModeProvider =
StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
      (ref) => ThemeModeNotifier(),
);