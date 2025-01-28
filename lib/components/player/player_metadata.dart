import 'package:flutter/material.dart';
import '../../models/audiobook.dart';

class PlayerMetadata extends StatelessWidget {
  final AudioBook audiobook;

  const PlayerMetadata({super.key, required this.audiobook});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          audiobook.title,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          audiobook.author,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
