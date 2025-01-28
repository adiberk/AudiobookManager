import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/audiobook_list.dart';
import '../components/mini_player.dart';
import '../providers/providers.dart';
import 'audiobook_player_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Navigator(
            key: _navigatorKey,
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => _buildPage(_selectedIndex),
              );
            },
          ),
          const AudiobookPlayerScreen(),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0, // Position directly above nav bar
            child: const MiniPlayer(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
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
          setState(() {
            _selectedIndex = index;
          });
          // Close player if home button is tapped
          // if (index == 0) {
          ref.read(playerUIProvider.notifier).setExpanded(false);
          // }
          _navigatorKey.currentState?.popUntil((route) => route.isFirst);
        },
        backgroundColor: Theme.of(context).canvasColor,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        // unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed, // or .fixed
        elevation: 20,
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const Center(child: Text('Profile Page'));
      case 2:
        return const Center(child: Text('Settings Page'));
      default:
        return const HomeScreen();
    }
  }
}

// lib/screens/home_screen.dart
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _pickAndProcessAudiobook(WidgetRef ref) async {
    final importService = ref.read(importServiceProvider);
    try {
      final audiobookManager = ref.read(audiobooksProvider.notifier);
      // Pick the file
      final audiobooks = await importService.importFiles();
      for (final book in audiobooks) {
        await audiobookManager.addAudiobook(book);
      }
    } catch (e) {
      if (e is FileSystemException) {
        // Handle file system exceptions
      } else {
        // Handle other exceptions
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audiobooks = ref.watch(audiobooksProvider);

    return Scaffold(
        appBar: AppBar(
          title: const Text('AudioBook Player'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                await _pickAndProcessAudiobook(ref);
              },
            ),
          ],
        ),
        body: Stack(children: [
          audiobooks.isEmpty
              ? const Center(child: Text('No audiobooks yet. Add some!'))
              : AudiobookList(audiobooks: audiobooks),
          // const PlayerScreen(), // This will be hidden when no book is selected
        ]));
  }
}
