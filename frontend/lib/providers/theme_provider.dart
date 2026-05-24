import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/themes.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'selected_theme';
  String _currentTheme = 'teal';

  ThemeProvider() {
    _loadTheme();
  }

  String get currentTheme => _currentTheme;

  ThemeData get themeData => AppThemes.allThemes[_currentTheme] ?? AppThemes.tealTheme;

  bool isTheme(String themeName) => _currentTheme == themeName;

  Future<void> setTheme(String themeName) async {
    if (AppThemes.allThemes.containsKey(themeName)) {
      _currentTheme = themeName;
      notifyListeners();
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_themeKey, themeName);
      } catch (e) {
        // Error saving theme, continue with in-memory theme change
      }
    }
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentTheme = prefs.getString(_themeKey) ?? 'teal';
      notifyListeners();
    } catch (e) {
      // Error loading theme preferences, use default
    }
  }
}
