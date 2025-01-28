import 'package:audiobook_manager/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../models/audiobook.dart';
import 'conditional_marqee_text.dart';

class AudiobookListItem extends ConsumerWidget {
  final AudioBook audiobook;
  final void Function(AudioBook)? onTap;
  final Widget Function(AudioBook)? leadingBuilder;
  final List<Widget> Function(AudioBook, BuildContext) actionBuilder;

  const AudiobookListItem({
    super.key,
    required this.audiobook,
    this.onTap,
    this.leadingBuilder,
    required this.actionBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentBook = ref.watch(audioPlayerProvider).currentBook;
    return Slidable(
      key: Key(audiobook.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: actionBuilder(audiobook, context),
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
                audiobook.duration,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          onTap: () {
            if (onTap != null) {
              onTap!(audiobook);
            } else {
              _defaultOnTap(currentBook, audiobook, ref);
            }
          },
        ),
      ),
    );
  }

  Widget _defaultLeading() {
    return audiobook.coverImage != null
        ? Image.memory(
            audiobook.coverImage!,
            width: 55,
            height: 55,
            fit: BoxFit.cover,
          )
        : const Icon(Icons.book_rounded);
  }

  void _defaultOnTap(
      AudioBook? currentBook, AudioBook audiobook, WidgetRef ref) {
    final playerNotifier = ref.read(audioPlayerProvider.notifier);
    final uiState = ref.read(playerUIProvider.notifier);

    if (currentBook?.id != audiobook.id) {
      playerNotifier.clearCurrentBook();
      playerNotifier.setAudiobook(audiobook);
      playerNotifier.play();
      if (ref.read(playerUIProvider).isExpanded) {
        uiState.setExpanded(false);
      }
    }
  }
}
