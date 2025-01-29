import 'package:audiobook_manager/utils/duration_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/audiobook.dart';
import '../../providers/providers.dart';

class ChapterSelector extends ConsumerWidget {
  final AudioBook audiobook;
  final Chapter currentChapter;

  const ChapterSelector({
    super.key,
    required this.audiobook,
    required this.currentChapter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Chapters',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: audiobook.chapters.length,
            itemBuilder: (context, index) {
              final chapter = audiobook.chapters[index];
              final isSelected = chapter == currentChapter;

              return ListTile(
                leading: Icon(
                  isSelected ? Icons.play_arrow : Icons.article,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
                title: Text(
                  chapter.title,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
                subtitle: Text(
                  'Duration: ${DurationFormatter.format(chapter.start - chapter.end)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                onTap: () {
                  if (audiobook.isJoinedVolume) {
                    ref.read(audioPlayerProvider.notifier).seekToChapter(index);
                  } else {
                    ref.read(audioPlayerProvider.notifier).seek(
                          chapter.start + const Duration(milliseconds: 1),
                        );
                  }
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        SafeArea(child: Container(height: 8)), // Bottom padding
      ],
    );
  }
}
