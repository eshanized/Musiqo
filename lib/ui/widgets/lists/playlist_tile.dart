// ============================================================================
// Playlist Tile - Compact playlist item
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../data/models/playlist.dart';
import '../images/cached_artwork.dart';

/// Compact playlist tile for lists.
class PlaylistTile extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;

  const PlaylistTile({
    super.key,
    required this.playlist,
    this.onTap,
    this.onLongPress,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedArtwork(url: playlist.thumbnailUrl, size: 48),
      ),
      title: Text(
        playlist.name,
        style: const TextStyle(color: EverblushColors.textPrimary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${playlist.songs.length} songs',
        style: const TextStyle(color: EverblushColors.textMuted, fontSize: 12),
      ),
      trailing: trailing,
    );
  }
}
