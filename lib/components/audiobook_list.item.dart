import 'package:audiobook_manager/providers/audiobook_provider.dart';
import 'package:audiobook_manager/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
          title: ConditionalMarquee(
            text: audiobook.title,
            style: const TextStyle(fontSize: 14),
            maxWidth: 100,
            velocity: 40,
            pauseAfterRound: const Duration(seconds: 3),
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
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              if (audiobook.isFolder && !audiobook.isJoinedVolume) ...[
                const PopupMenuItem(
                  value: 'join_as_volume',
                  child: Text('Join as Volume'),
                ),
              ],
              if (audiobook.isFolder && audiobook.isJoinedVolume) ...[
                const PopupMenuItem(
                  value: 'unjoin',
                  child: Text('Unjoin'),
                ),
              ],
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FolderContentsScreen(folder: audiobook),
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
    final playerState = ref.read(audioPlayerProvider);

    await ref
        .read(audiobooksProvider.notifier)
        .deleteAudiobooks({audiobook.id});

    if (audiobook.isFolder) {
      await ImportService.deleteFolder(audiobook.path);
    } else {
      await ImportService.deleteFile(audiobook.path);
    }

    if (playerState.currentBook?.id == audiobook.id) {
      await ref.read(audioPlayerProvider.notifier).clearCurrentBook();
    }
  }
}
