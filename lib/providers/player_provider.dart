import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/audiobook.dart';

class PlayerState {
  final AudioBook? currentBook;
  final bool isPlaying;
  final bool isExpanded; // Track if player screen is expanded
  final Duration currentPosition;

  PlayerState({
    this.currentBook,
    this.isPlaying = false,
    this.isExpanded = false,
    this.currentPosition = Duration.zero,
  });

  PlayerState copyWith({
    AudioBook? currentBook,
    bool? isPlaying,
    bool? isExpanded,
    Duration? currentPosition,
  }) {
    return PlayerState(
      currentBook: currentBook ?? this.currentBook,
      isPlaying: isPlaying ?? this.isPlaying,
      isExpanded: isExpanded ?? this.isExpanded,
      currentPosition: currentPosition ?? this.currentPosition,
    );
  }
}

class PlayerNotifier extends StateNotifier<PlayerState> {
  PlayerNotifier() : super(PlayerState());

  void playBook(AudioBook book) {
    state = state.copyWith(
      currentBook: book,
      isPlaying: true,
      isExpanded: true,
    );
  }

  void clearCurrentBook() {
    state = PlayerState(); // This resets everything to initial state
  }

  void setExpanded(bool expanded) {
    state = state.copyWith(isExpanded: expanded);
  }

  void togglePlay() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  void toggleExpanded() {
    state = state.copyWith(isExpanded: !state.isExpanded);
  }

  void updatePosition(Duration position) {
    state = state.copyWith(currentPosition: position);
  }

  @override
  void dispose() {
    // Cleanup audio resources
    super.dispose();
  }
}

final playerProvider = StateNotifierProvider<PlayerNotifier, PlayerState>(
  (ref) => PlayerNotifier(),
);
