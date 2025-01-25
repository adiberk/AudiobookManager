// lib/widgets/mini_player.dart
import 'package:audiobook_manager/components/conditional_marqee_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/player_provider.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider);
    final book = playerState.currentBook;

    if (book == null || playerState.isExpanded) return const SizedBox.shrink();

    return GestureDetector(
        onTap: () => ref.read(playerProvider.notifier).toggleExpanded(),
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
              if (book.coverPhoto != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.memory(
                    book.coverPhoto!,
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
                      text: book.title,
                      style: const TextStyle(fontSize: 14),
                      maxWidth: 250,
                      velocity: 20,
                      pauseAfterRound: const Duration(seconds: 3),
                    ),
                    Text(
                      book.author,
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
                  ref.read(playerProvider.notifier).togglePlay();
                },
              ),
            ],
          ),
        ));
  }
}
