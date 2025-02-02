import 'dart:typed_data';

import 'package:audiobook_manager/utils/duration_formatter.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/log_redirection_strategy.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'dart:convert';

import '../models/audiobook.dart';

class MetadataService {
  static void _initFFmpeg() {
    FFmpegKitConfig.enableLogCallback(null);
    FFmpegKitConfig.enableStatisticsCallback(null);
    FFmpegKitConfig.enableFFmpegSessionCompleteCallback(null);
    FFmpegKitConfig.setLogRedirectionStrategy(
        LogRedirectionStrategy.neverPrintLogs);
  }

  static Future<Map<String, dynamic>> extractMetadata(String filePath) async {
    _initFFmpeg();
    Map<String, dynamic> metadata = {
      'cover_photo': null,
      'chapters': [],
      'duration': null,
      'title': null,
      'author': null,
    };

    try {
      // Extract cover art
      metadata['cover_photo'] = await _extractCoverArt(filePath);
      // Get metadata using FFprobe
      final probeResult = await FFprobeKit.execute(
          '-v quiet -print_format json -show_chapters -show_format -show_streams "$filePath"');

      if (ReturnCode.isSuccess(await probeResult.getReturnCode())) {
        final jsonOutput = await probeResult.getOutput();
        if (jsonOutput != null) {
          try {
            final Map<String, dynamic> probeData = json.decode(jsonOutput);

            // Extract chapters
            if (probeData.containsKey('chapters')) {
              List<Chapter> formattedChapters = [];
              var rawChapters = probeData['chapters'];

              for (var chapter in rawChapters) {
                try {
                  String title = chapter['tags']?['title'] ??
                      'Chapter ${formattedChapters.length + 1}';
                  Duration start = Duration(
                      microseconds:
                          (double.parse(chapter['start_time']) * 1000000)
                              .round());
                  Duration end = Duration(
                      microseconds:
                          (double.parse(chapter['end_time']) * 1000000)
                              .round());

                  formattedChapters.add(Chapter(
                    title: title,
                    start: start,
                    duration: end - start,
                    end: end,
                  ));
                } catch (e) {
                  print('Error parsing chapter: $e');
                }
              }

              // If no chapters were found or parsed, create a single chapter for the entire book
              if (formattedChapters.isEmpty &&
                  probeData['format']?['duration'] != null) {
                double totalDuration =
                    double.parse(probeData['format']['duration']);
                formattedChapters.add(Chapter(
                  title: 'Full Book',
                  start: Duration.zero,
                  duration:
                      Duration(microseconds: (totalDuration * 1000000).round()),
                  end:
                      Duration(microseconds: (totalDuration * 1000000).round()),
                ));
              }

              metadata['chapters'] = formattedChapters;
            }

            // Extract format metadata
            if (probeData.containsKey('format')) {
              var format = probeData['format'];

              // Extract duration
              if (format.containsKey('duration')) {
                double durationSeconds = double.parse(format['duration']);
                metadata['duration'] = {
                  'seconds': durationSeconds,
                  'formatted': DurationFormatter.format(
                      Duration(seconds: durationSeconds.round())),
                };
              }

              // Extract tags from format metadata
              if (format.containsKey('tags')) {
                var tags = format['tags'];
                metadata['title'] = tags['title'] ??
                    tags['TITLE'] ??
                    _getFileNameWithoutExtension(filePath);

                metadata['author'] = tags['artist'] ??
                    tags['ARTIST'] ??
                    tags['author'] ??
                    tags['AUTHOR'] ??
                    tags['album_artist'] ??
                    tags['ALBUM_ARTIST'] ??
                    "Unknown Author";
              }
            }

            // If title/author not found in format tags, check stream metadata
            if (probeData.containsKey('streams') &&
                (metadata['title'] == null || metadata['author'] == null)) {
              for (var stream in probeData['streams']) {
                if (stream.containsKey('tags')) {
                  var tags = stream['tags'];

                  // Only set if not already set from format metadata
                  metadata['title'] ??= tags['title'] ?? tags['TITLE'];

                  metadata['author'] ??= tags['artist'] ??
                      tags['ARTIST'] ??
                      tags['author'] ??
                      tags['AUTHOR'] ??
                      tags['album_artist'] ??
                      tags['ALBUM_ARTIST'];
                }
              }
            }

            // Final fallback for title if nothing found in metadata
            metadata['title'] ??= _getFileNameWithoutExtension(filePath);
            metadata['author'] ??= "Unknown Author";
          } catch (e) {
            print('Error parsing JSON metadata: $e');
          }
        }
      }

      return metadata;
    } catch (e) {
      print('Error extracting metadata: $e');
      return metadata;
    }
  }

