import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../components/audiobook_list.item.dart';
import '../providers/audiobook_provider.dart';
import '../providers/main_navigation_provider.dart';
import '../models/audiobook.dart';
import '../providers/providers.dart';
import '../utils/duration_formatter.dart';

// ... existing imports ...

class FolderContentsScreen extends ConsumerStatefulWidget {
  final String folderId;

  const FolderContentsScreen({
    super.key,
    required this.folderId,
  });

  @override
  ConsumerState<FolderContentsScreen> createState() =>
      _FolderContentsScreenState();
}

class _FolderContentsScreenState extends ConsumerState<FolderContentsScreen> {
  late List<Chapter> localChapters;

  @override
  void initState() {
    super.initState();
    final folder = ref
        .read(audiobooksProvider)
        .firstWhere((book) => book.id == widget.folderId);
    localChapters = [...folder.chapters];
  }

  @override
  Widget build(BuildContext context) {
    final audiobooks = ref.watch(audiobooksProvider);
    final folder = audiobooks.firstWhere((book) => book.id == widget.folderId);

    ref.listen<SelectedNavigationState>(
      selectedNavigationProvider,
      (previous, next) {
        if ((previous?.isNavigatingFolderContents ?? false) &&
            !next.isNavigatingFolderContents) {
          Navigator.of(context).pop();
        }
      },
    );

    final chapterBooks = localChapters.map((chapter) {
      return AudioBook(
        id: chapter.filePath ?? Uuid().v4(),
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

          setState(() {
            final chapter = localChapters.removeAt(oldIndex);
            localChapters.insert(newIndex, chapter);
          });

          // Update the persistent state after the animation
          final updatedBook = folder.copyWith(chapters: localChapters);
          ref.read(audiobooksProvider.notifier).updateAudiobook(updatedBook);
        },
        itemBuilder: (context, index) {
          return KeyedSubtree(
            key: ValueKey(chapterBooks[index].id),
            child: AudiobookListItem(
              audiobook: chapterBooks[index],
              onTap: (_) {
                final playerNotifier = ref.read(audioPlayerProvider.notifier);
                final uiState = ref.read(playerUIProvider.notifier);

                playerNotifier.setAudiobook(chapterBooks[index]).then((_) {
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
