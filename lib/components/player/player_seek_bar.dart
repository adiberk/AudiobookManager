import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/chapter_state_provider.dart';
import '../../utils/duration_formatter.dart';
import '../../providers/providers.dart';

class PlayerSeekBar extends ConsumerWidget {
  const PlayerSeekBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioPlayer = ref.watch(audioPlayerProvider.notifier);
    final audioPlayerState = ref.watch(audioPlayerProvider);
    final chapterState = ref.watch(chapterStateProvider);
    final audiobook = audioPlayerState.currentBook;

    if (audiobook == null) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Slider(
            value: chapterState.chapterPosition.inMilliseconds.toDouble(),
            max: chapterState.chapterDuration.inMilliseconds.toDouble(),
            onChanged: (value) {
              final newPosition = Duration(milliseconds: value.toInt());
              if (audiobook.isJoinedVolume) {
                audioPlayer.seek(newPosition);
              } else {
                // For non-joined volumes, we need to add the chapter start offset
                final absolutePosition =
                    chapterState.currentChapter.start + newPosition;
                audioPlayer.seek(absolutePosition);
              }
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DurationFormatter.format(chapterState.chapterPosition)),
              Text(DurationFormatter.format(chapterState.chapterDuration)),
            ],
          ),
        ],
      ),
    );
  }
}
