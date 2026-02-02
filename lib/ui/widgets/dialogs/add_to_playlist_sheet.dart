// ============================================================================
// Add to Playlist Sheet - Select playlist to add song
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../data/models/song.dart';
import '../../../providers/playlist/playlist_provider.dart';
import 'create_playlist_dialog.dart';

/// Bottom sheet for selecting a playlist to add a song to.
class AddToPlaylistSheet extends ConsumerWidget {
  final Song song;

  const AddToPlaylistSheet({super.key, required this.song});

  static Future<void> show(BuildContext context, Song song) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AddToPlaylistSheet(song: song),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsProvider);

    return Container(
      decoration: const BoxDecoration(
        color: EverblushColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
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
              final playlist = await CreatePlaylistDialog.show(context);
              if (playlist != null && context.mounted) {
                await ref.read(playlistActionsProvider.notifier).addSongToPlaylist(playlist.id, song);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),

          const Divider(color: EverblushColors.outline),

          // Playlists list
          Expanded(
            child: playlistsAsync.when(
              data: (playlists) {
                if (playlists.isEmpty) {
                  return const Center(
                    child: Text(
                      'No playlists yet',
                      style: TextStyle(color: EverblushColors.textMuted),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    return ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: EverblushColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                          image: playlist.thumbnailUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(playlist.thumbnailUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: playlist.thumbnailUrl == null
                            ? const Icon(
                                Icons.queue_music_rounded,
                                color: EverblushColors.textMuted,
                              )
                            : null,
                      ),
                      title: Text(
                        playlist.name,
                        style: const TextStyle(color: EverblushColors.textPrimary),
                      ),
                      subtitle: Text(
                        '${playlist.songCount} songs',
                        style: const TextStyle(color: EverblushColors.textMuted, fontSize: 12),
                      ),
                      onTap: () async {
                        await ref.read(playlistActionsProvider.notifier).addSongToPlaylist(playlist.id, song);
                        if (context.mounted) Navigator.pop(context);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
