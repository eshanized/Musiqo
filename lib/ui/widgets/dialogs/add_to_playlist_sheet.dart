// ============================================================================
// Add to Playlist Sheet - Select playlist to add song
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/everblush_colors.dart';
import 'create_playlist_dialog.dart';

/// Bottom sheet for selecting a playlist to add a song to.
class AddToPlaylistSheet extends ConsumerWidget {
  final String songId;

  const AddToPlaylistSheet({super.key, required this.songId});

  static Future<void> show(BuildContext context, String songId) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AddToPlaylistSheet(songId: songId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Get playlists from provider
    final playlists = [
      'My Favorites',
      'Chill Vibes',
      'Workout Mix',
      'Road Trip',
    ];

    return Container(
      decoration: const BoxDecoration(
        color: EverblushColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: EverblushColors.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Add to Playlist',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: EverblushColors.textPrimary,
              ),
            ),
          ),

          // Create new playlist
          ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: EverblushColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: EverblushColors.primary,
              ),
            ),
            title: const Text(
              'Create new playlist',
              style: TextStyle(
                color: EverblushColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () async {
              final name = await CreatePlaylistDialog.show(context);
              if (name != null && context.mounted) {
                // TODO: Create playlist and add song
                Navigator.pop(context);
              }
            },
          ),

          const Divider(color: EverblushColors.outline),

          // Playlists list
          ...playlists.map(
            (name) => ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: EverblushColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.queue_music_rounded,
                  color: EverblushColors.textMuted,
                ),
              ),
              title: Text(
                name,
                style: const TextStyle(color: EverblushColors.textPrimary),
              ),
              onTap: () {
                // TODO: Add to playlist
                Navigator.pop(context);
              },
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}
