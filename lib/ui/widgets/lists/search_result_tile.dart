// ============================================================================
// Search Result Tile - Search result item
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../data/models/search_result.dart';
import '../images/cached_artwork.dart';

/// Tile for displaying search results.
class SearchResultTile extends StatelessWidget {
  final SearchResultItem item;
  final VoidCallback? onTap;

  const SearchResultTile({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(
          item.type == SearchResultType.artist ? 24 : 8,
        ),
        child: CachedArtwork(url: item.thumbnailUrl, size: 48),
      ),
      title: Text(
        item.title,
        style: const TextStyle(color: EverblushColors.textPrimary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        item.subtitle ?? _getTypeLabel(),
        style: const TextStyle(color: EverblushColors.textMuted, fontSize: 12),
      ),
      trailing: _buildTypeIcon(),
    );
  }

  String _getTypeLabel() {
    switch (item.type) {
      case SearchResultType.song:
        return 'Song';
      case SearchResultType.album:
        return 'Album';
      case SearchResultType.artist:
        return 'Artist';
      case SearchResultType.playlist:
        return 'Playlist';
    }
  }

  Widget? _buildTypeIcon() {
    final iconData = switch (item.type) {
      SearchResultType.song => Icons.music_note_rounded,
      SearchResultType.album => Icons.album_rounded,
      SearchResultType.artist => Icons.person_rounded,
      SearchResultType.playlist => Icons.playlist_play_rounded,
    };

    return Icon(
      iconData,
      size: 20,
      color: EverblushColors.textMuted.withValues(alpha: 0.5),
    );
  }
}
