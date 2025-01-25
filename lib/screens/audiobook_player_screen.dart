import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/player_provider.dart';

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
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    // Drag handle/close button
                    GestureDetector(
                      onTap: () =>
                          ref.read(playerProvider.notifier).toggleExpanded(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    // empty sizebox
                    const SizedBox(height: 20),

                    // Audiobook cover
                    Padding(
                      padding: const EdgeInsets.all(65.0),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: audiobook.coverPhoto != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  audiobook.coverPhoto!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.music_note,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                    ),

                    // Title and author
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          Text(
                            audiobook.title,
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            audiobook.author,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),

                    // Seek bar
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Slider(
                            value: 0,
                            onChanged: (value) {
                              // TODO: Implement seeking
                            },
                            min: 0,
                            max: 100,
                            thumbColor: Theme.of(context).colorScheme.secondary,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('0:00'),
                                Text('30:00'), // TODO: Get actual duration
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Playback controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.skip_previous),
                          iconSize: 32,
                          onPressed: () {
                            // TODO: Previous chapter
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.replay_10),
                          iconSize: 32,
                          onPressed: () {
                            // TODO: Rewind 10 seconds
                          },
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.play_arrow),
                            iconSize: 48,
                            color: Colors.white,
                            onPressed: () {
                              // TODO: Play/pause
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.forward_10),
                          iconSize: 32,
                          onPressed: () {
                            // TODO: Forward 10 seconds
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next),
                          iconSize: 32,
                          onPressed: () {
                            // TODO: Next chapter
                          },
                        ),
                      ],
                    ),

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
