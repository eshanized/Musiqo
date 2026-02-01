// ============================================================================
// Volume Slider Widget
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';

/// Volume control slider.
class VolumeSlider extends StatelessWidget {
  final double volume;
  final ValueChanged<double>? onChanged;
  final VoidCallback? onMute;

  const VolumeSlider({
    super.key,
    required this.volume,
    this.onChanged,
    this.onMute,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onMute,
          icon: Icon(
            volume == 0
                ? Icons.volume_off_rounded
                : volume < 0.5
                ? Icons.volume_down_rounded
                : Icons.volume_up_rounded,
            color: EverblushColors.textSecondary,
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: SliderComponentShape.noOverlay,
            ),
            child: Slider(
              value: volume,
              onChanged: onChanged,
              activeColor: EverblushColors.primary,
              inactiveColor: EverblushColors.outline,
            ),
          ),
        ),
      ],
    );
  }
}
