import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/hive_storage_service.dart';

enum ThemeSelection {
  system,
  light,
  dark,
  black,
  ocean,
  sunset,
  midnightPurple,
  forest,
  nordic,
  roseGold,
  electricBlue,
  emerald
}

final themeProvider =
    StateNotifierProvider<ThemeNotifier, ThemeSelection>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeSelection> {
  ThemeNotifier() : super(ThemeSelection.system) {
    _loadTheme();
  }

  void _loadTheme() async {
    final settings = await HiveStorageService().loadUserSettings();
    state = settings.selectedTheme;
  }

  void setTheme(ThemeSelection theme) async {
    state = theme;
    final settings = await HiveStorageService().loadUserSettings();
    final updatedSettings = settings.copyWith(selectedTheme: theme);
    await HiveStorageService().updateUserSettings(updatedSettings);
  }
}
