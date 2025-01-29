import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/hive_storage_service.dart';

final storageServiceProvider = Provider<HiveStorageService>((ref) {
  return HiveStorageService();
});
