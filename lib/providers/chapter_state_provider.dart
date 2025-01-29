import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/audiobook.dart';
import 'providers.dart';

class ChapterState {
  final Chapter currentChapter;
  final Duration chapterPosition;
  final Duration chapterDuration;
  final int chapterIndex;
  final bool isLoading;

  ChapterState({
    required this.currentChapter,
    required this.chapterPosition,
    required this.chapterDuration,
    required this.chapterIndex,
    this.isLoading = false,
  });
}

final chapterStateProvider = Provider<ChapterState>((ref) {
  final playerState = ref.watch(audioPlayerProvider);
  final audiobook = playerState.currentBook;
  final position = ref.watch(audioPlayerProvider.notifier).position;

  if (audiobook == null) {
    return ChapterState(
      currentChapter:
          Chapter(title: '', start: Duration.zero, end: Duration.zero),
      chapterPosition: Duration.zero,
      chapterDuration: Duration.zero,
      chapterIndex: 0,
    );
  }

  Chapter currentChapter;
  Duration chapterPosition;
  Duration chapterDuration;
  int chapterIndex;

  if (audiobook.isJoinedVolume) {
    chapterIndex = audiobook.currentChapterIndex;
    currentChapter = audiobook.chapters[chapterIndex];
    chapterPosition = position;
    chapterDuration = currentChapter.end - currentChapter.start;
  } else {
    currentChapter = ref.watch(currentChapterProvider(position));
    chapterIndex = audiobook.chapters.indexOf(currentChapter);
    chapterPosition = position - currentChapter.start;
    chapterDuration = currentChapter.end - currentChapter.start;
  }

  // Ensure position is within bounds
  chapterPosition = Duration(
    milliseconds: chapterPosition.inMilliseconds.clamp(
      0,
      chapterDuration.inMilliseconds,
    ),
  );

  return ChapterState(
    currentChapter: currentChapter,
    chapterPosition: chapterPosition,
    chapterDuration: chapterDuration,
    chapterIndex: chapterIndex,
    isLoading: playerState.isLoading,
  );
});
