// audio_player_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/player/drag_handle.dart';
import '../components/player/modern_player_controls.dart';
import '../components/player/modern_player_cover_art.dart';
import '../components/player/modern_player_metdata.dart';
import '../components/player/modern_player_seek_bar.dart';
import '../models/audiobook.dart';
import '../providers/providers.dart';

class AudiobookPlayerScreen extends ConsumerWidget {
  const AudiobookPlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(audioPlayerProvider);
    final uiState = ref.watch(playerUIProvider);
    final audiobook = playerState.currentBook;

    if (audiobook == null || !uiState.isExpanded) {
      return const SizedBox();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isPortrait = constraints.maxWidth < constraints.maxHeight;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          transform: Matrix4.translationValues(
            0,
            uiState.isExpanded ? 0 : MediaQuery.of(context).size.height,
            0,
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 1.0,
            minChildSize: 0.0,
            maxChildSize: 1.0,
            builder: (context, scrollController) {
              return NotificationListener<DraggableScrollableNotification>(
                onNotification: (notification) {
                  if (notification.extent <= 0.50) {
                    ref.read(playerUIProvider.notifier).toggleExpanded();
                  }
                  return true;
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: [
                      DragHandle(
                        onTap: () => ref
                            .read(playerUIProvider.notifier)
                            .toggleExpanded(),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          physics: const BouncingScrollPhysics(),
                          child: isPortrait
                              ? _buildPortraitLayout(audiobook)
                              : _buildLandscapeLayout(audiobook),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPortraitLayout(AudioBook audiobook) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          ModernPlayerCoverArt(audiobook: audiobook),
          const SizedBox(height: 24),
          ModernPlayerMetadata(audiobook: audiobook),
          const SizedBox(height: 24),
          const ModernPlayerSeekBar(),
          const SizedBox(height: 24),
          const ModernPlayerControls(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(AudioBook audiobook) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Cover Art - make it smaller in landscape
          Expanded(
            flex: 35, // Reduce from 4 to 35%
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AspectRatio(
                aspectRatio: 1,
                child: ModernPlayerCoverArt(audiobook: audiobook),
              ),
            ),
          ),
          // Controls and metadata
          Expanded(
            flex: 65, // Increase from 6 to 65%
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ModernPlayerMetadata(audiobook: audiobook),
                  const SizedBox(height: 8), // Reduce spacing
                  const ModernPlayerSeekBar(),
                  const SizedBox(height: 8), // Reduce spacing
                  const ModernPlayerControls(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
