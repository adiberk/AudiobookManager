import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedNavigationProvider =
    StateNotifierProvider<SelectedNavigationNotifier, SelectedNavigationState>(
        (ref) {
  return SelectedNavigationNotifier();
});

class SelectedNavigationState {
  final int index;
  final bool isNavigatingFolderContents;

  SelectedNavigationState({
    required this.index,
    required this.isNavigatingFolderContents,
  });

  SelectedNavigationState copyWith({
    int? index,
    bool? isNavigatingFolderContents,
  }) {
    return SelectedNavigationState(
      index: index ?? this.index,
      isNavigatingFolderContents:
          isNavigatingFolderContents ?? this.isNavigatingFolderContents,
    );
  }
}

class SelectedNavigationNotifier
    extends StateNotifier<SelectedNavigationState> {
  SelectedNavigationNotifier()
      : super(SelectedNavigationState(
            index: 0, isNavigatingFolderContents: false));

  void updateIndex(int newIndex) {
    state = state.copyWith(index: newIndex);
  }

  void setNavigatingFolderContents(bool isNavigating) {
    state = state.copyWith(isNavigatingFolderContents: isNavigating);
  }

  void toggleNavigatingFolderContents() {
    state = state.copyWith(
        isNavigatingFolderContents: !state.isNavigatingFolderContents);
  }
}
