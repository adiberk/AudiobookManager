import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/audiobook_list.dart';
import '../components/bottom_navbar.dart';
import '../components/mini_player.dart';
import '../providers/providers.dart';
import 'audiobook_player_screen.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedNavigationIndexProvider);

    return Scaffold(
      body: Stack(
        children: [
          _buildPage(selectedIndex),
          const AudiobookPlayerScreen(),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MiniPlayer(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(),
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
