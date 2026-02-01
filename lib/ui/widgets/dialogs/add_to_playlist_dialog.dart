// ============================================================================
// Add to Playlist Dialog - Select playlist to add song
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../data/models/song.dart';
import '../../../providers/playlist/playlist_provider.dart';
import 'create_playlist_dialog.dart';

/// Dialog for adding a song to a playlist
class AddToPlaylistDialog extends ConsumerWidget {
  final Song song;

  const AddToPlaylistDialog({super.key, required this.song});

  static Future<void> show(BuildContext context, Song song) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: EverblushColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => AddToPlaylistDialog(song: song),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: EverblushColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Title
          const Text(
            'Add to Playlist',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: EverblushColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            song.title,
            style: const TextStyle(color: EverblushColors.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          
          // Create new playlist option
          ListTile(
            onTap: () {
              Navigator.pop(context);
              CreatePlaylistDialog.show(context);
            },
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: EverblushColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add_rounded, color: EverblushColors.primary),
            ),
            title: const Text(
              'Create new playlist',
              style: TextStyle(color: EverblushColors.primary),
            ),
          ),
          
          const Divider(color: EverblushColors.surfaceVariant),
          
          // Playlist list
          playlistsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e', style: const TextStyle(color: EverblushColors.error)),
            data: (playlists) {
              if (playlists.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No playlists yet',
                    style: TextStyle(color: EverblushColors.textMuted),
                  ),
                );
              }
              
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    final alreadyAdded = playlist.songs.any((s) => s.id == song.id);
                    
                    return ListTile(
                      onTap: alreadyAdded ? null : () async {
                        await ref.read(playlistActionsProvider.notifier)
                            .addSongToPlaylist(playlist.id, song);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Added to ${playlist.name}')),
                          );
                        }
                      },
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
                            ? const Icon(Icons.playlist_play, color: EverblushColors.textMuted)
                            : null,
                      ),
                      title: Text(
                        playlist.name,
                        style: TextStyle(
                          color: alreadyAdded 
                              ? EverblushColors.textMuted 
                              : EverblushColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        alreadyAdded 
                            ? 'Already added' 
                            : '${playlist.songCount} songs',
                        style: const TextStyle(
                          fontSize: 12,
                          color: EverblushColors.textMuted,
                        ),
                      ),
                      trailing: alreadyAdded
                          ? const Icon(Icons.check_circle, color: EverblushColors.success)
                          : null,
                    );
                  },
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
