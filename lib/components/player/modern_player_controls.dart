import 'package:audiobook_manager/models/audiobook.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/chapter_state_provider.dart';
import '../../providers/providers.dart';

class ModernPlayerControls extends ConsumerWidget {
  const ModernPlayerControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioPlayerState = ref.watch(audioPlayerProvider);
    final chapterState = ref.watch(chapterStateProvider);
    final audiobook = audioPlayerState.currentBook;

    if (audiobook == null) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSecondaryButton(
            Icons.skip_previous,
            () => _skipToPrevious(ref, audiobook, chapterState),
          ),
          _buildSecondaryButton(
            Icons.replay_30,
            () => ref.read(audioPlayerProvider.notifier).skipBackward(),
          ),
          _buildPrimaryButton(context, ref),
          _buildSecondaryButton(
            Icons.forward_30,
            () => ref.read(audioPlayerProvider.notifier).skipForward(),
          ),
          _buildSecondaryButton(
            Icons.skip_next,
            () => _skipToNext(ref, audiobook, chapterState),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, size: 28),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(audioPlayerProvider).isPlaying;
    return Container(
      height: 64,
      width: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => ref.read(audioPlayerProvider.notifier).togglePlayPause(),
          child: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            size: 32,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _skipToPrevious(
      WidgetRef ref, AudioBook audiobook, ChapterState chapterState) {
    final audioPlayer = ref.read(audioPlayerProvider.notifier);
    if (audiobook.isJoinedVolume) {
      if (chapterState.chapterIndex > 0) {
        audioPlayer.skipToPrevious();
      }
    } else {
      if (chapterState.chapterIndex > 0) {
        final previousChapter =
            audiobook.chapters[chapterState.chapterIndex - 1];
        audioPlayer
            .seek(previousChapter.start + const Duration(milliseconds: 1));
      }
    }
  }

  void _skipToNext(
      WidgetRef ref, AudioBook audiobook, ChapterState chapterState) {
    final audioPlayer = ref.read(audioPlayerProvider.notifier);
    if (audiobook.isJoinedVolume) {
      if (chapterState.chapterIndex < audiobook.chapters.length - 1) {
        audioPlayer.skipToNext();
      }
    } else {
      if (chapterState.chapterIndex < audiobook.chapters.length - 1) {
        final nextChapter = audiobook.chapters[chapterState.chapterIndex + 1];
        audioPlayer.seek(nextChapter.start + const Duration(milliseconds: 1));
      }
    }
  }
}
