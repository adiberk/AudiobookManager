import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const primaryColor = Color(0xFFBB86FC); // Light Purple
  static const secondaryColor = Color.fromARGB(255, 43, 164, 220);
  static const backgroundColor = Color(0xFF121212); // Deep Black
  static const surfaceColor = Color(0xFF1E1E1E); // Dark Gray
  static const dividerColor =
      Color.fromARGB(255, 102, 101, 101); // Subtle Divider
  static const textColor = Color(0xFFE0E0E0); // Light Gray Text
  static const errorColor = Color(0xFFCF6679); // Pinkish Red

  // Light Theme Colors
  static const lightPrimaryColor = Color(0xFF6200EE);
  static const lightSecondaryColor = Color.fromARGB(255, 20, 203, 184);
  static const lightBackgroundColor = Color(0xFFF5F5F5);
  static const lightSurfaceColor = Color(0xFFFFFFFF);
  static const lightDividerColor = Color(0xFFE0E0E0);
  static const lightTextColor = Color(0xFF212121);
  static const lightErrorColor = Color(0xFFB00020);

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
      background: lightBackgroundColor,
      surface: lightSurfaceColor,
      error: lightErrorColor,
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
      backgroundColor: Color.fromARGB(214, 245, 245, 245),
      titleTextStyle: TextStyle(
          color: lightTextColor, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    listTileTheme: const ListTileThemeData(
      tileColor: lightSurfaceColor,
      textColor: lightTextColor,
    ),
  );
}
