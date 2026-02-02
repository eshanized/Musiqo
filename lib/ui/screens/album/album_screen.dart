// ============================================================================
// Album Screen - Album details with real data
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../providers/audio/player_provider.dart';
import '../../../providers/content/content_provider.dart';
import '../../../providers/library/library_provider.dart';
import '../../../providers/download/download_provider.dart';
import '../../navigation/routes.dart';


/// Album detail screen showing tracks and info.
class AlbumScreen extends ConsumerWidget {
  final String albumId;

  const AlbumScreen({
    super.key,
    required this.albumId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumAsync = ref.watch(albumDetailsProvider(albumId));

    return Scaffold(
      backgroundColor: EverblushColors.background,
      body: albumAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: EverblushColors.primary),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: EverblushColors.error),
              const SizedBox(height: 16),
              Text('Failed to load album', style: TextStyle(color: EverblushColors.textMuted)),
              TextButton(
                onPressed: () => ref.invalidate(albumDetailsProvider(albumId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (album) {
          if (album == null) {
            return const Center(
              child: Text('Album not found', style: TextStyle(color: EverblushColors.textMuted)),
            );
          }
          return _buildContent(context, ref, album);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, AlbumDetails album) {
    return CustomScrollView(
      slivers: [
        // Collapsing header with album art
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: EverblushColors.background,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Album art centered
                Center(
                  child: Container(
                    margin: const EdgeInsets.all(48),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: album.thumbnailUrl != null
                          ? Image.network(
                              album.thumbnailUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _albumPlaceholder(),
                            )
                          : _albumPlaceholder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Album info
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  album.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: EverblushColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),

                // Artist
                GestureDetector(
                  onTap: album.artistId != null
                      ? () => context.push('${Routes.artist}/${album.artistId!}')
                      : null,
                  child: Text(
                    album.artistName,
                    style: TextStyle(
                      fontSize: 16,
                      color: album.artistId != null
                          ? EverblushColors.primary
                          : EverblushColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // Metadata
                Text(
                  [
                    if (album.year != null) album.year,
                    if (album.trackCount != null) album.trackCount,
                    if (album.duration != null) album.duration,
                  ].where((e) => e != null).join(' • '),
                  style: const TextStyle(
                    fontSize: 12,
                    color: EverblushColors.textMuted,
                  ),
                ),
                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: album.tracks.isNotEmpty
                            ? () {
                                final handler = ref.read(audioHandlerProvider);
                                handler.playQueue(album.tracks);
                                context.push(Routes.player);
                              }
                            : null,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Play'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: album.tracks.isNotEmpty
                          ? () {
                              final handler = ref.read(audioHandlerProvider);
                              handler.toggleShuffle();
                              handler.playQueue(album.tracks);
                              context.push(Routes.player);
                            }
                          : null,
                      icon: const Icon(Icons.shuffle_rounded),
                      color: EverblushColors.textSecondary,
                    ),
                    IconButton(
                      onPressed: album.tracks.isNotEmpty
                          ? () {
                              for (final track in album.tracks) {
                                ref.read(downloadProvider.notifier).downloadSong(track);
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Downloading ${album.tracks.length} tracks...'),
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.download_outlined),
                      color: EverblushColors.textSecondary,
                    ),
                    IconButton(
                      onPressed: () {
                        Share.share(
                          'Check out "${album.title}" by ${album.artistName} on Musiqo!',
                        );
                      },
                      icon: const Icon(Icons.share_outlined),
                      color: EverblushColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Track list
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final track = album.tracks[index];
              return _trackTile(context, ref, track, index, album.tracks);
            },
            childCount: album.tracks.length,
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _albumPlaceholder() {
    return Container(
      width: 200,
      height: 200,
      color: EverblushColors.surfaceVariant,
      child: const Icon(
        Icons.album_rounded,
        size: 80,
        color: EverblushColors.textMuted,
      ),
    );
  }

  Widget _trackTile(BuildContext context, WidgetRef ref, dynamic track, int index, List tracks) {
    return ListTile(
      onTap: () {
        final handler = ref.read(audioHandlerProvider);
        handler.playQueue(tracks.cast(), startIndex: index);
        context.push(Routes.player);
      },
      leading: SizedBox(
        width: 32,
        child: Text(
          '${index + 1}',
          style: const TextStyle(color: EverblushColors.textMuted),
          textAlign: TextAlign.center,
        ),
      ),
      title: Text(
        track.title,
        style: const TextStyle(color: EverblushColors.textPrimary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _formatDuration(track.duration),
        style: const TextStyle(
          fontSize: 12,
          color: EverblushColors.textMuted,
        ),
      ),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, color: EverblushColors.textMuted),
        onSelected: (value) async {
          switch (value) {
            case 'play_next':
              ref.read(audioHandlerProvider).playNext(track);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Playing next')),
              );
              break;
            case 'add_queue':
              ref.read(audioHandlerProvider).addToQueue(track);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to queue')),
              );
              break;
            case 'like':
              await toggleLike(ref, track);
              break;
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'play_next',
            child: Row(
              children: [
                Icon(Icons.queue_play_next_rounded, size: 20),
                SizedBox(width: 12),
                Text('Play Next'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'add_queue',
            child: Row(
              children: [
                Icon(Icons.playlist_add_rounded, size: 20),
                SizedBox(width: 12),
                Text('Add to Queue'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'like',
            child: Row(
              children: [
                Icon(Icons.favorite_border_rounded, size: 20),
                SizedBox(width: 12),
                Text('Add to Favorites'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
