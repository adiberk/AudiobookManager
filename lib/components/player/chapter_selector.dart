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
    final scrollController = ScrollController(
      initialScrollOffset: audiobook.chapters.indexOf(currentChapter) *
          72.0, // Adjusted for new height
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentIndex = audiobook.chapters.indexOf(currentChapter);
      if (currentIndex != -1) {
        scrollController.animateTo(
          currentIndex * 72.0, // Adjusted for new height
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

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
            controller: scrollController,
            shrinkWrap: true,
            itemCount: audiobook.chapters.length,
            itemExtent: 72.0, // Adjusted height
            itemBuilder: (context, index) {
              final chapter = audiobook.chapters[index];
              final isSelected = chapter == currentChapter;

              return Padding(
                padding: const EdgeInsets.only(
                    bottom: 0), // Add spacing between items
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : null,
                    border: Border(
                      left: BorderSide(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 4,
                      ),
                    ),
                  ),
                  child: ListTile(
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
                      'Duration: ${DurationFormatter.format(audiobook.isFolder && !audiobook.isJoinedVolume ? chapter.duration : chapter.end - chapter.start)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    onTap: () {
                      ref
                          .read(audioPlayerProvider.notifier)
                          .seekToChapter(index);
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
          ),
        ),
        SafeArea(child: Container(height: 8)),
      ],
    );
  }
}
