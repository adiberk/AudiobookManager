import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/chapter_state_provider.dart';
import '../../providers/providers.dart';
import '../../utils/duration_formatter.dart';

class ModernPlayerSeekBar extends ConsumerWidget {
  const ModernPlayerSeekBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioPlayer = ref.watch(audioPlayerProvider.notifier);
    final audioPlayerState = ref.watch(audioPlayerProvider);
    final chapterState = ref.watch(chapterStateProvider);
    final audiobook = audioPlayerState.currentBook;

    if (audiobook == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 6,
                pressedElevation: 8,
              ),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: Theme.of(context).colorScheme.primary,
              inactiveTrackColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
              thumbColor: Theme.of(context).colorScheme.primary,
              overlayColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
            child: Slider(
              value: chapterState.chapterPosition.inMilliseconds.toDouble(),
              max: chapterState.chapterDuration.inMilliseconds.toDouble(),
              onChanged: (value) {
                final newPosition = Duration(milliseconds: value.toInt());
                if (audiobook.isJoinedVolume) {
                  audioPlayer.seek(newPosition);
                } else {
                  final absolutePosition =
                      chapterState.currentChapter.start + newPosition;
                  audioPlayer.seek(absolutePosition);
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeText(
                    DurationFormatter.format(chapterState.chapterPosition)),
                _buildTimeText(
                    DurationFormatter.format(chapterState.chapterDuration)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeText(String time) {
    return Text(
      time,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
