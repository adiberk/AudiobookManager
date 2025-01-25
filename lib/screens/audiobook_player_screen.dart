import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/player_provider.dart';
import '../components/player/player_cover_art.dart';
import '../components/player/player_controls.dart';
import '../components/player/player_seek_bar.dart';
import '../components/player/player_metadata.dart';
import '../components/player/drag_handle.dart';

class AudiobookPlayerScreen extends ConsumerWidget {
  const AudiobookPlayerScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider);
    final audiobook = playerState.currentBook;

    // Only show if there's a book and the player is expanded
    if (audiobook == null || !playerState.isExpanded) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        transform:
            Matrix4.translationValues(0, MediaQuery.of(context).size.height, 0),
      );
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      transform: Matrix4.translationValues(0, 0, 0),
      child: DraggableScrollableSheet(
        initialChildSize: 1.0,
        minChildSize: 0.0,
        maxChildSize: 1.0,
        builder: (context, scrollController) {
          return NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              if (notification.extent <= 0.15) {
                ref.read(playerProvider.notifier).toggleExpanded();
              }
              return true;
            },
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    DragHandle(
                        onTap: () =>
                            ref.read(playerProvider.notifier).toggleExpanded()),
                    const SizedBox(height: 20),
                    PlayerCoverArt(audiobook: audiobook),
                    PlayerMetadata(audiobook: audiobook),
                    const PlayerSeekBar(),
                    const PlayerControls(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
