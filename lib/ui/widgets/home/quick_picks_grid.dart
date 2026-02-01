// ============================================================================
// Quick Picks Grid - Grid of quick picks
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../data/models/song.dart';
import '../images/cached_artwork.dart';

/// Grid of quick pick songs for home screen.
class QuickPicksGrid extends StatelessWidget {
  final List<Song> songs;
  final Function(Song)? onSongTap;

  const QuickPicksGrid({super.key, required this.songs, this.onSongTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Quick Picks',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: EverblushColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 3.5,
            ),
            itemCount: songs.length.clamp(0, 6),
            itemBuilder: (context, index) {
              final song = songs[index];
              return GestureDetector(
                onTap: () => onSongTap?.call(song),
                child: Container(
                  decoration: BoxDecoration(
                    color: EverblushColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(8),
                        ),
                        child: CachedArtwork(url: song.thumbnailUrl, size: 48),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          song.title,
                          style: const TextStyle(
                            fontSize: 12,
                            color: EverblushColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
