import 'package:audiobook_manager/utils/duration_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../models/audiobook.dart';
import '../providers/audiobook_provider.dart';
import '../providers/player_provider.dart';
import '../services/file_service.dart';
import 'conditional_marqee_text.dart';

class AudiobookList extends ConsumerWidget {
  final List<AudioBook> audiobooks;
  const AudiobookList({super.key, required this.audiobooks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (audiobooks.isEmpty) {
      return const Center(child: Text('No audiobooks yet. Add some!'));
    }

    return ListView.builder(
      itemCount: audiobooks.length,
      itemBuilder: (context, index) {
        var audiobook = audiobooks[index];
        GlobalKey actionKey = GlobalKey();

        return Slidable(
          key: Key(audiobook.id),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                key: actionKey,
                onPressed: (context) {
                  final RenderBox renderBox =
                      actionKey.currentContext!.findRenderObject() as RenderBox;
                  final Offset offset = renderBox.localToGlobal(Offset.zero);

                  showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(
                      offset.dx,
                      offset.dy + renderBox.size.height,
                      offset.dx + renderBox.size.width,
                      offset.dy + renderBox.size.height + 50,
                    ),
                    items: [
                      PopupMenuItem(child: Text("Rename")),
                      PopupMenuItem(child: Text("Move to Folder")),
                    ],
                  );
                },
                icon: Icons.more_vert,
                label: 'More',
              ),
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
                velocity: 40,
                pauseAfterRound: const Duration(seconds: 3),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(audiobook.author, style: const TextStyle(fontSize: 12)),
                  Text(
                    DurationFormatter.format(audiobook.duration),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              onTap: () {
                final playerNotifier = ref.read(playerProvider.notifier);
                final currentBook = ref.read(playerProvider).currentBook;

                if (currentBook?.id != audiobook.id) {
                  //   // If the same book is selected, just toggle expanded state
                  //   playerNotifier.toggleExpanded();
                  // } else {
                  // If different book, start playing and ensure player is expanded
                  playerNotifier.playBook(audiobook);
                  playerNotifier.setExpanded(false);
                }
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteAudiobook(WidgetRef ref, AudioBook audiobook) async {
    // Check if this is the currently playing book
    final playerState = ref.read(playerProvider);
    if (playerState.currentBook?.id == audiobook.id) {
      // Clear the current book from the player
      ref.read(playerProvider.notifier).clearCurrentBook();
    }

    // Proceed with deletion
    await FileService.deleteFile(audiobook.filePath);
    ref.read(audioBooksProvider.notifier).removeAudioBook(audiobook.id);
  }
}
