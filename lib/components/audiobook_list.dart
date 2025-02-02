import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/audiobook.dart';
import 'audiobook_list.item.dart';

class AudiobookList extends ConsumerWidget {
  final List<AudioBook> audiobooks;
  final void Function(AudioBook)? onTap;
  final Widget Function(AudioBook)? leadingBuilder;

  const AudiobookList({
    super.key,
    required this.audiobooks,
    this.onTap,
    this.leadingBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (audiobooks.isEmpty) {
      return const Center(child: Text('No audiobooks yet. Add some!'));
    }
    int itemCount = audiobooks.length;
    if (itemCount > 5) {
      itemCount += 1; // Add an extra item for spacing
    }

    return ListView.builder(
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      cacheExtent: 100,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == audiobooks.length) {
          // Return an empty container for the extra space
          return const SizedBox(height: 50);
        }
        var audiobook = audiobooks[index];
        return KeyedSubtree(
          key: ValueKey(audiobook.id),
          child: AudiobookListItem(
            audiobook: audiobook,
            onTap: onTap,
            leadingBuilder: leadingBuilder,
          ),
        );
      },
    );

    //   return ListView.builder(
    //     // Add these properties for better performance
    //     addAutomaticKeepAlives: false,
    //     addRepaintBoundaries: true,
    //     // itemExtent: 88.0, // Fixed height for better performance
    //     cacheExtent: 100, // Increase cache for smoother scrolling
    //     itemCount: audiobooks.length,
    //     itemBuilder: (context, index) {
    //       var audiobook = audiobooks[index];
    //       return KeyedSubtree(
    //         key: ValueKey(audiobook.id),
    //         child: AudiobookListItem(
    //           audiobook: audiobook,
    //           onTap: onTap,
    //           leadingBuilder: leadingBuilder,
    //         ),
    //       );
    //     },
    //   );
    // }
  }
}
