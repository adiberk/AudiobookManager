import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../../utils/duration_formatter.dart';

class PlayerSeekBar extends ConsumerWidget {
  const PlayerSeekBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioPlayer = ref.watch(audioPlayerProvider.notifier);
    final audioPlayerState = ref.watch(audioPlayerProvider);
    final currentChapterIndex = ref.watch(currentChapterIndexProvider);
    final audiobook = audioPlayerState.currentBook;
    if (audiobook == null) {
      return const SizedBox();
    }
    final currentChapter = audiobook.isJoinedVolume
        ? audiobook.chapters[currentChapterIndex]
        : ref.watch(currentChapterProvider(audioPlayer.position));
    Duration chapterPosition;
    Duration chapterDuration;

    if (audiobook.isJoinedVolume) {
      // For joined volumes, we want the position relative to the current chapter
      chapterPosition = audioPlayer.position;
      chapterDuration = currentChapter.end - currentChapter.start;
    } else {
      // For single files, calculate relative to chapter start
      chapterPosition = audioPlayer.position - currentChapter.start;
      chapterDuration = currentChapter.end - currentChapter.start;
    }

    // Ensure position is within bounds
    chapterPosition = Duration(
        milliseconds: chapterPosition.inMilliseconds
            .clamp(0, chapterDuration.inMilliseconds));

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Slider(
            value: chapterPosition.inSeconds.toDouble(),
            min: 0,
            max: chapterDuration.inSeconds.toDouble(),
            onChanged: (value) {
              if (audiobook.isJoinedVolume) {
                // For joined volumes, seek within the current chapter
                audioPlayer.seek(Duration(seconds: value.toInt()));
              } else {
                audioPlayer.seek(
                  currentChapter.start + Duration(seconds: value.toInt()),
                );
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DurationFormatter.format(chapterPosition)),
                Text(DurationFormatter.format(chapterDuration)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
