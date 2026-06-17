import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _key = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    if (stored == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (stored == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode == ThemeMode.system ? 'system' : mode.name);
  }

  void toggleTheme() {
    setThemeMode(isDarkMode ? ThemeMode.light : ThemeMode.dark);
  }
}
