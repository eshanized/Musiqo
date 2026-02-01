// ============================================================================
// Song Options Dialog - Bottom sheet with song actions
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../data/models/song.dart';
import '../images/cached_artwork.dart';

/// Bottom sheet with song actions (add to playlist, download, share, etc.)
class SongOptionsSheet extends StatelessWidget {
  final Song song;
  final VoidCallback? onAddToPlaylist;
  final VoidCallback? onDownload;
  final VoidCallback? onShare;
  final VoidCallback? onAddToQueue;
  final VoidCallback? onGoToArtist;
  final VoidCallback? onGoToAlbum;

  const SongOptionsSheet({
    super.key,
    required this.song,
    this.onAddToPlaylist,
    this.onDownload,
    this.onShare,
    this.onAddToQueue,
    this.onGoToArtist,
    this.onGoToAlbum,
  });

  /// Show this sheet
  static Future<void> show(BuildContext context, Song song) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SongOptionsSheet(song: song),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: EverblushColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: EverblushColors.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Song info header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CachedArtwork(
                  url: song.thumbnailUrl,
                  size: 56,
                  borderRadius: 8,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: EverblushColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        song.artistName,
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
              ],
            ),
          ),

          const Divider(color: EverblushColors.outline, height: 1),

          // Options list
          _optionTile(
            icon: Icons.playlist_add_rounded,
            title: 'Add to playlist',
            onTap: () {
              Navigator.pop(context);
              onAddToPlaylist?.call();
            },
          ),
          _optionTile(
            icon: Icons.queue_music_rounded,
            title: 'Add to queue',
            onTap: () {
              Navigator.pop(context);
              onAddToQueue?.call();
            },
          ),
          _optionTile(
            icon: Icons.download_outlined,
            title: 'Download',
            onTap: () {
              Navigator.pop(context);
              onDownload?.call();
            },
          ),
          if (song.artists.isNotEmpty)
            _optionTile(
              icon: Icons.person_outlined,
              title: 'Go to artist',
              onTap: () {
                Navigator.pop(context);
                onGoToArtist?.call();
              },
            ),
          if (song.album != null)
            _optionTile(
              icon: Icons.album_outlined,
              title: 'Go to album',
              onTap: () {
                Navigator.pop(context);
                onGoToAlbum?.call();
              },
            ),
          _optionTile(
            icon: Icons.share_outlined,
            title: 'Share',
            onTap: () {
              Navigator.pop(context);
              onShare?.call();
            },
          ),

          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: EverblushColors.textSecondary),
      title: Text(
        title,
        style: const TextStyle(color: EverblushColors.textPrimary),
      ),
      onTap: onTap,
    );
  }
}
