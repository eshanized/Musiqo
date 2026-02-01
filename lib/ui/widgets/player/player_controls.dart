// ============================================================================
// Player Controls Widget
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';
import '../buttons/play_button.dart';

/// Full playback controls row.
class PlayerControls extends StatelessWidget {
  final bool isPlaying;
  final bool isShuffled;
  final int repeatMode; // 0: off, 1: all, 2: one
  final VoidCallback? onPlay;
  final VoidCallback? onPause;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onShuffle;
  final VoidCallback? onRepeat;

  const PlayerControls({
    super.key,
    required this.isPlaying,
    this.isShuffled = false,
    this.repeatMode = 0,
    this.onPlay,
    this.onPause,
    this.onNext,
    this.onPrevious,
    this.onShuffle,
    this.onRepeat,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Shuffle
        IconButton(
          onPressed: onShuffle,
          icon: Icon(
            Icons.shuffle_rounded,
            color: isShuffled
                ? EverblushColors.primary
                : EverblushColors.textMuted,
          ),
        ),

        // Previous
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(
            Icons.skip_previous_rounded,
            color: EverblushColors.textPrimary,
            size: 32,
          ),
        ),

        // Play/Pause
        AnimatedPlayButton(
          isPlaying: isPlaying,
          onPressed: isPlaying ? onPause : onPlay,
          size: 64,
        ),

        // Next
        IconButton(
          onPressed: onNext,
          icon: const Icon(
            Icons.skip_next_rounded,
            color: EverblushColors.textPrimary,
            size: 32,
          ),
        ),

        // Repeat
        IconButton(
          onPressed: onRepeat,
          icon: Icon(
            repeatMode == 2 ? Icons.repeat_one_rounded : Icons.repeat_rounded,
            color: repeatMode > 0
                ? EverblushColors.primary
                : EverblushColors.textMuted,
          ),
        ),
      ],
    );
  }
}
