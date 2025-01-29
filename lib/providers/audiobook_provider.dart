// AudioBooks state provider
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/audiobook.dart';
import '../services/hive_storage_service.dart';
import 'storage_service_provider.dart';

final audiobooksProvider =
    StateNotifierProvider<AudioBooksNotifier, List<AudioBook>>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return AudioBooksNotifier(storageService);
});

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
