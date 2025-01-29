import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
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
        id: Uuid().v4(),
        title: chapter.title,
        author: folder.author,
        duration: DurationFormatter.format(chapter.end - chapter.start),
        path: chapter.filePath!,
        coverImage: folder.coverImage,
        chapters: [
          Chapter(
            title: chapter.title,
            start: Duration.zero,
            end: chapter.end - chapter.start,
            filePath: chapter.filePath,
          )
        ],
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(folder.title),
      ),
      body: ReorderableListView.builder(
        itemCount: chapterBooks.length,
        onReorderStart: (_) {
          if (ref.read(playerUIProvider).isExpanded) {
            ref.read(playerUIProvider.notifier).setExpanded(false);
          }
        },
        onReorder: (oldIndex, newIndex) {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }

          final updatedChapters = [...folder.chapters];
          final chapter = updatedChapters.removeAt(oldIndex);
          updatedChapters.insert(newIndex, chapter);

          final updatedBook = folder.copyWith(chapters: updatedChapters);
          ref.read(audiobooksProvider.notifier).updateAudiobook(updatedBook);
        },
        itemBuilder: (context, index) {
          return KeyedSubtree(
            key: ValueKey(chapterBooks[index].id),
            child: AudiobookListItem(
              audiobook: chapterBooks[index], // Pass the parent folder
              onTap: (_) {
                final playerNotifier = ref.read(audioPlayerProvider.notifier);
                final uiState = ref.read(playerUIProvider.notifier);

                playerNotifier.setAudiobook(chapterBooks[index]).then((_) {
                  // playerNotifier.seekToChapter(index);
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
    );
  }
}
