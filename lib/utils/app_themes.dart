import 'package:flutter/material.dart';

class AppThemes {
  // Brand color used across the app (matches login/register screens)
  static const Color _brandColor = Color(0xFF1B3A6B); // deep navy blue

  // Define light theme
  static ThemeData lightTheme = ThemeData(
    primaryColor: _brandColor,
    scaffoldBackgroundColor: Color(0xFFF4F6F9),
    brightness: Brightness.light,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: _brandColor,
      brightness: Brightness.light,
      primary: _brandColor,
      surface: Colors.white,
    ),
    cardColor: Colors.white,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: _brandColor,
      unselectedItemColor: Colors.grey,
    ),
  );

  // Define dark theme
  static ThemeData darkTheme = ThemeData(
    primaryColor: _brandColor,
    scaffoldBackgroundColor: Color(0xFF0E1420),
    brightness: Brightness.dark,
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF0E1420),
      elevation: 0,
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: _brandColor,
      brightness: Brightness.dark,
      primary: _brandColor,
      surface: Color(0xFF161D2B),
    ),
    cardColor: Color(0xFF161D2B),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF161D2B),
      selectedItemColor: _brandColor,
      unselectedItemColor: Colors.grey,
    ),
  );
}