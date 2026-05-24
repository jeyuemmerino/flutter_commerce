import 'package:flutter/material.dart';

class AppThemes {
  /// Teal theme (Original)
  static ThemeData get tealTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0EA5A4),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF8FAFC),
        foregroundColor: Color(0xFF0F172A),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  /// Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0EA5A4),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A2335),
        foregroundColor: Color(0xFFF8FAFC),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A2335),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  /// Purple theme
  static ThemeData get purpleTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF9333EA),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFFAF5FF),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFAF5FF),
        foregroundColor: Color(0xFF44337A),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  /// Blue theme
  static ThemeData get blueTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF3B82F6),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF0F9FF),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF0F9FF),
        foregroundColor: Color(0xFF1E3A8A),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  /// Orange theme
  static ThemeData get orangeTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFEA580C),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFFEF3C7),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFEF3C7),
        foregroundColor: Color(0xFF7C2D12),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  /// Green theme
  static ThemeData get greenTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF16A34A),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF0FDF4),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF0FDF4),
        foregroundColor: Color(0xFF15803D),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  /// Red theme
  static ThemeData get redTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFDC2626),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFFEF2F2),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFEF2F2),
        foregroundColor: Color(0xFF7F1D1D),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  /// Get all available themes
  static Map<String, ThemeData> get allThemes => {
        'teal': tealTheme,
        'dark': darkTheme,
        'purple': purpleTheme,
        'blue': blueTheme,
        'orange': orangeTheme,
        'green': greenTheme,
        'red': redTheme,
      };

  /// Get theme display names
  static Map<String, String> get themeNames => {
        'teal': 'Teal',
        'dark': 'Dark',
        'purple': 'Purple',
        'blue': 'Blue',
        'orange': 'Orange',
        'green': 'Green',
        'red': 'Red',
      };
}
