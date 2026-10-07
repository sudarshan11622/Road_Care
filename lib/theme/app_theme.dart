import 'package:flutter/material.dart';

class AppTheme {
  static const blue = Color(0xFF1769FF);
  static const dark = Color(0xFF101828);
  static const text = Color(0xFF1D2939);
  static const muted = Color(0xFF667085);
  static const border = Color(0xFFE4E7EC);
  static const surface = Color(0xFFF8FAFC);
  static const green = Color(0xFF12B76A);
  static const orange = Color(0xFFF79009);
  static const red = Color(0xFFF04438);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: blue,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(primary: blue),
      scaffoldBackgroundColor: surface,
      fontFamily: 'Arial',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: text,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: blue, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: blue,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme.copyWith(primary: blue),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      fontFamily: 'Arial',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF111827),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF374151)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF374151)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: blue, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF111827),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF374151)),
        ),
      ),
    );
  }
}
