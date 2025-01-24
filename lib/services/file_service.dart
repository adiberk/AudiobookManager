// lib/services/file_service.dart
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:uuid/uuid.dart';

class FileService {
  static const _processedFolderName = 'processed';

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
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
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
      return destinationPath;
    } catch (e) {
      print('Error processing file: $e');
      return null;
    }
  }
}
