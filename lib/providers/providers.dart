import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/audiobook.dart';
import '../services/hive_storage_service.dart';
import '../services/import_service.dart';
import 'audiobook_player_provider.dart';
import 'player_ui_provider.dart';

// Services providers
final storageServiceProvider = Provider<HiveStorageService>((ref) {
  return HiveStorageService();
});

final importServiceProvider = Provider<ImportService>((ref) {
  return ImportService();
});

final selectedNavigationIndexProvider = StateProvider<int>((ref) => 0);

// AudioBooks state provider
final audiobooksProvider =
    StateNotifierProvider<AudioBooksNotifier, List<AudioBook>>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return AudioBooksNotifier(storageService);
});

// Current AudioBook provider
final playerUIProvider =
    StateNotifierProvider<PlayerUINotifier, PlayerUIState>((ref) {
  return PlayerUINotifier();
});

// Audio player provider
final audioPlayerProvider =
    StateNotifierProvider<AudioPlayerNotifier, AudioPlayerState>((ref) {
  return AudioPlayerNotifier();
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

// AudioBooks notifier
class AudioBooksNotifier extends StateNotifier<List<AudioBook>> {
  final HiveStorageService _storageService;

  AudioBooksNotifier(this._storageService) : super([]) {
    loadAudiobooks();
  }

  Future<void> loadAudiobooks() async {
    final AudioBooks = await _storageService.loadAudiobooks();
    state = AudioBooks;
  }

  Future<void> addAudiobook(AudioBook AudioBook) async {
    await _storageService.addAudiobook(AudioBook);
    state = [...state, AudioBook];
  }

  Future<void> updateAudiobook(AudioBook AudioBook) async {
    await _storageService.updateAudiobook(AudioBook);
    state = [
      for (final book in state)
        if (book.id == AudioBook.id) AudioBook else book
    ];
  }

  Future<void> deleteAudiobooks(Set<String> ids) async {
    for (final id in ids) {
      await _storageService.deleteAudiobook(id);
    }
    state = state.where((book) => !ids.contains(book.id)).toList();
  }
}
