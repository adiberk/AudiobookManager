import 'package:flutter/material.dart';

class AppTheme {
  // Original dark theme colors
  static const primaryColor = Color(0xFFBB86FC);
  static const secondaryColor = Color.fromARGB(255, 43, 164, 220);
  static const backgroundColor = Color(0xFF121212);
  static const surfaceColor = Color(0xFF1E1E1E);
  static const dividerColor = Color.fromARGB(255, 102, 101, 101);
  static const textColor = Color(0xFFE0E0E0);
  static const errorColor = Color(0xFFCF6679);

  // Original light theme colors
  static const lightPrimaryColor = Color(0xFF7C4DFF);
  static const lightSecondaryColor = Color(0xFF4DB6AC);
  static const lightBackgroundColor = Color(0xFFF5F5F7);
  static const lightSurfaceColor = Color(0xFFFFFFFF);
  static const lightDividerColor = Color(0xFFDADCE0);
  static const lightTextColor = Color(0xFF37474F);
  static const lightErrorColor = Color(0xFFEF5350);

  // Black theme colors
  static const blackPrimaryColor = Color(0xFF000000);
  static const blackSecondaryColor = Color(0xFF424242);
  static const blackBackgroundColor = Color(0xFF000000);
  static const blackSurfaceColor = Color(0xFF121212);
  static const blackTextColor = Color(0xFFFFFFFF);

  // Ocean theme colors
  static const oceanPrimaryColor = Color(0xFF006064);
  static const oceanSecondaryColor = Color(0xFF00ACC1);
  static const oceanBackgroundColor = Color(0xFF263238);
  static const oceanSurfaceColor = Color(0xFF37474F);
  static const oceanTextColor = Color(0xFFE0F7FA);

  // Sunset theme colors
  static const sunsetPrimaryColor = Color(0xFFFF9800);
  static const sunsetSecondaryColor = Color(0xFFFF5722);
  static const sunsetBackgroundColor = Color(0xFF3E2723);
  static const sunsetSurfaceColor = Color(0xFF4E342E);
  static const sunsetTextColor = Color(0xFFFFECB3);

  // Midnight Purple theme
  static const midnightPrimaryColor = Color(0xFF9B6DFF);
  static const midnightSecondaryColor = Color(0xFF7B4DFF);
  static const midnightBackgroundColor = Color(0xFF1A1625);
  static const midnightSurfaceColor = Color(0xFF2D2438);
  static const midnightTextColor = Color(0xFFE6E1F9);

  // Forest theme
  static const forestPrimaryColor = Color(0xFF4CAF50);
  static const forestSecondaryColor = Color(0xFF81C784);
  static const forestBackgroundColor = Color(0xFF1B2419);
  static const forestSurfaceColor = Color(0xFF2A362B);
  static const forestTextColor = Color(0xFFE8F5E9);

  // Nordic theme
  static const nordicPrimaryColor = Color(0xFF90A4AE);
  static const nordicSecondaryColor = Color(0xFF546E7A);
  static const nordicBackgroundColor = Color(0xFF1C2833);
  static const nordicSurfaceColor = Color(0xFF2C3E50);
  static const nordicTextColor = Color(0xFFECF0F1);

  // Rose Gold theme
  static const roseGoldPrimaryColor = Color(0xFFE0BFB8);
  static const roseGoldSecondaryColor = Color(0xFFCB8589);
  static const roseGoldBackgroundColor = Color(0xFF2D2123);
  static const roseGoldSurfaceColor = Color(0xFF3D2B2E);
  static const roseGoldTextColor = Color(0xFFF8EAE7);

  // Electric Blue theme
  static const electricPrimaryColor = Color(0xFF00E5FF);
  static const electricSecondaryColor = Color(0xFF00B8D4);
  static const electricBackgroundColor = Color(0xFF0A192F);
  static const electricSurfaceColor = Color(0xFF172A45);
  static const electricTextColor = Color(0xFFE6F1FF);

  // Emerald theme
  static const emeraldPrimaryColor = Color(0xFF2ECC71);
  static const emeraldSecondaryColor = Color(0xFF27AE60);
  static const emeraldBackgroundColor = Color(0xFF0C1F0F);
  static const emeraldSurfaceColor = Color(0xFF1A382B);
  static const emeraldTextColor = Color(0xFFE8F6EF);

