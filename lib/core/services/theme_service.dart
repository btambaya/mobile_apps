import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Singleton service for app theme management
class ThemeService extends ChangeNotifier {
  // Singleton instance
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal() {
    _loadTheme();
  }

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _themeModeKey = 'theme_mode';

  // Current theme mode
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  /// Check if dark mode is enabled
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Load saved theme preference
  Future<void> _loadTheme() async {
    final savedTheme = await _secureStorage.read(key: _themeModeKey);
    if (savedTheme != null) {
      _themeMode = _stringToThemeMode(savedTheme);
      notifyListeners();
    }
  }

  /// Set dark mode on/off
  Future<void> setDarkMode(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    await _secureStorage.write(
      key: _themeModeKey,
      value: _themeModeToString(_themeMode),
    );
    notifyListeners();
  }

  /// Toggle between dark and light mode
  Future<void> toggleTheme() async {
    await setDarkMode(!isDarkMode);
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
    }
  }

  ThemeMode _stringToThemeMode(String str) {
    switch (str) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }
}
