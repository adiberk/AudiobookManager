import 'package:audiobook_manager/providers/main_navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';

class BottomNavBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(selectedNavigationProvider);
    return BottomNavigationBar(
      currentIndex: navigationState.index,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
      onTap: (index) {
        // Update the selected index using the provider
        final navigationNotifier =
            ref.read(selectedNavigationProvider.notifier);
        navigationNotifier.updateIndex(index);
        if (index == 0) {
          navigationNotifier.setNavigatingFolderContents(false);
        }

        // Close player when switching tabs
        ref.read(playerUIProvider.notifier).setExpanded(false);
      },
      backgroundColor: Theme.of(context).canvasColor,
      selectedItemColor: Theme.of(context).colorScheme.secondary,
      type: BottomNavigationBarType.fixed,
      elevation: 20,
    );
  }
}
