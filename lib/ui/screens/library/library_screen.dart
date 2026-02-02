// ============================================================================
// Library Screen - User's saved music with real data
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../data/models/song.dart';
import '../../../providers/audio/player_provider.dart';
import '../../../providers/library/library_provider.dart';
import '../../navigation/routes.dart';
import '../../widgets/images/cached_artwork.dart';

/// Library screen showing user's playlists, downloads, and history.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EverblushColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              pinned: true,
              backgroundColor: EverblushColors.background,
              title: const Text(
                'Library',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: EverblushColors.textPrimary,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    context.push(Routes.search);
                  },
                  icon: const Icon(
                    Icons.search_rounded,
                    color: EverblushColors.textPrimary,
                  ),
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                labelColor: EverblushColors.primary,
                unselectedLabelColor: EverblushColors.textMuted,
                indicatorColor: EverblushColors.primary,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Favorites'),
                  Tab(text: 'History'),
                  Tab(text: 'Playlists'),
                  Tab(text: 'Downloads'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildFavoritesTab(),
            _buildHistoryTab(),
            _buildPlaylistsTab(),
            _buildDownloadsTab(),
          ],
        ),
      ),
    );
  }

  /// Favorites tab with real data
  Widget _buildFavoritesTab() {
    final likedSongsAsync = ref.watch(likedSongsProvider);
    
    return likedSongsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (songs) {
        if (songs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.favorite_border_rounded,
            title: 'No favorites yet',
            subtitle: 'Tap the heart icon on songs to save them here',
          );
        }

        return Column(
          children: [
            // Play all / Shuffle buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final handler = ref.read(audioHandlerProvider);
                        handler.playQueue(songs);
                      },
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Play All'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        final handler = ref.read(audioHandlerProvider);
                        handler.toggleShuffle();
                        handler.playQueue(songs);
                      },
                      icon: const Icon(Icons.shuffle_rounded),
                      label: const Text('Shuffle'),
                    ),
                  ),
                ],
              ),
            ),
            // Songs list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  return _buildSongTile(songs[index], songs: songs, index: index);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// History tab with real data
  Widget _buildHistoryTab() {
    final historyAsync = ref.watch(recentHistoryProvider);
    
    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (songs) {
        if (songs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.history_rounded,
            title: 'No play history',
            subtitle: 'Songs you play will appear here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: songs.length,
          itemBuilder: (context, index) {
            return _buildSongTile(songs[index], songs: songs, index: index);
          },
        );
      },
    );
  }

  /// Playlists tab
  Widget _buildPlaylistsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Create playlist button
        _libraryItem(
          icon: Icons.add_rounded,
          iconBgColor: EverblushColors.primary.withValues(alpha: 0.2),
          iconColor: EverblushColors.primary,
          title: 'Create Playlist',
          onTap: () => _showCreatePlaylistDialog(context),
        ),
        const SizedBox(height: 16),
        const Text(
          'Your Playlists',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: EverblushColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildEmptyState(
          icon: Icons.queue_music_rounded,
          title: 'No playlists yet',
          subtitle: 'Create a playlist to organize your music',
        ),
      ],
    );
  }

  /// Downloads tab
  Widget _buildDownloadsTab() {
    return _buildEmptyState(
      icon: Icons.download_for_offline_outlined,
      title: 'No downloads yet',
      subtitle: 'Download songs for offline listening',
    );
  }

  /// Build a song list tile
  Widget _buildSongTile(Song song, {List<Song>? songs, int? index}) {
    return ListTile(
      onTap: () {
        if (songs != null && index != null) {
          final handler = ref.read(audioHandlerProvider);
          handler.playQueue(songs, startIndex: index);
        } else {
          final handler = ref.read(audioHandlerProvider);
          handler.playSong(song);
        }
        context.push(Routes.player);
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedArtwork(
          url: song.thumbnailUrl,
          size: 50,
          borderRadius: 8,
        ),
      ),
      title: Text(
        song.title,
        style: const TextStyle(color: EverblushColors.textPrimary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artistName,
        style: const TextStyle(
          fontSize: 12,
          color: EverblushColors.textMuted,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, color: EverblushColors.textMuted),
        onSelected: (value) async {
          switch (value) {
            case 'play_next':
              final handler = ref.read(audioHandlerProvider);
              handler.playNext(song);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Playing next')),
              );
              break;
            case 'add_queue':
              final handler = ref.read(audioHandlerProvider);
              handler.addToQueue(song);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to queue')),
              );
              break;
            case 'toggle_like':
              await toggleLike(ref, song);
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
            value: 'toggle_like',
            child: Row(
              children: [
                Icon(Icons.favorite_border_rounded, size: 20),
                SizedBox(width: 12),
                Text('Toggle Like'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Empty state widget
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: EverblushColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: EverblushColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: EverblushColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// A library list item
  Widget _libraryItem({
    required IconData icon,
    Color? iconBgColor,
    Color? iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: iconBgColor ?? EverblushColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor ?? EverblushColors.textMuted,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: EverblushColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: EverblushColors.textMuted,
              ),
            )
          : null,
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final textController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: EverblushColors.surface,
        title: const Text(
          'Create Playlist',
          style: TextStyle(color: EverblushColors.textPrimary),
        ),
        content: TextField(
          controller: textController,
          autofocus: true,
          style: const TextStyle(color: EverblushColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Playlist name',
            hintStyle: TextStyle(
              color: EverblushColors.textMuted.withValues(alpha: 0.7),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: EverblushColors.outline),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: EverblushColors.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = textController.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Playlist "$name" created')),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
