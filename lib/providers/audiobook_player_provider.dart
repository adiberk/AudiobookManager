import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../models/audiobook.dart';
import '../services/import_service.dart';

class AudioPlayerState {
  final Duration position;
  final Duration duration;
  final PlayerState playerState;
  final bool isPlaying;
  final int? currentIndex;
  final AudioBook? currentBook; // Added this field

  AudioPlayerState({
    required this.position,
    required this.duration,
    required this.playerState,
    required this.isPlaying,
    this.currentIndex,
    this.currentBook, // Added this parameter
  });

  AudioPlayerState copyWith({
    Duration? position,
    Duration? duration,
    PlayerState? playerState,
    bool? isPlaying,
    int? currentIndex,
    AudioBook? currentBook, // Added this parameter
  }) {
    return AudioPlayerState(
      position: position ?? this.position,
      duration: duration ?? this.duration,
      playerState: playerState ?? this.playerState,
      isPlaying: isPlaying ?? this.isPlaying,
      currentIndex: currentIndex ?? this.currentIndex,
      currentBook: currentBook ?? this.currentBook, // Added this field
    );
  }
}

class AudioPlayerNotifier extends StateNotifier<AudioPlayerState> {
  AudioPlayer? _player;
  AudioBook? _currentBook;
  ConcatenatingAudioSource? _playlist;

  AudioPlayerNotifier()
      : super(AudioPlayerState(
          position: Duration.zero,
          duration: Duration.zero,
          playerState: PlayerState(false, ProcessingState.idle),
          isPlaying: false,
        )) {
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _player = AudioPlayer();
    _initializeListeners();
  }

  void _initializeListeners() {
    _player?.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });

    _player?.playerStateStream.listen((playerState) {
      state = state.copyWith(
        playerState: playerState,
        isPlaying: playerState.playing,
      );
    });

    _player?.durationStream.listen((duration) {
      state = state.copyWith(duration: duration ?? Duration.zero);
    });

    _player?.currentIndexStream.listen((index) {
      state = state.copyWith(currentIndex: index);
    });
  }

  Future<void> setAudiobook(AudioBook book) async {
    try {
      // Ensure player is initialized
      if (_player == null) {
        await _initializePlayer();
      }

      if (_currentBook?.id != book.id) {
        final wasPlaying = _player?.playing ?? false;
        if (wasPlaying) await _player?.stop();
        state = state.copyWith(currentBook: book);

        // Resolve the full path
        final fullPath = await ImportService.resolveFullPath(book.path);

        if (book.isFolder && book.isJoinedVolume) {
          _playlist = ConcatenatingAudioSource(
            children: await Future.wait(
              book.chapters.map((chapter) async {
                final fullChapterPath =
                    await ImportService.resolveFullPath(chapter.filePath!);
                return AudioSource.file(fullChapterPath);
              }),
            ),
          );
          await _player?.setAudioSource(_playlist!);
          if (book.currentChapterIndex > 0) {
            await _player?.seek(Duration.zero, index: book.currentChapterIndex);
          }
        } else {
          _playlist = null;
          await _player?.setFilePath(fullPath);
        }

        if (book.currentPosition > Duration.zero) {
          await _player?.seek(book.currentPosition);
        }

        if (wasPlaying) {
          await _player?.play();
        }
      }
    } catch (e) {
      print('Error setting audiobook: $e');
    }
  }

  Future<void> play() async => await _player?.play();
  Future<void> pause() async => await _player?.pause();
  Future<void> togglePlayPause() async {
    if (_player?.playing ?? false) {
      await _player?.pause();
    } else {
      await _player?.play();
    }
  }

  Future<void> seek(Duration position) async => await _player?.seek(position);

  Future<void> skipForward() async {
    if (_player != null) {
      final newPosition = _player!.position + const Duration(seconds: 30);
      await _player!.seek(newPosition);
    }
  }

  Future<void> skipBackward() async {
    if (_player != null) {
      final newPosition = _player!.position - const Duration(seconds: 30);
      await _player?.seek(newPosition);
    }
  }

  Future<void> skipToNext() async {
    if (_playlist != null && (_player?.hasNext ?? false)) {
      await _player?.seekToNext();
    }
  }

  Future<void> skipToPrevious() async {
    if (_playlist != null && (_player?.hasPrevious ?? false)) {
      await _player?.seekToPrevious();
    }
  }

  Future<void> seekToChapter(int chapterIndex) async {
    if (_currentBook?.isJoinedVolume == true) {
      if (_playlist != null &&
          chapterIndex >= 0 &&
          chapterIndex < _playlist!.length) {
        await _player?.seek(Duration.zero, index: chapterIndex);
      }
    }
  }

  Future<void> clearCurrentBook() async {
    try {
      if (_player?.playing ?? false) {
        await _player?.stop();
      }
      _currentBook = null;
      _playlist = null;
      state = AudioPlayerState(
        position: Duration.zero,
        duration: Duration.zero,
        playerState: PlayerState(false, ProcessingState.idle),
        isPlaying: false,
      );
    } catch (e) {
      print('Error clearing current book: $e');
    }
  }

  AudioBook? get currentBook => state.currentBook;
  bool get hasNext => _player?.hasNext ?? false;
  bool get hasPrevious => _player?.hasPrevious ?? false;

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }
}
