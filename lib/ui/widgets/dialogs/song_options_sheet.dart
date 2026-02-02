// ============================================================================
// Song Options Dialog - Bottom sheet with song actions
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../data/models/song.dart';
import '../../../providers/download/download_provider.dart';
import '../../../providers/queue/queue_provider.dart';
import '../images/cached_artwork.dart';
import 'add_to_playlist_sheet.dart';

/// Bottom sheet with song actions (add to playlist, download, share, etc.)
class SongOptionsSheet extends ConsumerWidget {
  final Song song;

  const SongOptionsSheet({
    super.key,
    required this.song,
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
  Widget build(BuildContext context, WidgetRef ref) {
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
              AddToPlaylistSheet.show(context, song);
            },
          ),
          _optionTile(
            icon: Icons.queue_music_rounded,
            title: 'Add to queue',
            onTap: () {
              Navigator.pop(context);
              ref.read(queueProvider.notifier).addToQueue(song);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('"${song.title}" added to queue')),
              );
            },
          ),
          _optionTile(
            icon: Icons.download_outlined,
            title: 'Download',
            onTap: () {
              Navigator.pop(context);
              ref.read(downloadProvider.notifier).downloadSong(song);
            },
          ),
          if (song.artists.isNotEmpty)
            _optionTile(
              icon: Icons.person_outlined,
              title: 'Go to artist',
              onTap: () {
                Navigator.pop(context);
                context.push('/artist/${song.artists.first.id}');
              },
            ),
          if (song.album != null)
            _optionTile(
              icon: Icons.album_outlined,
              title: 'Go to album',
              onTap: () {
                Navigator.pop(context);
                context.push('/album/${song.album!.id}');
              },
            ),
          _optionTile(
            icon: Icons.share_outlined,
            title: 'Share',
            onTap: () {
              Navigator.pop(context);
              Share.share('Check out "${song.title}" by ${song.artistName} on Musiqo!');
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
