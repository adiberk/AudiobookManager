import 'package:flutter/material.dart';
import '../../models/audiobook.dart';

class PlayerCoverArt extends StatelessWidget {
  final AudioBook audiobook;

  const PlayerCoverArt({super.key, required this.audiobook});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(50),
      child: AspectRatio(
        aspectRatio: 1,
        child: audiobook.coverImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  audiobook.coverImage!,
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
    );
  }
}