  // Theme getters
  static ThemeData get darkTheme => _createTheme(
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
        backgroundColor: backgroundColor,
        surfaceColor: surfaceColor,
        textColor: textColor,
        isDark: true,
      );

  static ThemeData get lightTheme => _createTheme(
        primaryColor: lightPrimaryColor,
        secondaryColor: lightSecondaryColor,
        backgroundColor: lightBackgroundColor,
        surfaceColor: lightSurfaceColor,
        textColor: lightTextColor,
        isDark: false,
      );

  static ThemeData get blackTheme => _createTheme(
        primaryColor: blackPrimaryColor,
        secondaryColor: blackSecondaryColor,
        backgroundColor: blackBackgroundColor,
        surfaceColor: blackSurfaceColor,
        textColor: blackTextColor,
        isDark: true,
      );

  static ThemeData get oceanTheme => _createTheme(
        primaryColor: oceanPrimaryColor,
        secondaryColor: oceanSecondaryColor,
        backgroundColor: oceanBackgroundColor,
        surfaceColor: oceanSurfaceColor,
        textColor: oceanTextColor,
        isDark: true,
      );

  static ThemeData get sunsetTheme => _createTheme(
        primaryColor: sunsetPrimaryColor,
        secondaryColor: sunsetSecondaryColor,
        backgroundColor: sunsetBackgroundColor,
        surfaceColor: sunsetSurfaceColor,
        textColor: sunsetTextColor,
        isDark: true,
      );

  static ThemeData get midnightTheme => _createTheme(
        primaryColor: midnightPrimaryColor,
        secondaryColor: midnightSecondaryColor,
        backgroundColor: midnightBackgroundColor,
        surfaceColor: midnightSurfaceColor,
        textColor: midnightTextColor,
        isDark: true,
      );

  static ThemeData get forestTheme => _createTheme(
        primaryColor: forestPrimaryColor,
        secondaryColor: forestSecondaryColor,
        backgroundColor: forestBackgroundColor,
        surfaceColor: forestSurfaceColor,
        textColor: forestTextColor,
        isDark: true,
      );

  static ThemeData get nordicTheme => _createTheme(
        primaryColor: nordicPrimaryColor,
        secondaryColor: nordicSecondaryColor,
        backgroundColor: nordicBackgroundColor,
        surfaceColor: nordicSurfaceColor,
        textColor: nordicTextColor,
        isDark: true,
      );

  static ThemeData get roseGoldTheme => _createTheme(
        primaryColor: roseGoldPrimaryColor,
        secondaryColor: roseGoldSecondaryColor,
        backgroundColor: roseGoldBackgroundColor,
        surfaceColor: roseGoldSurfaceColor,
        textColor: roseGoldTextColor,
        isDark: true,
      );

  static ThemeData get electricTheme => _createTheme(
        primaryColor: electricPrimaryColor,
        secondaryColor: electricSecondaryColor,
        backgroundColor: electricBackgroundColor,
        surfaceColor: electricSurfaceColor,
        textColor: electricTextColor,
        isDark: true,
      );

  static ThemeData get emeraldTheme => _createTheme(
        primaryColor: emeraldPrimaryColor,
        secondaryColor: emeraldSecondaryColor,
        backgroundColor: emeraldBackgroundColor,
        surfaceColor: emeraldSurfaceColor,
        textColor: emeraldTextColor,
        isDark: true,
      );

  static ThemeData _createTheme({
    required Color primaryColor,
    required Color secondaryColor,
    required Color backgroundColor,
    required Color surfaceColor,
    required Color textColor,
    required bool isDark,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: primaryColor,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        background: backgroundColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: textColor,
        onSecondary: textColor,
        onBackground: textColor,
        onSurface: textColor,
        onError: textColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardColor: surfaceColor,
      dividerColor: dividerColor,
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: textColor),
        bodyMedium: TextStyle(color: textColor),
        bodySmall: TextStyle(color: textColor),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      listTileTheme: ListTileThemeData(
        tileColor: surfaceColor,
        textColor: textColor,
      ),
    );
  }
}
