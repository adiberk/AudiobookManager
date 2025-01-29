import 'package:audiobook_manager/components/player/chapter_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/audiobook.dart';
import '../../providers/chapter_state_provider.dart';

class ModernPlayerMetadata extends ConsumerWidget {
  final AudioBook audiobook;

  const ModernPlayerMetadata({super.key, required this.audiobook});

  void _showChapterSelector(
      BuildContext context, WidgetRef ref, ChapterState currentState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ChapterSelector(
        audiobook: audiobook,
        currentChapter: currentState.currentChapter,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapterState = ref.watch(chapterStateProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            audiobook.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            audiobook.author,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (audiobook.chapters.length > 1)
            GestureDetector(
              onTap: () => _showChapterSelector(context, ref, chapterState),
              child: _buildChapterInfo(context, chapterState),
            ),
        ],
      ),
    );
  }

  Widget _buildChapterInfo(
      BuildContext context, ChapterState chapterState, bool isLandscape) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isLandscape ? 4 : 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bookmark,
            size: isLandscape ? 12 : 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              chapterState.currentChapter.title,
              style: TextStyle(
                fontSize: isLandscape ? 12 : 14,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