  static Future<Uint8List?> _extractCoverArt(String filePath) async {
    final String coverOutputPath =
        '${Directory.systemTemp.path}/${Uuid().v4()}cover.jpg';

    // List of FFmpeg commands to try
    final coverCommands = [
      // Method 1: Extract album art stream
      '-v quiet -i "$filePath" -an -vcodec copy "$coverOutputPath"',
      // Method 2: Extract embedded art
      '-v quiet -i "$filePath" -map 0:v -map -0:V -c copy "$coverOutputPath"',
      // Method 3: Extract first attached picture
      '-v quiet -i "$filePath" -map 0:v:0 -frames:v 1 "$coverOutputPath"',
      // Method 4: Extract embedded art (alternative)
      '-v quiet -i "$filePath" -an -vf scale=600:-1 "$coverOutputPath"',
      // Method 5: Extract metadata picture
      '-v quiet -i "$filePath" -map 0:v? -map -0:V? -c copy "$coverOutputPath"',
    ];

    // Try each method until we successfully extract the cover
    for (final command in coverCommands) {
      try {
        final coverResult = await FFmpegKit.execute(command);
        final coverFile = File(coverOutputPath);

        if (ReturnCode.isSuccess(await coverResult.getReturnCode()) &&
            await coverFile.exists()) {
          final bytes = await coverFile.readAsBytes();
          await coverFile.delete();
          return bytes;
        }

        // Clean up if the file exists but extraction failed
        if (await coverFile.exists()) {
          await coverFile.delete();
        }
      } catch (e) {
        print("Error trying cover extraction method: $e");
        continue;
      }
    }

    // Try extracting cover from metadata directly as a last resort
    try {
      final probeResult = await FFprobeKit.execute(
          '-v quiet -print_format json -show_streams -select_streams v "$filePath"');

      if (ReturnCode.isSuccess(await probeResult.getReturnCode())) {
        final jsonOutput = await probeResult.getOutput();
        if (jsonOutput != null) {
          final Map<String, dynamic> probeData = json.decode(jsonOutput);
          if (probeData.containsKey('streams') &&
              probeData['streams'] is List &&
              probeData['streams'].isNotEmpty) {
            // If we found a video stream, try one more time with specific parameters
            final lastCommand =
                '-i "$filePath" -map 0:${probeData['streams'][0]['index']} -frames:v 1 "$coverOutputPath"';
            final lastResult = await FFmpegKit.execute(lastCommand);
            final coverFile = File(coverOutputPath);

            if (ReturnCode.isSuccess(await lastResult.getReturnCode()) &&
                await coverFile.exists()) {
              final bytes = await coverFile.readAsBytes();
              await coverFile.delete();
              return bytes;
            }
            if (await coverFile.exists()) {
              await coverFile.delete();
            }
          }
        }
      }
    } catch (e) {
      print("Error in final cover extraction attempt: $e");
    }

    return null;
  }

  static String _getFileNameWithoutExtension(String filePath) {
    String fileName = filePath.split('/').last;
    return fileName.substring(0, fileName.lastIndexOf('.'));
  }
}
