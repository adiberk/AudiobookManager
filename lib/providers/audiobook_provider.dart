// lib/providers/audiobook_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/audiobook.dart';
import '../services/storage_service.dart';

class AudioBooksNotifier extends StateNotifier<List<AudioBook>> {
  AudioBooksNotifier() : super([]) {
    // Load saved audiobooks when the provider is created
    _loadSavedAudioBooks();
  }

  Future<void> _loadSavedAudioBooks() async {
    final savedBooks = await StorageService.loadAudioBooks();
    state = savedBooks;
  }

  Future<void> addAudioBook(AudioBook audioBook) async {
    state = [...state, audioBook];
    await _saveAudioBooks();
  }

  Future<void> updateAudioBook(AudioBook audioBook) async {
    state = [
      for (final book in state)
        if (book.id == audioBook.id) audioBook else book
    ];
    await _saveAudioBooks();
  }

  Future<void> removeAudioBook(String id) async {
    state = state.where((book) => book.id != id).toList();
    await _saveAudioBooks();
  }

  Future<void> _saveAudioBooks() async {
    await StorageService.saveAudioBooks(state);
  }
}

final audioBooksProvider =
    StateNotifierProvider<AudioBooksNotifier, List<AudioBook>>(
        (ref) => AudioBooksNotifier());
