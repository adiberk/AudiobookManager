import 'dart:io';
import 'dart:typed_data';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '../models/audiobook.dart';
import '../services/audio_handler.dart';
import '../services/import_service.dart';
import 'audiobook_provider.dart';

class AudioPlayerState {
  final Duration duration;
  final bool isPlaying;
  final PlayerState? playerState;
  final AudioBook? currentBook;
  final AudioPlayer? player;
  final ConcatenatingAudioSource? playlist;
  final Chapter currentChapter;
  final Duration chapterPosition;
  final Duration chapterDuration;
  final int chapterIndex;
  final bool isLoading;

  AudioPlayerState({
    this.duration = Duration.zero,
    this.isPlaying = false,
    this.playerState,
    this.currentBook,
    this.player,
    this.playlist,
    this.currentChapter = const Chapter(
      title: '',
      start: Duration.zero,
      end: Duration.zero,
      duration: Duration.zero,
    ),
    this.chapterPosition = Duration.zero,
    this.chapterDuration = Duration.zero,
    this.chapterIndex = 0,
    this.isLoading = false,
  });

  AudioPlayerState copyWith({
    Duration? duration,
    PlayerState? playerState,
    bool? isPlaying,
    AudioBook? currentBook,
    AudioPlayer? player,
    ConcatenatingAudioSource? playlist,
    bool? isLoading,
    Chapter? currentChapter,
    Duration? chapterPosition,
    Duration? chapterDuration,
    int? chapterIndex,
  }) {
    return AudioPlayerState(
      duration: duration ?? this.duration,
      playerState: playerState ?? this.playerState,
      isPlaying: isPlaying ?? this.isPlaying,
      currentBook: currentBook ?? this.currentBook,
      player: player ?? this.player,
      playlist: playlist ?? this.playlist,
      isLoading: isLoading ?? this.isLoading,
      currentChapter: currentChapter ?? this.currentChapter,
      chapterPosition: chapterPosition ?? this.chapterPosition,
      chapterDuration: chapterDuration ?? this.chapterDuration,
      chapterIndex: chapterIndex ?? this.chapterIndex,
    );
  }
}

class AudioPlayerNotifier extends StateNotifier<AudioPlayerState> {
  final Ref ref;
  late AudiobookHandler _audioHandler;
  bool _isInitialized = false;

  AudioPlayerNotifier(this.ref) : super(AudioPlayerState()) {
    _initializeHandler();
  }

  Future<void> _initializeHandler() async {
    if (_isInitialized) return;

    _audioHandler = await AudioService.init(
      builder: () => AudiobookHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.yourdomain.audiobook',
        androidNotificationChannelName: 'Audiobook Player',
        androidNotificationOngoing: true,
      ),
    );

    state = state.copyWith(player: _audioHandler.player);
    _initializeListeners();
    _isInitialized = true;
  }

  void _initializeListeners() {
    _audioHandler.player.positionStream.listen((position) {
      if (!state.isLoading && state.currentBook != null) {
        final book = state.currentBook!;
        final chapterIndex = _audioHandler.player.currentIndex ?? 0;
        final currentChapter = book.chapters[chapterIndex];

        final chapterPosition =
            position; // Position is always absolute for the current file

        // Calculate the correct duration based on the book type
        final Duration chapterDuration;
        if (book.isFolder) {
          // For folder-based files, use the chapter's duration directly
          chapterDuration = currentChapter.duration;
        } else if (book.isJoinedVolume) {
          // For joined volumes, use the difference between end and start
          chapterDuration = currentChapter.end - currentChapter.start;
        } else {
          // For single files (including those from folder contents),
          // use the player's duration
          chapterDuration = _audioHandler.player.duration ?? Duration.zero;
        }
        final updatedBook = book.copyWith(
          currentPosition: position,
          currentChapterIndex: chapterIndex,
        );

        ref.read(audiobooksProvider.notifier).updateAudiobook(updatedBook);

        state = state.copyWith(
          currentBook: updatedBook,
          currentChapter: currentChapter,
          chapterPosition: chapterPosition,
          chapterDuration: chapterDuration,
          chapterIndex: chapterIndex,
        );
      }
    });

    _audioHandler.player.playerStateStream.listen((playerState) {
      if (!state.isLoading) {
        state = state.copyWith(
          playerState: playerState,
          isPlaying: playerState.playing,
        );
      }
    });

    _audioHandler.player.durationStream.listen((duration) {
      if (!state.isLoading) {
        state = state.copyWith(duration: duration ?? Duration.zero);
      }
    });
  }

  Future<void> setAudiobook(AudioBook book) async {
    if (state.isLoading) return;

    try {
      state = state.copyWith(isLoading: true);
      await _audioHandler.setAudiobook(book);
      state = state.copyWith(
        currentBook: book,
        isPlaying: false,
      );
    } catch (e) {
      print('Error setting audiobook: $e');
      state = state.copyWith(
        currentBook: null,
        isPlaying: false,
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> play() async => await _audioHandler.play();
  Future<void> pause() async => await _audioHandler.pause();
  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seek(Duration position) async =>
      await _audioHandler.seek(position);
  Future<void> skipForward() async => await _audioHandler.seekForward(true);
  Future<void> skipBackward() async => await _audioHandler.seekBackward(true);
  Future<void> skipToNext() async => await _audioHandler.skipToNext();
  Future<void> skipToPrevious() async => await _audioHandler.skipToPrevious();

  Future<void> seekToChapter(int chapterIndex) async {
    await _audioHandler.skipToChapter(chapterIndex);
  }

  Future<void> clearCurrentBook() async {
    try {
      await _audioHandler.pause();
      state = AudioPlayerState();
    } catch (e) {
      print('Error clearing current book: $e');
    }
  }

  @override
  void dispose() {
    if (state.currentBook != null) {
      // Save final position before disposing
      final book = state.currentBook!.copyWith(
        currentPosition: state.chapterPosition,
        currentChapterIndex: state.chapterIndex,
      );
      ref.read(audiobooksProvider.notifier).updateAudiobook(book);
    }
    _audioHandler.closeHandler();
    super.dispose();
  }
}
