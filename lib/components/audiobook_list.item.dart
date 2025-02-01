import 'package:audiobook_manager/providers/audiobook_provider.dart';
import 'package:audiobook_manager/providers/main_navigation_provider.dart';
import 'package:audiobook_manager/providers/providers.dart';
import 'package:audiobook_manager/utils/duration_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:uuid/uuid.dart';

import '../models/audiobook.dart';
import '../screens/folder_contents_screen.dart';
import '../services/import_service.dart';
import 'conditional_marqee_text.dart';

class AudiobookListItem extends ConsumerWidget {
  final AudioBook audiobook;
  final void Function(AudioBook)? onTap;
  final Widget Function(AudioBook)? leadingBuilder;

  const AudiobookListItem({
    super.key,
    required this.audiobook,
    this.onTap,
    this.leadingBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentBook = ref.watch(audioPlayerProvider).currentBook;

    return Slidable(
      key: Key(audiobook.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        dismissible: DismissiblePane(
          onDismissed: () => _deleteAudiobook(context, ref),
        ),
        children: [
          SlidableAction(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            onPressed: (context) => _deleteAudiobook(context, ref),
          ),
        ],
      ),
      child: Card(
        child: ListTile(
          leading: leadingBuilder?.call(audiobook) ?? _defaultLeading(),
          title: Text(
            audiobook.title,
            style: const TextStyle(fontSize: 14),
            // maxWidth: 100,
            // velocity: 0,
            // pauseAfterRound: const Duration(seconds: 3),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(audiobook.author, style: const TextStyle(fontSize: 12)),
              Text(
                !audiobook.isFolder || audiobook.isJoinedVolume
                    ? audiobook.duration
                    : '${audiobook.chapters.length} files',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          trailing: PopupMenuButton(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            offset: const Offset(0, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            itemBuilder: (context) => [
              if (audiobook.isFolder && !audiobook.isJoinedVolume) ...[
                PopupMenuItem(
                  value: 'join_as_volume',
                  child: Row(
                    children: [
                      Icon(
                        Icons.merge_type_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Text('Join As Single Audiobook'),
                    ],
                  ),
                ),
              ],
              if (audiobook.isFolder && audiobook.isJoinedVolume) ...[
                PopupMenuItem(
                  value: 'unjoin',
                  child: Row(
                    children: [
                      Icon(
                        Icons.call_split_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Text('Unjoin'),
                    ],
                  ),
                ),
              ],
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      color: Theme.of(context).colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Delete'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              // Handle menu item selection
              switch (value) {
                case 'join_as_volume':
                  final updatedBook = audiobook.copyWith(isJoinedVolume: true);
                  ref
                      .read(audiobooksProvider.notifier)
                      .updateAudiobook(updatedBook);
                  break;
                case 'unjoin':
                  final audioState = ref.read(audioPlayerProvider);
                  final audioNotifier = ref.read(audioPlayerProvider.notifier);
                  if (audioState.currentBook?.id == audiobook.id) {
                    audioNotifier.clearCurrentBook();
                    ref
                        .read(audioPlayerProvider.notifier)
                        .setAudiobook(AudioBook(
                          id: Uuid().v4(),
                          duration: DurationFormatter.format(audiobook
                                  .chapters[audiobook.currentChapterIndex].end -
                              audiobook.chapters[audiobook.currentChapterIndex]
                                  .start),
                          title: audiobook
                              .chapters[audiobook.currentChapterIndex].title,
                          author: audiobook.author,
                          path: audiobook
                                  .chapters[audiobook.currentChapterIndex]
                                  .filePath ??
                              '',
                          isFolder: false,
                          isJoinedVolume: false,
                          chapters: [
                            audiobook.chapters[audiobook.currentChapterIndex]
                          ],
                          coverImage: audiobook.coverImage,
                        ))
                        .then((_) {
                      ref.read(playerUIProvider.notifier).setExpanded(false);
                      audioNotifier.play();
                    });
                  }
                  final updatedBook = audiobook.copyWith(isJoinedVolume: false);
                  ref
                      .read(audiobooksProvider.notifier)
                      .updateAudiobook(updatedBook);
                  break;
                case 'delete':
                  _deleteAudiobook(context, ref);
                  break;
              }
            },
          ),
          onTap: () {
            if (onTap != null) {
              onTap!(audiobook);
            } else {
              _defaultOnTap(context, currentBook, ref);
            }
          },
        ),
      ),
    );
  }

  Widget _defaultLeading() {
    if (audiobook.isFolder) {
      if (audiobook.isJoinedVolume) {
        return audiobook.coverImage != null
            ? Image.memory(
                audiobook.coverImage!,
                width: 55,
                height: 55,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.book_rounded);
      } else {
        // return large folder icon
        return const Icon(Icons.folder_rounded, size: 55);
      }
    } else {
      return audiobook.coverImage != null
          ? Image.memory(
              audiobook.coverImage!,
              width: 55,
              height: 55,
              fit: BoxFit.cover,
            )
          : const Icon(Icons.book_rounded);
    }
  }

  void _defaultOnTap(
      BuildContext context, AudioBook? currentBook, WidgetRef ref) {
    // logic is that if we are clikcing on a folder, we should navigate to the folder contents
    if (audiobook.isFolder && !audiobook.isJoinedVolume) {
      // ref.read(selectedNavigationIndexProvider.notifier).state = 100;
      ref
          .read(selectedNavigationProvider.notifier)
          .setNavigatingFolderContents(true);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FolderContentsScreen(folderId: audiobook.id),
        ),
      );
    } else {
      final playerNotifier = ref.read(audioPlayerProvider.notifier);
      final uiState = ref.read(playerUIProvider.notifier);

      if (currentBook?.id != audiobook.id) {
        playerNotifier.setAudiobook(audiobook).then((_) {
          playerNotifier.play();
        });

        if (ref.read(playerUIProvider).isExpanded) {
          uiState.setExpanded(false);
        }
      }
    }
  }

  Future<void> _deleteAudiobook(BuildContext context, WidgetRef ref) async {
    // Store necessary values before deletion
    final playerState = ref.read(audioPlayerProvider);
    final currentBookId = playerState.currentBook?.id;
    final audiobooksNotifier = ref.read(audiobooksProvider.notifier);
    final playerNotifier = ref.read(audioPlayerProvider.notifier);

    try {
      // Delete from storage first
      if (audiobook.isFolder) {
        await ImportService.deleteFolder(audiobook.path);
      } else {
        await ImportService.deleteFile(audiobook.path);
      }

      // Then update the UI state
      await audiobooksNotifier.deleteAudiobooks({audiobook.id});

      // Clear player if current book was deleted
      if (currentBookId == audiobook.id) {
        await playerNotifier.clearCurrentBook();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting audiobook: $e')),
        );
      }
    }
  }
}
