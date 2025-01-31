import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/import_service.dart';
import 'audiobook_player_provider.dart';
import 'player_ui_provider.dart';

// Service providers
final importServiceProvider = Provider<ImportService>((ref) {
  return ImportService();
});

// UI State providers
final sortOptionProvider = StateProvider<String>((ref) => 'title');

final playerUIProvider =
    StateNotifierProvider<PlayerUINotifier, PlayerUIState>((ref) {
  return PlayerUINotifier();
});

// Player providers
final audioPlayerProvider =
    StateNotifierProvider<AudioPlayerNotifier, AudioPlayerState>((ref) {
  return AudioPlayerNotifier(ref);
});
