import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/chapter_state_provider.dart';
import '../../providers/providers.dart';

class PlayerControls extends ConsumerWidget {
  const PlayerControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioPlayerState = ref.watch(audioPlayerProvider);
    final chapterState = ref.watch(chapterStateProvider);
    final audiobook = audioPlayerState.currentBook;

    if (audiobook == null) {
      return const SizedBox();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildControlButton(
          icon: Icons.skip_previous,
          onPressed: () {
            final audioPlayer = ref.read(audioPlayerProvider.notifier);
            if (audiobook.isJoinedVolume) {
              if (chapterState.chapterIndex > 0) {
                audioPlayer.skipToPrevious();
              }
            } else {
              if (chapterState.chapterIndex > 0) {
                final previousChapter =
                    audiobook.chapters[chapterState.chapterIndex - 1];
                audioPlayer.seek(
                    previousChapter.start + const Duration(milliseconds: 1));
              }
            }
          },
        ),
        _buildControlButton(
          icon: Icons.replay_30,
          onPressed: () =>
              ref.read(audioPlayerProvider.notifier).skipBackward(),
        ),
        _buildPlayButton(context),
        _buildControlButton(
          icon: Icons.forward_30,
          onPressed: () => ref.read(audioPlayerProvider.notifier).skipForward(),
        ),
        _buildControlButton(
          icon: Icons.skip_next,
          onPressed: () {
            final audioPlayer = ref.read(audioPlayerProvider.notifier);
            if (audiobook.isJoinedVolume) {
              if (chapterState.chapterIndex < audiobook.chapters.length - 1) {
                audioPlayer.skipToNext();
              }
            } else {
              if (chapterState.chapterIndex < audiobook.chapters.length - 1) {
                final nextChapter =
                    audiobook.chapters[chapterState.chapterIndex + 1];
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
      iconSize: 36, // Slightly larger buttons
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
            iconSize: 56, // Larger play button for better interaction
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
