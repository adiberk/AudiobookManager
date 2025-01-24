// lib/screens/main_screen.dart
import 'dart:io';

import 'package:audiobook_manager/components/import_audiobooks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:marquee/marquee.dart';
import 'package:uuid/uuid.dart';

import '../components/conditional_marqee_text.dart';
import '../models/audiobook.dart';
import '../providers/audiobook_provider.dart';
import '../services/file_service.dart';
import '../services/metadata_service.dart';
import 'audiobook_player_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => _buildPage(_selectedIndex),
          );
        },
      ),
      bottomSheet: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        child: Container(
          height: 55,
          color: Theme.of(context).colorScheme.secondary,
          child: Row(
            children: [
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Currently Playing Book'),
              ),
              IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () {},
              ),
            ],
          ),
        ),
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
    try {
      // Pick the file
      final File? pickedFile = await FileService.pickAudioFile();
      if (pickedFile == null) return;

      // Process the file (copy to app directory)
      final String? processedPath =
          await FileService.processAudioFile(pickedFile);
      if (processedPath == null) return;

      // Extract metadata
      final metadata = await MetadataService.extractMetadata(processedPath);

      // Create AudioBook object
      final audioBook = AudioBook(
        title: metadata['title'] ?? 'Unknown Title',
        author: metadata['author'] ?? 'Unknown Author',
        filePath: processedPath,
        duration: Duration(seconds: metadata['duration']['seconds'].round()),
        coverPhoto: metadata['cover_photo'],
        chapters: (metadata['chapters'] as List<Chapter>),
      );

      // Add to provider
      ref.read(audioBooksProvider.notifier).addAudioBook(audioBook);
    } catch (e) {
      print('Error processing audiobook: $e');
      // In a real app, you'd want to show an error message to the user
    }
  }

  // Delete
  Future<void> _deleteAudiobook(WidgetRef ref, AudioBook audiobook) async {
    await FileService.deleteFile(audiobook.filePath);
    ref.read(audioBooksProvider.notifier).removeAudioBook(audiobook.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audiobooks = ref.watch(audioBooksProvider);

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
      body: audiobooks.isEmpty
          ? const Center(child: Text('No audiobooks yet. Add some!'))
          : ListView.builder(
              itemCount: audiobooks.length,
              itemBuilder: (context, index) {
                var audiobook = audiobooks[index];
                GlobalKey actionKey = GlobalKey();

                return Slidable(
                  key: Key(audiobook.id), // Ensure a unique key
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(), // Smooth sliding motion
                    children: [
                      // More options button
                      SlidableAction(
                        key: actionKey,
                        onPressed: (context) {
                          final RenderBox renderBox = actionKey.currentContext!
                              .findRenderObject() as RenderBox;
                          final Offset offset =
                              renderBox.localToGlobal(Offset.zero);

                          showMenu(
                            context: context,
                            position: RelativeRect.fromLTRB(
                              offset.dx, // X position
                              offset.dy +
                                  renderBox.size.height, // Below the button
                              offset.dx + renderBox.size.width,
                              offset.dy +
                                  renderBox.size.height +
                                  50, // Adjust height
                            ),
                            items: [
                              PopupMenuItem(child: Text("Rename")),
                              PopupMenuItem(child: Text("Move to Folder")),
                            ],
                          );
                        },
                        // backgroundColor: Colors.grey.shade700,
                        // foregroundColor: Colors.white,
                        icon: Icons.more_vert,
                        label: 'More',
                      ),
                      // Delete button
                      SlidableAction(
                        onPressed: (context) {
                          _deleteAudiobook(ref, audiobook);
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: Card(
                    child: ListTile(
                      leading: audiobook.coverPhoto != null
                          ? Image.memory(
                              audiobook.coverPhoto!,
                              width: 55,
                              height: 55,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.book_rounded),
                      title: ConditionalMarquee(
                        text: audiobook.title,
                        style: const TextStyle(fontSize: 14),
                        maxWidth: 100,
                        velocity: 50,
                        pauseAfterRound: const Duration(seconds: 3),
                      ),
                      subtitle: Text(audiobook.author,
                          style: const TextStyle(fontSize: 12)),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                AudiobookPlayer(audiobook: audiobook),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
