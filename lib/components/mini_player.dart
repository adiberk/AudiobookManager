// lib/widgets/mini_player.dart
import 'dart:typed_data';

import 'package:audiobook_manager/components/conditional_marqee_text.dart';
import 'package:audiobook_manager/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/audiobook.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(audioPlayerProvider);
    final uiState = ref.watch(playerUIProvider);
    final book = playerState.currentBook;
    final currentChapterIndex = ref.watch(currentChapterIndexProvider);
    final audioPlayerState = ref.watch(audioPlayerProvider.notifier);

    Chapter? currentChapter = null;
    if (book != null) {
      currentChapter = book.isJoinedVolume == true
          ? book.chapters[currentChapterIndex]
          : ref.watch(currentChapterProvider(audioPlayerState.position));
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      transform: Matrix4.translationValues(
        0,
        uiState.isExpanded ? 60 : 0,
        0,
      ),
      child: Visibility(
        visible: book != null,
        maintainState: true,
        maintainAnimation: true,
        maintainSize: true,
        child: GestureDetector(
          onTap: () {
            ref.read(playerUIProvider.notifier).toggleExpanded();
          },
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (book?.coverImage != null)
                    Padding(
                      padding: const EdgeInsets.all(7),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.memory(
                          book?.coverImage! ?? Uint8List(0),
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ConditionalMarquee(
                            text: book?.title ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxWidth: 280,
                            velocity: 20,
                            pauseAfterRound: const Duration(seconds: 1),
                          ),
                          Text(
                            book?.author ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondary
                                  .withOpacity(0.8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (currentChapter != null &&
                              book != null &&
                              book.chapters.length > 1) ...[
                            Text(
                              currentChapter.title,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondary
                                    .withOpacity(0.7),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      ref.read(audioPlayerProvider.notifier).togglePlayPause();
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
