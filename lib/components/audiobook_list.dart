import 'package:audiobook_manager/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../models/audiobook.dart';
import '../services/import_service.dart';
import 'audiobook_list.item.dart';

class AudiobookList extends ConsumerWidget {
  final List<AudioBook> audiobooks;
  final void Function(AudioBook)? onTap;
  final Widget Function(AudioBook)? leadingBuilder;
  final List<Widget> Function(AudioBook, BuildContext)? actionBuilder;

  const AudiobookList({
    super.key,
    required this.audiobooks,
    this.onTap,
    this.leadingBuilder,
    this.actionBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (audiobooks.isEmpty) {
      return const Center(child: Text('No audiobooks yet. Add some!'));
    }

    return ListView.builder(
      itemCount: audiobooks.length,
      itemBuilder: (context, index) {
        var audiobook = audiobooks[index];
        return AudiobookListItem(
          audiobook: audiobook,
          onTap: onTap,
          leadingBuilder: leadingBuilder,
          actionBuilder: actionBuilder ?? _defaultActionBuilder,
        );
      },
    );
  }

  List<Widget> _defaultActionBuilder(
      AudioBook audiobook, BuildContext context) {
    GlobalKey actionKey = GlobalKey();
    return [
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
            items: const [
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
          _deleteAudiobook(context, audiobook);
        },
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        icon: Icons.delete,
        label: 'Delete',
      ),
    ];
  }

  Future<void> _deleteAudiobook(
      BuildContext context, AudioBook audiobook) async {
    // Get ref using context
    final container = ProviderScope.containerOf(context);

    // Check if this is the currently playing book
    final playerState = container.read(audioPlayerProvider);
    await container
        .read(audiobooksProvider.notifier)
        .deleteAudiobooks({audiobook.id});
    if (audiobook.isFolder) {
      await ImportService.deleteFolder(audiobook.path);
    } else {
      await ImportService.deleteFile(audiobook.path);
    }
    if (playerState.currentBook?.id == audiobook.id) {
      // Clear the current book from the player
      await container.read(audioPlayerProvider.notifier).clearCurrentBook();
    }

    // Proceed with deletion
  }
}
