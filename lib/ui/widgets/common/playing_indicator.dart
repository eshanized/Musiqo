// ============================================================================
// Playing Indicator - Shows when song is playing
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';
import '../animations/waveform.dart';

/// An indicator showing the currently playing song.
class PlayingIndicator extends StatelessWidget {
  final bool isPlaying;

  const PlayingIndicator({super.key, required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    if (!isPlaying) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: Icon(
          Icons.music_note_rounded,
          size: 16,
          color: EverblushColors.textMuted,
        ),
      );
    }

    return const SizedBox(
      width: 20,
      height: 20,
      child: Waveform(barCount: 3, height: 16),
    );
  }
}
