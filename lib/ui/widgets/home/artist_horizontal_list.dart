// ============================================================================
// Artist Horizontal List - Horizontal artist list
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../data/models/song.dart';
import '../images/avatar_circle.dart';

/// Horizontal scrolling list of artists.
class ArtistHorizontalList extends StatelessWidget {
  final String title;
  final List<Artist> artists;
  final Function(Artist)? onArtistTap;
  final double avatarSize;

  const ArtistHorizontalList({
    super.key,
    required this.title,
    required this.artists,
    this.onArtistTap,
    this.avatarSize = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: EverblushColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: avatarSize + 30,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: artists.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final artist = artists[index];
              return GestureDetector(
                onTap: () => onArtistTap?.call(artist),
                child: SizedBox(
                  width: avatarSize,
                  child: Column(
                    children: [
                      AvatarCircle(
                        imageUrl: artist.thumbnailUrl,
                        size: avatarSize,
                        fallbackText: artist.name,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        artist.name,
                        style: const TextStyle(
                          fontSize: 12,
                          color: EverblushColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
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
