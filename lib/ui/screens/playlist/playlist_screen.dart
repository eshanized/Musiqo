// ============================================================================
// Playlist Screen - Playlist details and songs
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../providers/playlist/playlist_provider.dart';
import '../../../providers/audio/player_provider.dart';
import '../../widgets/images/cached_artwork.dart';
import '../../widgets/dialogs/edit_playlist_dialog.dart';
import '../../widgets/lists/song_tile_placeholder.dart';

/// Playlist detail screen.
class PlaylistScreen extends ConsumerWidget {
  final String playlistId;

  const PlaylistScreen({
    super.key,
    required this.playlistId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistAsync = ref.watch(playlistProvider(playlistId));
    final audioHandler = ref.watch(audioHandlerProvider);

    return Scaffold(
      backgroundColor: EverblushColors.background,
      body: playlistAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (playlist) {
          if (playlist == null) {
            return const Center(child: Text('Playlist not found'));
          }
          
          final totalDuration = playlist.totalDuration;
          final durationString = '${totalDuration.inHours > 0 ? '${totalDuration.inHours} hr ' : ''}${totalDuration.inMinutes.remainder(60)} min';

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: EverblushColors.background,
                actions: [
                  if (playlist.isLocal)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: EverblushColors.textPrimary),
                      color: EverblushColors.surface,
                      onSelected: (value) async {
                        if (value == 'edit') {
                          EditPlaylistDialog.show(context, playlist);
                        } else if (value == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: EverblushColors.surface,
                              title: const Text('Delete Playlist', style: TextStyle(color: EverblushColors.textPrimary)),
                              content: Text('Are you sure you want to delete "${playlist.name}"?', style: const TextStyle(color: EverblushColors.textSecondary)),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: EverblushColors.error))),
                              ],
                            ),
                          );
                          
                          if (confirm == true) {
                            await ref.read(playlistActionsProvider.notifier).deletePlaylist(playlist.id);
                            if (context.mounted) Navigator.pop(context);
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit details', style: TextStyle(color: EverblushColors.textPrimary))),
                        const PopupMenuItem(value: 'delete', child: Text('Delete playlist', style: TextStyle(color: EverblushColors.error))),
                      ],
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (playlist.thumbnailUrl != null)
                        SizedBox.expand(
                          child: CachedArtwork(
                            url: playlist.thumbnailUrl,
                            size: 280,
                          ),
                        )
                      else
                        Container(
                          color: EverblushColors.surfaceVariant,
                          child: const Icon(Icons.music_note, size: 80, color: EverblushColors.textMuted),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              EverblushColors.background.withValues(alpha: 0.8),
                              EverblushColors.background,
                            ],
                            stops: const [0.0, 0.7, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playlist.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: EverblushColors.textPrimary,
                        ),
                      ),
                      if (playlist.description != null && playlist.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          playlist.description!,
                          style: const TextStyle(
                            color: EverblushColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        '${playlist.songCount} songs • $durationString',
                        style: const TextStyle(
                          fontSize: 12,
                          color: EverblushColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: playlist.songs.isEmpty ? null : () {
                                audioHandler.playSong(playlist.songs.first);
                                // Queue the rest
                                for (var i = 1; i < playlist.songs.length; i++) {
                                  audioHandler.addToQueue(playlist.songs[i]);
                                }
                                audioHandler.toggleShuffle();
                              },
                              icon: const Icon(Icons.shuffle_rounded),
                              label: const Text('Shuffle'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: EverblushColors.primary,
                                foregroundColor: EverblushColors.background,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: playlist.songs.isEmpty ? null : () {
                                audioHandler.playSong(playlist.songs.first);
                                for (var i = 1; i < playlist.songs.length; i++) {
                                  audioHandler.addToQueue(playlist.songs[i]);
                                }
                              },
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: const Text('Play'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: EverblushColors.primary),
                                foregroundColor: EverblushColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              if (playlist.songs.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No songs yet. Add songs from player or search.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: EverblushColors.textMuted),
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final song = playlist.songs[index];
                      return Dismissible(
                        key: ValueKey('${playlist.id}_${song.id}_$index'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          color: EverblushColors.error,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          ref.read(playlistActionsProvider.notifier)
                              .removeSongFromPlaylist(playlist.id, song.id);
                        },
                        child: SongTilePlaceholder(
                          song: song,
                          onTap: () => audioHandler.playSong(song),
                        ),
                      );
                    },
                    childCount: playlist.songs.length,
                  ),
                ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }
}
