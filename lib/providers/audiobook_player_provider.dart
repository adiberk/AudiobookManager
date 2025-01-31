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
  final Chapter currentChapter;
  final Duration chapterPosition;
  final Duration chapterDuration;
  final int chapterIndex;
  final bool isLoading; // New field to track loading state

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

    player.positionStream.listen((position) {
      if (!state.isLoading && state.currentBook != null) {
        final book = state.currentBook!;
        final chapterIndex = state.player!.currentIndex ?? 0;
        final currentChapter = book.chapters[chapterIndex];

        // For folder-based chapters, use position directly
        // For single-file chapters or joined volumes, position is already relative to clip
        final chapterPosition =
            book.isFolder && !book.isJoinedVolume ? position : position;

        final chapterDuration = book.isFolder && !book.isJoinedVolume
            ? currentChapter.duration
            : currentChapter.end - currentChapter.start;

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

    player.playerStateStream.listen((playerState) {
      if (!state.isLoading) {
        state = state.copyWith(
          playerState: playerState,
          isPlaying: playerState.playing,
        );
      }
    });

    player.durationStream.listen((duration) {
      if (!state.isLoading) {
        state = state.copyWith(duration: duration ?? Duration.zero);
      }
    });

    player.currentIndexStream.listen((index) {
      if (!state.isLoading && index != null && state.currentBook != null) {
        state = state.copyWith(
          currentBook: state.currentBook!.copyWith(currentChapterIndex: index),
        );
      }
    });
  }

  Future<void> setAudiobook(AudioBook book) async {
    if (state.isLoading) return; // Prevent concurrent loading

    try {
      state = state.copyWith(isLoading: true);

      if (state.player == null) {
        await _initializePlayer();
      }

      // Stop current playback before switching
      if (state.isPlaying) {
        await state.player?.stop();
      }

      // Clear current state
      state = state.copyWith(
        currentBook: null,
        isPlaying: false,
        playerState: PlayerState(false, ProcessingState.idle),
        playlist: null,
      );

      final fullPath = await ImportService.resolveFullPath(book.path);
      final playlist = ConcatenatingAudioSource(
          children: book.isFolder
              ? await _createFolderChapterSources(book)
              : await _createSingleFileChapterSources(book, fullPath));
      await state.player?.setAudioSource(playlist);
      state = state.copyWith(
        playlist: playlist,
        currentBook: book,
      );
      if (book.currentChapterIndex > 0) {
        await state.player
            ?.seek(Duration.zero, index: book.currentChapterIndex);
      }
    } catch (e) {
      print('Error setting audiobook: $e');
      // Reset state on error
      state = state.copyWith(
        currentBook: null,
        isPlaying: false,
        playerState: PlayerState(false, ProcessingState.idle),
        playlist: null,
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<List<AudioSource>> _createFolderChapterSources(AudioBook book) async {
    return Future.wait(
      book.chapters.map((chapter) async {
        final fullChapterPath =
            await ImportService.resolveFullPath(chapter.filePath!);
        return AudioSource.file(fullChapterPath);
      }),
    );
  }

  Future<List<AudioSource>> _createSingleFileChapterSources(
      AudioBook book, String fullPath) async {
    return book.chapters.map((chapter) {
      return ClippingAudioSource(
        child: AudioSource.file(fullPath),
        start: chapter.start,
        end: chapter.end,
      );
    }).toList();
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
  // Future<void> seek(Duration position) async =>
  //     await state.player?.seek(position);

  Future<void> seek(Duration position) async {
    if (state.player != null && state.currentBook != null) {
      final book = state.currentBook!;
      if (book.isFolder && !book.isJoinedVolume) {
        // For folder-based chapters, seek directly
        await state.player?.seek(position);
      } else {
        // For single-file chapters or joined volumes, use relative position
        await state.player?.seek(position, index: state.player?.currentIndex);
      }
    }
  }

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
    if (chapterIndex >= 0 &&
        chapterIndex < (state.currentBook?.chapters.length ?? 0)) {
      await state.player?.seek(Duration.zero, index: chapterIndex);
    }
  }

  Future<void> clearCurrentBook() async {
    try {
      if (state.isPlaying) {
        await state.player?.stop();
      }
      state.player?.dispose();
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
