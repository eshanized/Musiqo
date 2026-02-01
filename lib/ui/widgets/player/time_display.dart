// ============================================================================
// Time Display - Current/total time
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../core/extensions/duration_extensions.dart';

/// Time display showing position and duration.
class TimeDisplay extends StatelessWidget {
  final Duration position;
  final Duration duration;

  const TimeDisplay({
    super.key,
    required this.position,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          position.formatted,
          style: const TextStyle(
            fontSize: 12,
            fontFeatures: [FontFeature.tabularFigures()],
            color: EverblushColors.textMuted,
          ),
        ),
        Text(
          duration.formatted,
          style: const TextStyle(
            fontSize: 12,
            fontFeatures: [FontFeature.tabularFigures()],
            color: EverblushColors.textMuted,
          ),
        ),
      ],
    );
  }
}
