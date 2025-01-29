import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(_getThemeName(currentTheme)),
            onTap: () => _showThemeSelector(context, ref),
          ),
        ],
      ),
    );
  }

  String _getThemeName(ThemeSelection theme) {
    switch (theme) {
      case ThemeSelection.system:
        return 'System Default';
      case ThemeSelection.light:
        return 'Light';
      case ThemeSelection.dark:
        return 'Dark';
      case ThemeSelection.black:
        return 'Black';
      case ThemeSelection.ocean:
        return 'Ocean';
      case ThemeSelection.sunset:
        return 'Sunset';
      case ThemeSelection.midnightPurple:
        return 'Midnight Purple';
      case ThemeSelection.forest:
        return 'Forest';
      case ThemeSelection.nordic:
        return 'Nordic';
      case ThemeSelection.roseGold:
        return 'Rose Gold';
      case ThemeSelection.electricBlue:
        return 'Electric Blue';
      case ThemeSelection.emerald:
        return 'Emerald';
    }
  }

  void _showThemeSelector(BuildContext context, WidgetRef ref) async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: ThemeSelection.values.map((theme) {
              return ListTile(
                title: Text(_getThemeName(theme)),
                onTap: () {
                  ref.read(themeProvider.notifier).setTheme(theme);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
