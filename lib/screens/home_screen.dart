import 'dart:io';
import 'package:audiobook_manager/providers/main_navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/audiobook_list.dart';
import '../components/bottom_navbar.dart';
import '../components/mini_player.dart';
import '../providers/audiobook_provider.dart';
import '../providers/providers.dart';
import 'audiobook_player_screen.dart';
import 'settings_screen.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(selectedNavigationProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Main content using IndexedStack
          IndexedStack(
            index: navigationState.index,
            children: [
              Navigator(
                onGenerateRoute: (settings) {
                  return MaterialPageRoute(
                    builder: (_) => const HomeScreen(),
                  );
                },
              ),
              const Center(child: Text('Profile Page')),
              Navigator(
                onGenerateRoute: (settings) {
                  return MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  );
                },
              ),
            ],
          ),
          // Player UI layers
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
}

// lib/screens/home_screen.dart
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _pickAndProcessAudiobook(
      WidgetRef ref, String importType) async {
    final importService = ref.read(importServiceProvider);
    try {
      final audiobookManager = ref.read(audiobooksProvider.notifier);
      if (importType == 'files') {
        await for (final audiobook in importService.importFiles()) {
          await audiobookManager.addAudiobook(audiobook);
        }
        // final audiobooks = await importService.importFiles();
        // for (final book in audiobooks) {
        //   await audiobookManager.addAudiobook(book);
        // }
      } else if (importType == 'folder') {
        final book = await importService.importFolder();
        if (book != null) {
          await audiobookManager.addAudiobook(book);
        }
      }
    } catch (e) {
      if (e is FileSystemException) {
        // Handle file system exceptions
      } else {
        // Handle other exceptions
      }
    }
  }

  void _showSortOptions(BuildContext context, WidgetRef ref) {
    final sortOption = ref.watch(sortOptionProvider);
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Title'),
                leading: Radio<String>(
                  value: 'title',
                  groupValue: sortOption,
                  onChanged: (value) {
                    ref.read(sortOptionProvider.notifier).state = value!;
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text('Author'),
                leading: Radio<String>(
                  value: 'author',
                  groupValue: sortOption,
                  onChanged: (value) {
                    ref.read(sortOptionProvider.notifier).state = value!;
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audiobooks = ref.watch(audiobooksProvider);
    final sortOption = ref.watch(sortOptionProvider);

    final sortedAudiobooks = [...audiobooks]..sort((a, b) {
        switch (sortOption) {
          case 'title':
            return a.title.compareTo(b.title);
          case 'author':
            return a.author.compareTo(b.author);
          default:
            return 0;
        }
      });
    return Scaffold(
        appBar: AppBar(
          title: const Text('AudioBook Player'),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.add),
              offset: const Offset(0, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              onSelected: (String choice) =>
                  _pickAndProcessAudiobook(ref, choice),
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'files',
                  child: Row(
                    children: [
                      Icon(
                        Icons.file_present_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Text('Import Files'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'folder',
                  child: Row(
                    children: [
                      Icon(
                        Icons.folder_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Text('Import Folder'),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
        body: Stack(children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.sort),
                      label: const Text('Sort'),
                      onPressed: () => _showSortOptions(context, ref),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: sortedAudiobooks.isEmpty
                    ? const Center(child: Text('No audiobooks yet. Add some!'))
                    : AudiobookList(audiobooks: sortedAudiobooks),
              ),
            ],
          ),
        ]));
  }
}
