// lib/models/audiobook.dart
import 'dart:typed_data';

class Chapter {
  final String title;
  final Duration start;
  final Duration end;

  Chapter({
    required this.title,
    required this.start,
    required this.end,
  });
}

class AudioBook {
  final String id;
  final String title;
  final String author;
  final String filePath;
  final Duration duration;
  final List<Chapter> chapters;
  final Uint8List? coverPhoto;
  Duration currentPosition;
  int currentChapterIndex;

  AudioBook({
    required this.id,
    required this.title,
    required this.author,
    required this.filePath,
    required this.duration,
    required this.chapters,
    this.coverPhoto,
    this.currentPosition = Duration.zero,
    this.currentChapterIndex = 0,
  });

  // Convert AudioBook to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'filePath': filePath,
      'duration': duration.inMicroseconds,
      'chapters': chapters
          .map((chapter) => {
                'title': chapter.title,
                'start': chapter.start.inMicroseconds,
                'end': chapter.end.inMicroseconds,
              })
          .toList(),
      'coverPhoto': coverPhoto,
      'currentPosition': currentPosition.inMicroseconds,
      'currentChapterIndex': currentChapterIndex,
    };
  }

  // Create AudioBook from Map
  factory AudioBook.fromMap(Map<String, dynamic> map) {
    return AudioBook(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      filePath: map['filePath'],
      duration: Duration(microseconds: map['duration']),
      chapters: (map['chapters'] as List)
          .map((chapter) => Chapter(
                title: chapter['title'],
                start: Duration(microseconds: chapter['start']),
                end: Duration(microseconds: chapter['end']),
              ))
          .toList(),
      coverPhoto: map['coverPhoto'],
      currentPosition: Duration(microseconds: map['currentPosition']),
      currentChapterIndex: map['currentChapterIndex'],
    );
  }
}
