import 'package:flutter/material.dart';

class PlayerSeekBar extends StatelessWidget {
  const PlayerSeekBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Slider(
            value: 0,
            onChanged: (value) {/* TODO: Implement seeking */},
            min: 0,
            max: 100,
            thumbColor: Theme.of(context).colorScheme.secondary,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('0:00'),
                Text('30:00'), // TODO: Get actual duration
              ],
            ),
          ),
        ],
      ),
    );
  }
}
