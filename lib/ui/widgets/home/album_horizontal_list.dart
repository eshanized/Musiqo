// ============================================================================
// Album Horizontal List - Horizontal album list
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../data/models/song.dart';
import '../images/cached_artwork.dart';

/// Horizontal scrolling list of albums.
class AlbumHorizontalList extends StatelessWidget {
  final String title;
  final List<Album> albums;
  final Function(Album)? onAlbumTap;
  final double itemWidth;

  const AlbumHorizontalList({
    super.key,
    required this.title,
    required this.albums,
    this.onAlbumTap,
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
          height: itemWidth + 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: albums.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final album = albums[index];
              return GestureDetector(
                onTap: () => onAlbumTap?.call(album),
                child: SizedBox(
                  width: itemWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedArtwork(
                          url: album.thumbnailUrl,
                          size: itemWidth,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        album.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: EverblushColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'Album',
                        style: TextStyle(
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
