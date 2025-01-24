import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/audiobook.dart';

class StorageService {
  static const String _audioBooksBoxName = 'audiobooks';
  static const String _versionKey = 'storage_version';
  static const int _currentVersion = 1;

  // Initialize Hive and open boxes
  static Future<void> init() async {
    await Hive.initFlutter();
    final box = await Hive.openBox<String>(_audioBooksBoxName);
    // Check version and migrate if needed
    // final version = box.get(_versionKey, defaultValue: '0');
    // if (version != _currentVersion.toString()) {
    //   await _migrate(int.parse(version), _currentVersion);
    //   await box.put(_versionKey, _currentVersion.toString());
    // }
  }

  // static Future<void> _migrate(int fromVersion, int toVersion) async {
  //   // Handle migrations here when you update your data structure
  //   print('Migrating from version $fromVersion to $toVersion');
  // }

  // Save audiobooks
  static Future<void> saveAudioBooks(List<AudioBook> audiobooks) async {
    final box = Hive.box<String>(_audioBooksBoxName);

    // Convert audiobooks to JSON strings and store
    final audiobooksJson = audiobooks.map((book) => book.toMap()).toList();
    await box.put('all_audiobooks', json.encode(audiobooksJson));
  }

  // Load audiobooks
  static Future<List<AudioBook>> loadAudioBooks() async {
    final box = Hive.box<String>(_audioBooksBoxName);

    try {
      final String? storedData = box.get('all_audiobooks');
      if (storedData == null) return [];

      // Parse the stored JSON string back to List<Map>
      final List<dynamic> audiobooksJson = json.decode(storedData);

      // Convert each Map back to AudioBook
      return audiobooksJson
          .map((json) => AudioBook.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading audiobooks: $e');
      return [];
    }
  }
}
