import 'dart:io';
import 'dart:typed_data';
import 'package:audiobook_manager/utils/duration_formatter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/audiobook.dart';
import 'metadata_service.dart';

class ImportService {
  static final List<String> _supportedFormats = [
    'mp3',
    'm4a',
    'm4b',
    'aac',
    'wav'
  ];
  static const _processedFolderName = 'processed';

  static Future<String> get _documentsPath async {
    if (Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
    // For Android or other platforms, you might want to handle differently
    return '/';
  }

// Get the processed directory path
  static Future<Directory> get _processedDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final processedDir =
        Directory(path.join(appDir.path, _processedFolderName));
    if (!await processedDir.exists()) {
      await processedDir.create();
    }
    return processedDir;
  }

  Future<List<AudioBook>> importFiles() async {
    String initialDirectory = await _documentsPath;
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: _supportedFormats,
          allowMultiple: true,
          initialDirectory: initialDirectory);

      if (result != null) {
        List<AudioBook> importedBooks = [];

        for (var file in result.files) {
          File? processedFile = file.path != null
              ? await processAudioFile(File(file.path!))
              : null;
          if (processedFile != null) {
            final metadata = await MetadataService.extractMetadata(
                await resolveFullPath(file.path!));

            final audiobook = AudioBook(
              title: metadata['title'] ?? path.basename(file.path!),
              author: metadata['author'] ?? 'Unknown Author',
              duration: metadata['duration']?['formatted'] ?? '00:00:00',
              path: processedFile.path!,
              coverImage: metadata['cover_photo'],
              chapters: (metadata['chapters'] as List<Chapter>?) ?? [],
            );

            importedBooks.add(audiobook);
          }
        }

        return importedBooks;
      }
    } catch (e) {
      print('Error importing files: $e');
    }

    return [];
  }

  Future<AudioBook?> importFolder() async {
    String initialDirectory = await _documentsPath;
    try {
      String? folderPath = await FilePicker.platform
          .getDirectoryPath(initialDirectory: initialDirectory);
      String? newFolderPath = folderPath != null
          ? await processFolder(Directory(folderPath))
          : null;
      if (newFolderPath != null) {
        final directory = Directory(newFolderPath);
        List<Chapter> folderChapters = [];
        Uint8List? firstCoverImage;
        String? firstAuthor;
        Duration totalDuration = Duration.zero;

        // Get all audio files in the folder
        List<FileSystemEntity> files = directory
            .listSync()
            .where((entity) =>
                entity is File &&
                _supportedFormats.contains(
                    path.extension(entity.path).toLowerCase().substring(1)))
            .toList();

        // Sort files by name to maintain order
        files.sort((a, b) => a.path.compareTo(b.path));

        for (var entity in files) {
          if (entity is File) {
            final metadata = await MetadataService.extractMetadata(entity.path);

            // Store first found cover image
            if (firstCoverImage == null && metadata['cover_photo'] != null) {
              firstCoverImage = metadata['cover_photo'];
            }
            if (firstAuthor == null && metadata['author'] != null) {
              firstAuthor = metadata['author'];
            }

            // Calculate duration
            Duration fileDuration = Duration(
                seconds: (metadata['duration']?['seconds'] ?? 0.0).round());

            // Create chapter from file
            Chapter chapter = Chapter(
              title: metadata['title'] ?? path.basename(entity.path),
              start: totalDuration,
              end: totalDuration + fileDuration,
              filePath: entity.path,
            );

            folderChapters.add(chapter);
            totalDuration += fileDuration;
          }
        }

        if (folderChapters.isNotEmpty) {
          return AudioBook(
            title: path.basename(newFolderPath),
            author: firstAuthor ?? 'Unknown Author',
            duration: DurationFormatter.format(totalDuration),
            path: newFolderPath,
            coverImage: firstCoverImage,
            chapters: folderChapters,
            isFolder: true,
            isJoinedVolume: false,
          );
        }
      }
    } catch (e) {
      print('Error importing folder: $e');
    }

    return null;
  }

  static Future<File?> processAudioFile(File sourceFile) async {
    try {
      final processedDir = await _processedDir;
      final String newFileName =
          '${const Uuid().v4()}${path.extension(sourceFile.path)}';
      final String destinationPath = path.join(processedDir.path, newFileName);

      // Copy file to processed directory
      await sourceFile.copy(destinationPath);

      // Store the relative path from the documents directory
      final relativePath = path.join(_processedFolderName, newFileName);

      return File(relativePath);
    } catch (e) {
      print('Error processing file: $e');
      return null;
    }
  }

  //   static Future<File?> processAudioFile(File sourceFile) async {
  //   try {
  //     final processedDir = await _processedDir;
  //     final String newFileName =
  //         '${const Uuid().v4()}${path.extension(sourceFile.path)}';
  //     final String destinationPath = path.join(processedDir.path, newFileName);

  //     // Copy file to processed directory
  //     final newFile = await sourceFile.copy(destinationPath);

  //     // delete the current file
  //     await sourceFile.delete();
  //     return newFile;
  //   } catch (e) {
  //     print('Error processing file: $e');
  //     return null;
  //   }
  // }

  static Future<String?> processFolder(Directory sourceFolder) async {
    try {
      final processedDir = await _processedDir;
      final String newFolderName = const Uuid().v4();
      final String destinationFolderPath =
          path.join(processedDir.path, newFolderName);

      // Create the new folder in the processed directory
      final destinationFolder = Directory(destinationFolderPath);
      if (!await destinationFolder.exists()) {
        await destinationFolder.create();
      }

      // Copy each file in the source folder to the new folder
      await for (var entity in sourceFolder.list(recursive: false)) {
        if (entity is File) {
          final String newFileName =
              '${const Uuid().v4()}${path.extension(entity.path)}';
          final String destinationFilePath =
              path.join(destinationFolder.path, newFileName);
          await entity.copy(destinationFilePath);
          await entity.delete();
        }
      }

      return destinationFolderPath;
    } catch (e) {
      print('Error processing folder: $e');
      return null;
    }
  }

  static Future<void> deleteFile(String relativePath) async {
    try {
      final fullPath = await resolveFullPath(relativePath);
      final file = File(fullPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  static Future<void> deleteFolder(String relativePath) async {
    try {
      final fullPath = await resolveFullPath(relativePath);
      final folder = Directory(fullPath);
      if (await folder.exists()) {
        await folder.delete(recursive: true);
      }
    } catch (e) {
      print('Error deleting folder: $e');
    }
  }

  Future<AudioBook> convertToJoinedVolume(AudioBook folderBook) async {
    if (!folderBook.isFolder) return folderBook;

    return folderBook.copyWith(
      isJoinedVolume: true,
    );
  }

  static Future<String> resolveFullPath(String relativePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    return path.join(appDir.path, relativePath);
  }
}
