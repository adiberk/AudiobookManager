import 'package:audiobook_manager/components/player/chapter_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/audiobook.dart';
import '../../providers/providers.dart';

class ModernPlayerMetadata extends ConsumerWidget {
  final AudioBook audiobook;

  const ModernPlayerMetadata({super.key, required this.audiobook});

  void _showChapterSelector(
      BuildContext context, WidgetRef ref, Chapter currentChapter) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ChapterSelector(
        audiobook: audiobook,
        currentChapter: currentChapter,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(audioPlayerProvider);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isLandscape ? 8.0 : 24.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            audiobook.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  // Smaller text in landscape
                  fontSize: isLandscape ? 18 : null,
                ),
            textAlign: TextAlign.center,
            maxLines: isLandscape ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isLandscape ? 4 : 8),
          Text(
            audiobook.author,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                  // Smaller text in landscape
                  fontSize: isLandscape ? 14 : null,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (audiobook.chapters.length > 1)
            GestureDetector(
              onTap: () => _showChapterSelector(
                  context, ref, playerState.currentChapter),
              child: _buildChapterInfo(
                  context, playerState.currentChapter, isLandscape),
            ),
        ],
      ),
    );
  }

  Widget _buildChapterInfo(
      BuildContext context, Chapter currentChapter, bool isLandscape) {
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
              currentChapter.title,
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
