// ============================================================================
// Song Tile - List item for songs
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../core/extensions/duration_extensions.dart';
import '../../../data/models/song.dart';
import '../images/cached_artwork.dart';

/// A list tile for displaying a song.
/// Used in playlists, albums, search results, etc.
class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;
  final bool isPlaying;
  final bool showThumbnail;
  final int? index;

  const SongTile({
    super.key,
    required this.song,
    this.onTap,
    this.onMoreTap,
    this.isPlaying = false,
    this.showThumbnail = true,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

      // Index or thumbnail
      leading: _buildLeading(),

      // Song info
      title: Text(
        song.title,
        style: TextStyle(
          color: isPlaying
              ? EverblushColors.primary
              : EverblushColors.textPrimary,
          fontWeight: isPlaying ? FontWeight.w600 : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),

      subtitle: Row(
        children: [
          // Explicit badge
          if (song.isExplicit) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: EverblushColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
              child: const Text(
                'E',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: EverblushColors.textMuted,
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],

          // Artist and duration
          Expanded(
            child: Text(
              '${song.artistName} • ${song.duration.formatted}',
              style: const TextStyle(
                fontSize: 12,
                color: EverblushColors.textMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),

      // More button
      trailing: IconButton(
        onPressed: onMoreTap,
        icon: const Icon(Icons.more_vert, color: EverblushColors.textMuted),
      ),
    );
  }

  Widget _buildLeading() {
    if (index != null && !showThumbnail) {
      // Show number instead of thumbnail
      return SizedBox(
        width: 40,
        child: Center(
          child: Text(
            '${index! + 1}',
            style: TextStyle(
              color: isPlaying
                  ? EverblushColors.primary
                  : EverblushColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    // Show thumbnail
    return CachedArtwork(url: song.thumbnailUrl, size: 48, borderRadius: 8);
  }
}
