import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/audiobook.dart';
import '../services/import_service.dart';
import 'audiobook_player_provider.dart';
import 'player_ui_provider.dart';

// Service providers
final importServiceProvider = Provider<ImportService>((ref) {
  return ImportService();
});

// UI State providers
final sortOptionProvider = StateProvider<String>((ref) => 'title');

final playerUIProvider =
    StateNotifierProvider<PlayerUINotifier, PlayerUIState>((ref) {
  return PlayerUINotifier();
});

// Player providers
final audioPlayerProvider =
    StateNotifierProvider<AudioPlayerNotifier, AudioPlayerState>((ref) {
  return AudioPlayerNotifier(ref);
});

// Derived state providers
final currentChapterProvider =
    Provider.family<Chapter, Duration>((ref, position) {
  final playerState = ref.watch(audioPlayerProvider);
  final currentBook = playerState.currentBook;

  // Early return if no book
  if (currentBook == null) {
    return Chapter(title: '', start: Duration.zero, end: Duration.zero);
  }

  // For joined volumes, use the chapter index
  if (currentBook.isJoinedVolume) {
    return currentBook.chapters[currentBook.currentChapterIndex];
  }

  // Cache the chapters list
  final chapters = currentBook.chapters;

  // Binary search for current chapter
  int low = 0;
  int high = chapters.length - 1;

  while (low <= high) {
    int mid = (low + high) ~/ 2;
    final chapter = chapters[mid];

    if (position >= chapter.start && position <= chapter.end) {
      return chapter;
    }

    if (position < chapter.start) {
      high = mid - 1;
    } else {
      low = mid + 1;
    }
  }

  return chapters.last;
});

// Simplified chapter index provider
final currentChapterIndexProvider = Provider<int>((ref) {
  final playerState = ref.watch(audioPlayerProvider);
  final book = playerState.currentBook;
  if (book == null) return 0;

  if (book.isJoinedVolume) {
    return book.currentChapterIndex;
  }

  final position = ref.watch(audioPlayerProvider.notifier).position;
  final chapter = ref.watch(currentChapterProvider(position));
  return book.chapters.indexOf(chapter);
});

// Position provider
final currentPositionProvider = StreamProvider<Duration>((ref) {
  final player = ref.watch(audioPlayerProvider).player;
  if (player == null) return Stream.value(Duration.zero);
  return player.positionStream;
});
