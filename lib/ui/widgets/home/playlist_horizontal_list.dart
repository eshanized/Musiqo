// ============================================================================
// Playlist Horizontal List - Horizontal playlist list
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../data/models/playlist.dart';
import '../images/cached_artwork.dart';

/// Horizontal scrolling list of playlists.
class PlaylistHorizontalList extends StatelessWidget {
  final String title;
  final List<Playlist> playlists;
  final Function(Playlist)? onPlaylistTap;
  final double itemWidth;

  const PlaylistHorizontalList({
    super.key,
    required this.title,
    required this.playlists,
    this.onPlaylistTap,
    this.itemWidth = 130,
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
          height: itemWidth + 45,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: playlists.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return GestureDetector(
                onTap: () => onPlaylistTap?.call(playlist),
                child: SizedBox(
                  width: itemWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedArtwork(
                          url: playlist.thumbnailUrl,
                          size: itemWidth,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        playlist.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: EverblushColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${playlist.songs.length} songs',
                        style: const TextStyle(
                          fontSize: 11,
                          color: EverblushColors.textMuted,
                        ),
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
