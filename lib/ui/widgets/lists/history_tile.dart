// ============================================================================
// History Tile - Recently played item
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../data/models/song.dart';
import '../images/cached_artwork.dart';

/// History tile with time played.
class HistoryTile extends StatelessWidget {
  final Song song;
  final DateTime playedAt;
  final VoidCallback? onTap;

  const HistoryTile({
    super.key,
    required this.song,
    required this.playedAt,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedArtwork(url: song.thumbnailUrl, size: 48),
      ),
      title: Text(
        song.title,
        style: const TextStyle(color: EverblushColors.textPrimary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artistName,
        style: const TextStyle(color: EverblushColors.textMuted, fontSize: 12),
      ),
      trailing: Text(
        _formatTime(),
        style: const TextStyle(color: EverblushColors.textMuted, fontSize: 11),
      ),
    );
  }

  String _formatTime() {
    final diff = DateTime.now().difference(playedAt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    if (diff.inDays == 1) {
      return 'Yesterday';
    }
    return '${diff.inDays}d ago';
  }
}
