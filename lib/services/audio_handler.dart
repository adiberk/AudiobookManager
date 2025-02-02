import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '../models/audiobook.dart';
import '../services/import_service.dart';

class AudiobookHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer();
  AudioBook? _currentBook;

  AudiobookHandler() {
    _listenToPlaybackState();
    _listenToCurrentPosition();
    _listenToSequenceState();
  }

  Future<String?> _getArtUriFromCoverImage(Uint8List? coverImage) async {
    if (coverImage == null) return null;

    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/current_audiobook_cover.jpg');
      await file.writeAsBytes(coverImage);
      return file.uri.toString();
    } catch (e) {
      print('Error creating cover image file: $e');
      return null;
    }
  }

  void _listenToPlaybackState() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.rewind,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.fastForward,
          MediaControl.skipToNext,
        ],
        systemActions: {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.fastForward, // Add this
          MediaAction.rewind, // Add this
        },
        androidCompactActionIndices: const [1, 2, 3],
        processingState: {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex ?? 0,
      ));
    });
  }

  void _listenToCurrentPosition() {
    _player.positionStream.listen((position) async {
      if (_currentBook != null) {
        final chapterIndex = _player.currentIndex ?? 0;
        final currentChapter = _currentBook!.chapters[chapterIndex];
        final Duration chapterDuration;
        if (_currentBook!.isFolder) {
          // For folder-based files, use the chapter's duration directly
          chapterDuration = currentChapter.duration;
        } else if (_currentBook!.isJoinedVolume) {
          // For joined volumes, use the difference between end and start
          chapterDuration = currentChapter.end - currentChapter.start;
        } else {
          // For single files (including those from folder contents),
          // use the player's duration
          chapterDuration = _player.duration ?? Duration.zero;
        }
        String? artUri =
            await _getArtUriFromCoverImage(_currentBook?.coverImage);
        mediaItem.add(MediaItem(
          id: currentChapter.filePath ?? _currentBook!.path,
          displaySubtitle: currentChapter.title,
          displayTitle: _currentBook!.title,
          artist: _currentBook!.author,
          album: _currentBook!.title,
          title: currentChapter.title,
          duration: chapterDuration,
          artUri: artUri != null ? Uri.parse(artUri) : null,
        ));
      }
    });
  }

  void _listenToSequenceState() {
    _player.sequenceStateStream.listen((SequenceState? sequenceState) {
      if (sequenceState == null) return;
      final sequence = sequenceState.effectiveSequence;
      if (sequence.isEmpty) return;
    });
  }

  Future<void> setAudiobook(AudioBook book) async {
    _currentBook = book;
    final fullPath = await ImportService.resolveFullPath(book.path);
    final playlist = ConcatenatingAudioSource(
      children: book.isFolder
          ? await _createFolderChapterSources(book)
          : await _createSingleFileChapterSources(book, fullPath),
    );
    await _player.setAudioSource(playlist);
    await _player.load();

    // First seek to the correct chapter
    if (book.currentChapterIndex > 0) {
      await _player.seek(
          book.currentPosition > Duration.zero
              ? book.currentPosition
              : Duration.zero,
          index: book.currentChapterIndex);
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

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) async {
    if (_currentBook != null) {
      if (_currentBook!.isFolder && !_currentBook!.isJoinedVolume) {
        await _player.seek(position);
      } else {
        await _player.seek(position, index: _player.currentIndex);
      }
    }
  }

  @override
  Future<void> fastForward() async {
    // Standard 10-second skip for iOS
    final newPosition = _player.position + const Duration(seconds: 10);
    await seek(newPosition);
  }

  @override
  Future<void> rewind() async {
    // Standard 10-second rewind for iOS
    final newPosition = _player.position - const Duration(seconds: 10);
    await seek(newPosition);
  }

  @override
  Future<void> seekForward(bool begin) async {
    if (begin) {
      final newPosition = _player.position + const Duration(seconds: 30);
      await seek(newPosition);
    }
  }

  @override
  Future<void> seekBackward(bool begin) async {
    if (begin) {
      final newPosition = _player.position - const Duration(seconds: 30);
      await seek(newPosition);
    }
  }

  Future<void> skipToChapter(int chapterIndex) async {
    if (_currentBook != null &&
        chapterIndex >= 0 &&
        chapterIndex < _currentBook!.chapters.length) {
      await _player.seek(Duration.zero, index: chapterIndex);
    }
  }

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  AudioPlayer get player => _player;

  Future<void> closeHandler() async {
    await _player.dispose();
  }
}
