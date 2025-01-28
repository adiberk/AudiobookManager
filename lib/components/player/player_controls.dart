import 'package:audiobook_manager/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerControls extends ConsumerWidget {
  const PlayerControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioPlayerState = ref.watch(audioPlayerProvider);
    final currentChapterIndex = ref.watch(currentChapterIndexProvider);
    final audiobook = audioPlayerState.currentBook;
    if (audiobook == null) {
      return const SizedBox();
    }
    final currentChapter = audiobook.isJoinedVolume
        ? audiobook.chapters[currentChapterIndex]
        : ref.watch(currentChapterProvider(audioPlayerState.position));
    Duration chapterPosition;
    Duration chapterDuration;

    if (audiobook.isJoinedVolume) {
      // For joined volumes, we want the position relative to the current chapter
      chapterPosition = audioPlayerState.position;
      chapterDuration = currentChapter.end - currentChapter.start;
    } else {
      // For single files, calculate relative to chapter start
      chapterPosition = audioPlayerState.position - currentChapter.start;
      chapterDuration = currentChapter.end - currentChapter.start;
    }

    // Ensure position is within bounds
    chapterPosition = Duration(
        milliseconds: chapterPosition.inMilliseconds
            .clamp(0, chapterDuration.inMilliseconds));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildControlButton(
          icon: Icons.skip_previous,
          onPressed: () {
            final audioPlayer = ref.read(audioPlayerProvider.notifier);
            if (audiobook.isJoinedVolume) {
              if (currentChapterIndex > 0) {
                audioPlayer.skipToPrevious();
                ref.read(currentChapterIndexProvider.notifier).state =
                    currentChapterIndex - 1;
              }
            } else {
              // For non-joined volumes, calculate the previous chapter based on current position
              final currentChapter =
                  ref.read(currentChapterProvider(audioPlayerState.position));
              final currentIndex = audiobook.chapters.indexOf(currentChapter);
              if (currentIndex > 0) {
                final previousChapter = audiobook.chapters[currentIndex - 1];
                audioPlayer.seek(
                    previousChapter.start + const Duration(milliseconds: 1));
              }
            }
          },
        ),
        _buildControlButton(
          icon: Icons.replay_30,
          onPressed: () {
            ref.read(audioPlayerProvider.notifier).skipBackward();
          },
        ),
        _buildPlayButton(context),
        _buildControlButton(
            icon: Icons.forward_30,
            onPressed: () {
              ref.read(audioPlayerProvider.notifier).skipForward();
            }),
        _buildControlButton(
          icon: Icons.skip_next,
          onPressed: () {
            final audioPlayer = ref.read(audioPlayerProvider.notifier);
            if (audiobook.isJoinedVolume) {
              if (currentChapterIndex < audiobook.chapters.length - 1) {
                audioPlayer.skipToNext();
                ref.read(currentChapterIndexProvider.notifier).state =
                    currentChapterIndex + 1;
              }
            } else {
              // For non-joined volumes, calculate the next chapter based on current position
              final currentChapter =
                  ref.read(currentChapterProvider(audioPlayerState.position));
              final currentIndex = audiobook.chapters.indexOf(currentChapter);
              if (currentIndex < audiobook.chapters.length - 1) {
                final nextChapter = audiobook.chapters[currentIndex + 1];
                audioPlayer
                    .seek(nextChapter.start + const Duration(milliseconds: 1));
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon),
      iconSize: 32,
      onPressed: onPressed,
    );
  }

  Widget _buildPlayButton(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final isPlaying = ref.watch(audioPlayerProvider).isPlaying;
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.secondary,
          ),
          child: IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            iconSize: 48,
            color: Colors.white,
            onPressed: () {
              final audioPlayer = ref.read(audioPlayerProvider.notifier);
              audioPlayer.togglePlayPause();
            },
          ),
        );
      },
    );
  }
}
