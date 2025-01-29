import 'package:audiobook_manager/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../models/audiobook.dart';
import '../services/import_service.dart';
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

    return ListView.builder(
      itemCount: audiobooks.length,
      itemBuilder: (context, index) {
        var audiobook = audiobooks[index];
        return AudiobookListItem(
          audiobook: audiobook,
          onTap: onTap,
          leadingBuilder: leadingBuilder,
        );
      },
    );
  }
}
