// ============================================================================
// Song Tile Placeholder - Reusable song list tile
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../data/models/song.dart';
import '../images/cached_artwork.dart';

/// A reusable song tile widget for lists.
class SongTilePlaceholder extends StatelessWidget {
  final Song song;
  final VoidCallback? onTap;
  final Widget? trailing;

  const SongTilePlaceholder({
    super.key,
    required this.song,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedArtwork(
          url: song.thumbnailUrl,
          size: 48,
        ),
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: EverblushColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        song.artistName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: EverblushColors.textMuted,
          fontSize: 13,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
