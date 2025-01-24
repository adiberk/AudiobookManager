// lib/services/file_service.dart
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:uuid/uuid.dart';

import '../models/audiobook.dart';
import 'metadata_service.dart';

class FileService {
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

  // Pick audio file
  static Future<File?> pickAudioFile() async {
    try {
      String initialDirectory = await _documentsPath;
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _supportedFormats,
        allowMultiple: true,
        initialDirectory: initialDirectory,
      );
      if (result != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      print('Error picking file: $e');
      return null;
    }
  }

  // Process and move file to app directory
  static Future<String?> processAudioFile(File sourceFile) async {
    try {
      final processedDir = await _processedDir;
      final String newFileName =
          '${const Uuid().v4()}${path.extension(sourceFile.path)}';
      final String destinationPath = path.join(processedDir.path, newFileName);

      // Copy file to processed directory
      await sourceFile.copy(destinationPath);
      // delete the current file
      await sourceFile.delete();
      return destinationPath;
    } catch (e) {
      print('Error processing file: $e');
      return null;
    }
  }

  // Delete file
  static Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting file: $e');
    }
  }
}
