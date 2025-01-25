import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const primaryColor = Color(0xFFBB86FC); // Light Purple
  static const secondaryColor = Color.fromARGB(255, 43, 164, 220);
  static const backgroundColor = Color(0xFF121212); // Deep Black
  static const surfaceColor = Color(0xFF1E1E1E); // Dark Gray
  static const dividerColor = Color.fromARGB(255, 102, 101, 101);
  static const textColor = Color(0xFFE0E0E0); // Light Gray Text
  static const errorColor = Color(0xFFCF6679); // Pinkish Red

  // Light Theme Colors
  static const lightPrimaryColor = Color(0xFF7C4DFF); // Softer Purple
  static const lightSecondaryColor = Color(0xFF4DB6AC); // Muted Teal
  static const lightBackgroundColor = Color(0xFFF5F5F7); // Warm Soft Gray-White
  static const lightSurfaceColor = Color(0xFFFFFFFF); // Clean White
  static const lightDividerColor = Color(0xFFDADCE0); // Softer Gray
  static const lightTextColor = Color(0xFF37474F);
  static const lightErrorColor = Color(0xFFEF5350); // Soft Red

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      background: backgroundColor,
      surface: surfaceColor,
      error: errorColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    dividerColor: dividerColor,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textColor),
      bodyMedium: TextStyle(color: textColor),
      bodySmall: TextStyle(color: textColor),
    ),
    cardColor: surfaceColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      titleTextStyle: TextStyle(
          color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    listTileTheme: const ListTileThemeData(
      tileColor: surfaceColor,
      textColor: textColor,
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: lightPrimaryColor,
    colorScheme: const ColorScheme.light(
      primary: lightPrimaryColor,
      secondary: lightSecondaryColor,
      // background: lightBackgroundColor,
      surface: lightSurfaceColor,
      error: lightErrorColor,
      onSurface: lightTextColor,
    ),
    scaffoldBackgroundColor: lightBackgroundColor,
    dividerColor: lightDividerColor,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: lightTextColor),
      bodyMedium: TextStyle(color: lightTextColor),
      bodySmall: TextStyle(color: lightTextColor),
    ),
    cardColor: lightSurfaceColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: lightSurfaceColor,
      elevation: 0,
      titleTextStyle: TextStyle(
          color: lightTextColor, fontSize: 20, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(color: lightTextColor),
    ),
    listTileTheme: const ListTileThemeData(
      tileColor: lightSurfaceColor,
      textColor: lightTextColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightPrimaryColor,
        foregroundColor: Colors.white,
      ),
    ),
  );
}
