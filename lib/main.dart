import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';
import 'services/hive_storage_service.dart';
import 'themes/app_theme.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveStorageService().init();

  runApp(
    const ProviderScope(
      child: AudioBookApp(),
    ),
  );
}

class AudioBookApp extends ConsumerWidget {
  const AudioBookApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'AudioBook Player',
      theme: _getTheme(themeMode),
      darkTheme: _getDarkTheme(themeMode),
      themeMode: _getThemeMode(themeMode),
      home: const MainScreen(),
    );
  }

  ThemeData _getTheme(ThemeSelection mode) {
    switch (mode) {
      case ThemeSelection.system:
      case ThemeSelection.light:
        return AppTheme.lightTheme;
      case ThemeSelection.dark:
        return AppTheme.darkTheme;
      case ThemeSelection.black:
        return AppTheme.blackTheme;
      case ThemeSelection.ocean:
        return AppTheme.oceanTheme;
      case ThemeSelection.sunset:
        return AppTheme.sunsetTheme;
      case ThemeSelection.midnightPurple:
        return AppTheme.midnightTheme;
      case ThemeSelection.forest:
        return AppTheme.forestTheme;
      case ThemeSelection.nordic:
        return AppTheme.nordicTheme;
      case ThemeSelection.roseGold:
        return AppTheme.roseGoldTheme;
      case ThemeSelection.electricBlue:
        return AppTheme.electricTheme;
      case ThemeSelection.emerald:
        return AppTheme.emeraldTheme;
    }
  }

  ThemeData _getDarkTheme(ThemeSelection mode) {
    switch (mode) {
      case ThemeSelection.system:
      case ThemeSelection.dark:
        return AppTheme.darkTheme;
      case ThemeSelection.black:
        return AppTheme.blackTheme;
      case ThemeSelection.ocean:
        return AppTheme.oceanTheme;
      case ThemeSelection.sunset:
        return AppTheme.sunsetTheme;
      case ThemeSelection.light:
        return AppTheme.darkTheme; // Fallback for light mode
      case ThemeSelection.midnightPurple:
        return AppTheme.midnightTheme;
      case ThemeSelection.forest:
        return AppTheme.forestTheme;
      case ThemeSelection.nordic:
        return AppTheme.nordicTheme;
      case ThemeSelection.roseGold:
        return AppTheme.roseGoldTheme;
      case ThemeSelection.electricBlue:
        return AppTheme.electricTheme;
      case ThemeSelection.emerald:
        return AppTheme.emeraldTheme;
    }
  }

  ThemeMode _getThemeMode(ThemeSelection mode) {
    switch (mode) {
      case ThemeSelection.system:
        return ThemeMode.system;
      case ThemeSelection.light:
        return ThemeMode.light;
      case ThemeSelection.dark:
      case ThemeSelection.black:
      case ThemeSelection.ocean:
      case ThemeSelection.midnightPurple:
      case ThemeSelection.forest:
      case ThemeSelection.nordic:
      case ThemeSelection.roseGold:
      case ThemeSelection.electricBlue:
      case ThemeSelection.emerald:
      case ThemeSelection.sunset:
        return ThemeMode.dark;
    }
  }
}
