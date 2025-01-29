import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/audiobook.dart';
import '../services/import_service.dart';
import 'audiobook_player_provider.dart';
import 'player_ui_provider.dart';

final importServiceProvider = Provider<ImportService>((ref) {
  return ImportService();
});

final selectedNavigationIndexProvider = StateProvider<int>((ref) => 0);

final sortOptionProvider = StateProvider<String>((ref) => 'title');

// Current AudioBook provider
final playerUIProvider =
    StateNotifierProvider<PlayerUINotifier, PlayerUIState>((ref) {
  return PlayerUINotifier();
});

// Audio player provider
final audioPlayerProvider =
    StateNotifierProvider<AudioPlayerNotifier, AudioPlayerState>((ref) {
  return AudioPlayerNotifier(ref);
});

// Current chapter provider
final currentChapterProvider =
    Provider.family<Chapter, Duration>((ref, position) {
  final playerState = ref.watch(audioPlayerProvider);
  final currentBook = playerState.currentBook;
  if (currentBook == null) {
    throw Exception('No AudioBook is currently playing');
  }

  if (currentBook.isJoinedVolume) {
    return currentBook.chapters[currentBook.currentChapterIndex];
  }

  for (final chapter in currentBook.chapters) {
    if (position >= chapter.start && position <= chapter.end) {
      return chapter;
    }
  }
  return currentBook.chapters.last;
});

// Current chapter index provider
final currentChapterIndexProvider = StateProvider<int>((ref) {
  final playerState = ref.watch(audioPlayerProvider);
  return playerState.currentBook?.currentChapterIndex ?? 0;
});

final currentBookPositionProvider = Provider<Duration>((ref) {
  final playerState = ref.watch(audioPlayerProvider);
  return playerState.currentBook?.currentPosition ?? Duration.zero;
});
