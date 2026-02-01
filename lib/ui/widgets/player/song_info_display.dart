// ============================================================================
// Song Info Display - Song title and artist
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../data/models/song.dart';

/// Displays song title and artist with marquee effect.
class SongInfoDisplay extends StatelessWidget {
  final Song song;
  final bool isLarge;

  const SongInfoDisplay({super.key, required this.song, this.isLarge = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          song.title,
          style: TextStyle(
            fontSize: isLarge ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: EverblushColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: isLarge ? 4 : 2),
        Text(
          song.artistName,
          style: TextStyle(
            fontSize: isLarge ? 14 : 12,
            color: EverblushColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
