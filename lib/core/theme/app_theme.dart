import 'package:flutter/material.dart';

class AppTheme {
  static const primaryPurple = Color(0xFF6153FF);
  static const darkBg = Color(0xFF161B2E);
  static const darkCard = Color(0xFF20263F);
  
  static const lightBg = Color(0xFFF6F6FC);
  static const lightCard = Colors.white;

  // Premium Dark Mode Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryPurple,
    scaffoldBackgroundColor: darkBg,
    cardColor: darkCard,
    dividerColor: const Color(0xFF2D3555),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBg,
      elevation: 0,
      centerTitle: true,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Color(0xFFC1C6D9)),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    colorScheme: const ColorScheme.dark(
      primary: primaryPurple,
      surface: darkCard,
      onPrimary: Colors.white,
      onSurface: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );

  // Premium Light Mode Theme (App Classic)
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryPurple,
    scaffoldBackgroundColor: lightBg,
    cardColor: lightCard,
    dividerColor: const Color(0xFFEAEBFA),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBg,
      elevation: 0,
      centerTitle: true,
      foregroundColor: Color(0xFF14142B),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF14142B)),
      bodyMedium: TextStyle(color: Color(0xFF5A5A6D)),
      titleLarge: TextStyle(color: Color(0xFF14142B), fontWeight: FontWeight.bold),
    ),
    colorScheme: const ColorScheme.light(
      primary: primaryPurple,
      surface: lightCard,
      onPrimary: Colors.white,
      onSurface: Color(0xFF14142B),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );

  // Backwards compatibility alias
  static final ThemeData focusTheme = darkTheme;
}
