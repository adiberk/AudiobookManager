import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/player_provider.dart';

class PlayerControls extends ConsumerWidget {
  const PlayerControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildControlButton(
          icon: Icons.skip_previous,
          onPressed: () {/* TODO: Previous chapter */},
        ),
        _buildControlButton(
          icon: Icons.replay_10,
          onPressed: () {/* TODO: Rewind 10 seconds */},
        ),
        _buildPlayButton(context),
        _buildControlButton(
          icon: Icons.forward_10,
          onPressed: () {/* TODO: Forward 10 seconds */},
        ),
        _buildControlButton(
          icon: Icons.skip_next,
          onPressed: () {/* TODO: Next chapter */},
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon),
      iconSize: 32,
      onPressed: onPressed,
    );
  }

  Widget _buildPlayButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.secondary,
      ),
      child: IconButton(
        icon: const Icon(Icons.play_arrow),
        iconSize: 48,
        color: Colors.white,
        onPressed: () {/* TODO: Play/pause */},
      ),
    );
  }
}
