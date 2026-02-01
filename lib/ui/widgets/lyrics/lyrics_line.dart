// ============================================================================
// Lyrics Line Widget - Single lyric line
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';

/// A single lyric line with active state.
class LyricsLine extends StatelessWidget {
  final String text;
  final bool isActive;
  final bool isPast;
  final VoidCallback? onTap;

  const LyricsLine({
    super.key,
    required this.text,
    this.isActive = false,
    this.isPast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: TextStyle(
          fontSize: isActive ? 24 : 18,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          color: isActive
              ? EverblushColors.primary
              : isPast
              ? EverblushColors.textMuted.withValues(alpha: 0.5)
              : EverblushColors.textSecondary,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(text, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
