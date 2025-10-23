import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF1E3A2E);
  static const Color secondaryColor = Color(0xFF3D6854);
  static const Color tertiaryColor = Color(0xFF5A967D);
  static const Color accentColor = Color(0xFF7EC4A6);
  static const Color errorColor = Color(0xFFE53935);
  static const Color backgroundColor = Color.fromARGB(255, 255, 255, 255);
  static const Color cardColor = Color.fromARGB(255, 255, 254, 254);
  static const Color textPrimary = Color(0xFF1E3A2E);
  static const Color textSecondary = Color(0xFF636E72);
  
  static const Color attendingColor = Color(0xFF5A967D);
  static const Color declinedColor = Color(0xFFE53935);
  static const Color maybeColor = Color(0xFFFF9800);
  static const Color pendingColor = Color(0xFF9E9E9E);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: tertiaryColor,
      error: errorColor,
    ),
    
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
  );
}