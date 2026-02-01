// ============================================================================
// Quick Picks Section - Personalized song recommendations
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../data/models/song.dart';
import '../images/cached_artwork.dart';

/// Quick Picks section - a vertical list of personalized song recommendations.
/// Displays songs in a compact row layout with thumbnail, info, and play button.
class QuickPicksSection extends StatelessWidget {
  final String title;
  final List<Song> songs;
  final Function(Song)? onSongTap;
  final VoidCallback? onSeeAllTap;

  const QuickPicksSection({
    super.key,
    this.title = 'Quick picks',
    required this.songs,
    this.onSongTap,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with "See all" button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: EverblushColors.textPrimary,
                ),
              ),
              if (onSeeAllTap != null)
                TextButton(
                  onPressed: onSeeAllTap,
                  style: TextButton.styleFrom(
                    foregroundColor: EverblushColors.primary,
                  ),
                  child: const Text('See all'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Song list
        ...songs.take(4).map((song) => _QuickPickTile(
          song: song,
          onTap: () => onSongTap?.call(song),
        )),
      ],
    );
  }
}

/// Individual song tile in Quick Picks
class _QuickPickTile extends StatefulWidget {
  final Song song;
  final VoidCallback? onTap;

  const _QuickPickTile({
    required this.song,
    this.onTap,
  });

  @override
  State<_QuickPickTile> createState() => _QuickPickTileState();
}

class _QuickPickTileState extends State<_QuickPickTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _isPressed 
              ? EverblushColors.surface 
              : EverblushColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Thumbnail with subtle shadow
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: widget.song.thumbnailUrl != null
                    ? CachedArtwork(
                        url: widget.song.thumbnailUrl,
                        size: 56,
                        borderRadius: 8,
                      )
                    : Container(
                        width: 56,
                        height: 56,
                        color: EverblushColors.surfaceVariant,
                        child: const Icon(
                          Icons.music_note_rounded,
                          color: EverblushColors.textMuted,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Song info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.song.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: EverblushColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.song.artistName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: EverblushColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Play button
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: EverblushColors.primary.withValues(alpha: 0.15),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: EverblushColors.primary,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
