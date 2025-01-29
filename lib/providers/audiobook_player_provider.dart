import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../models/audiobook.dart';
import '../services/import_service.dart';
import 'audiobook_provider.dart';

class AudioPlayerState {
  final Duration duration;
  final bool isPlaying;
  final PlayerState? playerState;
  final AudioBook? currentBook;
  final AudioPlayer? player;
  final ConcatenatingAudioSource? playlist;

  AudioPlayerState({
    this.duration = Duration.zero,
    this.isPlaying = false,
    this.playerState,
    this.currentBook,
    this.player,
    this.playlist,
  });

  AudioPlayerState copyWith({
    Duration? duration,
    PlayerState? playerState,
    bool? isPlaying,
    AudioBook? currentBook,
    AudioPlayer? player,
    ConcatenatingAudioSource? playlist,
  }) {
    return AudioPlayerState(
      duration: duration ?? this.duration,
      playerState: playerState ?? this.playerState,
      isPlaying: isPlaying ?? this.isPlaying,
      currentBook: currentBook ?? this.currentBook,
      player: player ?? this.player,
      playlist: playlist ?? this.playlist,
    );
  }
}

class AudioPlayerNotifier extends StateNotifier<AudioPlayerState> {
  final Ref ref; // Add ref to access providers

  AudioPlayerNotifier(this.ref) : super(AudioPlayerState()) {
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final player = AudioPlayer();
    state = state.copyWith(player: player);
    _initializeListeners();
  }

  void _initializeListeners() {
    final player = state.player;
    if (player == null) return;

    // Update position listener to save progress
    player.positionStream.listen((position) {
      // Save progress if we have a current book
      if (state.currentBook != null) {
        final updatedBook = state.currentBook!.copyWith(
          currentPosition: position,
          currentChapterIndex: state.player!.currentIndex,
        );

        // Update the book in storage
        ref.read(audiobooksProvider.notifier).updateAudiobook(updatedBook);

        // Update current book in player state
        state = state.copyWith(currentBook: updatedBook);
      }
    });

    player.playerStateStream.listen((playerState) {
      state = state.copyWith(
        playerState: playerState,
        isPlaying: playerState.playing,
      );
    });

    player.durationStream.listen((duration) {
      state = state.copyWith(duration: duration ?? Duration.zero);
    });

    player.currentIndexStream.listen((index) {
      if (index != null && state.currentBook != null) {
        state = state.copyWith(
          currentBook: state.currentBook!.copyWith(currentChapterIndex: index),
        );
      }
    });
  }

  Future<void> setAudiobook(AudioBook book) async {
    try {
      if (state.player == null) {
        await _initializePlayer();
      }

      if (state.currentBook?.id != book.id) {
        final wasPlaying = state.isPlaying;
        if (wasPlaying) await state.player?.stop();

        state = state.copyWith(
          currentBook: book,
          isPlaying: false,
          playerState: PlayerState(false, ProcessingState.idle),
        );

        final fullPath = await ImportService.resolveFullPath(book.path);

        if (book.isFolder && book.isJoinedVolume) {
          final playlist = ConcatenatingAudioSource(
            children: await Future.wait(
              book.chapters.map((chapter) async {
                final fullChapterPath =
                    await ImportService.resolveFullPath(chapter.filePath!);
                return AudioSource.file(fullChapterPath);
              }),
            ),
          );

          state = state.copyWith(playlist: playlist);
          await state.player?.setAudioSource(playlist);

          if (book.currentChapterIndex > 0) {
            await state.player
                ?.seek(Duration.zero, index: book.currentChapterIndex);
          }
        } else {
          state = state.copyWith(playlist: null);
          await state.player?.setFilePath(fullPath);
        }

        if (book.currentPosition > Duration.zero) {
          await state.player?.seek(book.currentPosition);
        }

        if (wasPlaying) {
          await state.player?.play();
        }
      }
    } catch (e) {
      print('Error setting audiobook: $e');
    }
  }

  // Return player position
  Duration get position => state.player?.position ?? Duration.zero;
  // return current book
  AudioBook? get currentBook => state.currentBook;
  // Player control methods
  Future<void> play() async => await state.player?.play();
  Future<void> pause() async => await state.player?.pause();
  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seek(Duration position) async =>
      await state.player?.seek(position);

  Future<void> skipForward() async {
    if (state.player != null) {
      final newPosition = state.player!.position + const Duration(seconds: 30);
      await seek(newPosition);
    }
  }

  Future<void> skipBackward() async {
    if (state.player != null) {
      final newPosition = state.player!.position - const Duration(seconds: 30);
      await seek(newPosition);
    }
  }

  Future<void> skipToNext() async {
    if (state.playlist != null && (state.player?.hasNext ?? false)) {
      await state.player?.seekToNext();
    }
  }

  Future<void> skipToPrevious() async {
    if (state.playlist != null && (state.player?.hasPrevious ?? false)) {
      await state.player?.seekToPrevious();
    }
  }

  Future<void> seekToChapter(int chapterIndex) async {
    if ((state.currentBook?.isFolder ?? false) &&
        state.currentBook?.isJoinedVolume == true) {
      if (chapterIndex >= 0 &&
          chapterIndex < (state.currentBook?.chapters.length ?? 0)) {
        await state.player?.seek(Duration.zero, index: chapterIndex);
      }
    }
  }

  Future<void> clearCurrentBook() async {
    try {
      if (state.isPlaying) {
        await state.player?.stop();
      }
      state = AudioPlayerState();
    } catch (e) {
      print('Error clearing current book: $e');
    }
  }

  @override
  void dispose() {
    state.player?.dispose();
    super.dispose();
  }
}
