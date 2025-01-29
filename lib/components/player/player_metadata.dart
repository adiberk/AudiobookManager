import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/audiobook.dart';
import '../../providers/providers.dart';

class PlayerMetadata extends ConsumerWidget {
  final AudioBook audiobook;

  const PlayerMetadata({super.key, required this.audiobook});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentChapterIndex = ref.watch(currentChapterIndexProvider);
    final audioPlayerState = ref.watch(audioPlayerProvider.notifier);

    final currentChapter = audiobook.isJoinedVolume
        ? audiobook.chapters[currentChapterIndex]
        : ref.watch(currentChapterProvider(audioPlayerState.position));

    return Column(
      children: [
        Text(
          audiobook.title,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          audiobook.author,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Text(
          'Chapter: ${currentChapter.title}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
