// ============================================================================
// Progress Slider - Custom styled audio progress bar
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../core/extensions/duration_extensions.dart';

/// A custom audio progress slider with time labels.
class ProgressSlider extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;
  final bool showLabels;

  const ProgressSlider({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Slider
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            activeTrackColor: EverblushColors.primary,
            inactiveTrackColor: EverblushColors.outline,
            thumbColor: EverblushColors.primary,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayColor: EverblushColors.primary.withValues(alpha: 0.2),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          ),
          child: Slider(
            value: progress.clamp(0.0, 1.0),
            onChanged: (value) {
              final newPosition = Duration(
                milliseconds: (value * duration.inMilliseconds).round(),
              );
              onSeek(newPosition);
            },
          ),
        ),

        // Time labels
        if (showLabels)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  position.formatted,
                  style: const TextStyle(
                    fontSize: 12,
                    color: EverblushColors.textMuted,
                  ),
                ),
                Text(
                  duration.formatted,
                  style: const TextStyle(
                    fontSize: 12,
                    color: EverblushColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
