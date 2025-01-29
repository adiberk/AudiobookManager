import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/audiobook_list.item.dart';
import '../components/mini_player.dart';
import '../components/bottom_navbar.dart';
import '../providers/audiobook_provider.dart';
import '../screens/audiobook_player_screen.dart';
import '../models/audiobook.dart';
import '../providers/providers.dart';
import '../utils/duration_formatter.dart';

class FolderContentsScreen extends ConsumerWidget {
  final AudioBook folder;

  const FolderContentsScreen({
    super.key,
    required this.folder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Create virtual audiobooks from the chapters
    final chapterBooks = folder.chapters.map((chapter) {
      return AudioBook(
        title: chapter.title,
        author: folder.author,
        duration: DurationFormatter.format(chapter.end - chapter.start),
        path: chapter.filePath!,
        coverImage: folder.coverImage,
        chapters: [chapter],
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(folder.title),
      ),
      body: Stack(
        children: [
          ReorderableListView.builder(
            itemCount: chapterBooks.length,
            onReorderStart: (_) {
              // Close mini player if it's expanded
              if (ref.read(playerUIProvider).isExpanded) {
                ref.read(playerUIProvider.notifier).setExpanded(false);
              }
            },
            onReorder: (oldIndex, newIndex) {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }

              // Update the folder's chapters order
              final updatedChapters = [...folder.chapters];
              final chapter = updatedChapters.removeAt(oldIndex);
              updatedChapters.insert(newIndex, chapter);

              // Create updated audiobook
              final updatedBook = folder.copyWith(chapters: updatedChapters);

              // Update in provider
              ref
                  .read(audiobooksProvider.notifier)
                  .updateAudiobook(updatedBook);
            },
            itemBuilder: (context, index) {
              return KeyedSubtree(
                key: ValueKey(chapterBooks[index].id),
                child: AudiobookListItem(
                  audiobook: chapterBooks[index],
                  onTap: (audiobook) {
                    final playerNotifier =
                        ref.read(audioPlayerProvider.notifier);
                    final uiState = ref.read(playerUIProvider.notifier);

                    playerNotifier.setAudiobook(folder).then((_) {
                      playerNotifier.seekToChapter(index);
                      playerNotifier.play();
                    });

                    if (ref.read(playerUIProvider).isExpanded) {
                      uiState.setExpanded(false);
                    }
                  },
                ),
              );
            },
          ),
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
