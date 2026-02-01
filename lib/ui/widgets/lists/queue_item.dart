// ============================================================================
// Queue Item - Item in playback queue
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../data/models/song.dart';
import '../images/cached_artwork.dart';

/// Queue item with reorder handle.
class QueueItem extends StatelessWidget {
  final Song song;
  final bool isCurrentlyPlaying;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const QueueItem({
    super.key,
    required this.song,
    this.isCurrentlyPlaying = false,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isCurrentlyPlaying
          ? EverblushColors.primary.withValues(alpha: 0.1)
          : Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ReorderableDragStartListener(
              index: 0,
              child: const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.drag_handle_rounded,
                  color: EverblushColors.textMuted,
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CachedArtwork(url: song.thumbnailUrl, size: 40),
            ),
          ],
        ),
        title: Text(
          song.title,
          style: TextStyle(
            color: isCurrentlyPlaying
                ? EverblushColors.primary
                : EverblushColors.textPrimary,
            fontWeight: isCurrentlyPlaying ? FontWeight.w600 : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          song.artistName,
          style: const TextStyle(
            color: EverblushColors.textMuted,
            fontSize: 12,
          ),
          maxLines: 1,
        ),
        trailing: IconButton(
          onPressed: onRemove,
          icon: const Icon(
            Icons.close_rounded,
            color: EverblushColors.textMuted,
            size: 18,
          ),
        ),
      ),
    );
  }
}
