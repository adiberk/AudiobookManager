// lib/providers/audiobook_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/audiobook.dart';

class AudioBooksNotifier extends StateNotifier<List<AudioBook>> {
  AudioBooksNotifier() : super([]);

  void addAudioBook(AudioBook audioBook) {
    state = [...state, audioBook];
  }

  void updateAudioBook(AudioBook audioBook) {
    state = [
      for (final book in state)
        if (book.id == audioBook.id) audioBook else book
    ];
  }

  void removeAudioBook(String id) {
    state = state.where((book) => book.id != id).toList();
  }
}

final audioBooksProvider =
    StateNotifierProvider<AudioBooksNotifier, List<AudioBook>>(
        (ref) => AudioBooksNotifier());
