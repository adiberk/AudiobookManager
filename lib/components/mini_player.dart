// lib/widgets/mini_player.dart
import 'dart:typed_data';

import 'package:audiobook_manager/components/conditional_marqee_text.dart';
import 'package:audiobook_manager/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(audioPlayerProvider);
    final uiState = ref.watch(playerUIProvider);
    final book = playerState.currentBook;

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
                      padding: const EdgeInsets.all(8.0),
                      child: Image.memory(
                        book?.coverImage! ?? Uint8List(0),
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                      ),
                    ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ConditionalMarquee(
                          text: book?.title ?? '',
                          style: const TextStyle(fontSize: 14),
                          maxWidth: 250,
                          velocity: 20,
                          pauseAfterRound: const Duration(seconds: 0),
                        ),
                        Text(
                          book?.author ?? '',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
