import 'package:flutter/material.dart';

import '../../models/audiobook.dart';

class ModernPlayerCoverArt extends StatelessWidget {
  final AudioBook audiobook;

  const ModernPlayerCoverArt({super.key, required this.audiobook});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'cover-${audiobook.id}',
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: audiobook.coverImage != null
                  ? Image.memory(
                      audiobook.coverImage!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.music_note,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
