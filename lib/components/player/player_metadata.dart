import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/audiobook.dart';
import '../../providers/chapter_state_provider.dart';

class PlayerMetadata extends ConsumerWidget {
  final AudioBook audiobook;

  const PlayerMetadata({super.key, required this.audiobook});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapterState = ref.watch(chapterStateProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            audiobook.title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            audiobook.author,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Text(
            chapterState.currentChapter.title,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}
