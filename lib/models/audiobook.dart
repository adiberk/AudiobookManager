// lib/models/audiobook.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';

class Chapter {
  final String title;
  final Duration start;
  final Duration end;
  final String? filePath;

  Chapter({
    required this.title,
    required this.start,
    required this.end,
    this.filePath,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'start': start.inMilliseconds,
        'end': end.inMilliseconds,
        'filePath': filePath,
      };

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
        title: json['title'],
        start: Duration(milliseconds: json['start']),
        end: Duration(milliseconds: json['end']),
        filePath: json['filePath'],
      );
}

class AudioBook {
  static const int currentVersion = 1;
  final String id;
  final String title;
  final String author;
  final String filePath;
  final Duration duration;
  final int version;
  final List<Chapter> chapters;
  final Uint8List? coverPhoto;
  final bool isFolder;
  final bool isJoinedVolume;
  Duration currentPosition;
  int currentChapterIndex;

  AudioBook({
    String? id,
    required this.title,
    required this.author,
    required this.filePath,
    required this.duration,
    this.version = currentVersion,
    this.coverPhoto,
    this.chapters = const [],
    this.isFolder = false, // Default to false
    this.isJoinedVolume = false, // Default to false
    this.currentPosition = Duration.zero,
    this.currentChapterIndex = 0,
  }) : id = id ?? const Uuid().v4();

  // Convert AudioBook to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'filePath': filePath,
      'duration': duration.inMicroseconds,
      'chapters': chapters.map((c) => c.toJson()).toList(),
      'coverPhoto': coverPhoto != null ? base64Encode(coverPhoto!) : null,
      'currentPosition': currentPosition.inMicroseconds,
      'currentChapterIndex': currentChapterIndex,
      'isFolder': isFolder,
      'isJoinedVolume': isJoinedVolume,
      'version': version,
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
        coverPhoto:
            map['coverPhoto'] != null ? base64Decode(map['coverPhoto']) : null,
        chapters:
            (map['chapters'] as List).map((c) => Chapter.fromJson(c)).toList(),
        currentPosition: Duration(microseconds: map['currentPosition']),
        currentChapterIndex: map['currentChapterIndex'],
        isFolder: map['isFolder'] ?? false,
        isJoinedVolume: map['isJoinedVolume'] ?? false,
        version: map['version'] ?? 1);
  }
}
