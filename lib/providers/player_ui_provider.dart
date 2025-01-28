import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerUIState {
  final bool isExpanded;

  const PlayerUIState({
    this.isExpanded = false,
  });

  PlayerUIState copyWith({
    bool? isExpanded,
  }) {
    return PlayerUIState(
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

class PlayerUINotifier extends StateNotifier<PlayerUIState> {
  PlayerUINotifier() : super(const PlayerUIState());

  void toggleExpanded() {
    state = state.copyWith(isExpanded: !state.isExpanded);
  }

  void setExpanded(bool isExpanded) {
    state = state.copyWith(isExpanded: isExpanded);
  }
}
