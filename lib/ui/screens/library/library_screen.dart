// ============================================================================
// Library Screen - User's saved music
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/everblush_colors.dart';

/// Library screen showing user's playlists, downloads, and history.
/// 
/// Has tabs for:
/// - Playlists
/// - Downloads
/// - History
/// - Favorites
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
                    // TODO: Create playlist dialog
                  },
                  icon: const Icon(
                    Icons.add_rounded,
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
                  Tab(text: 'Playlists'),
                  Tab(text: 'Downloads'),
                  Tab(text: 'History'),
                  Tab(text: 'Favorites'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPlaylistsTab(),
            _buildDownloadsTab(),
            _buildHistoryTab(),
            _buildFavoritesTab(),
          ],
        ),
      ),
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
          iconBgColor: EverblushColors.surfaceVariant,
          title: 'Create playlist',
          onTap: () {},
        ),
        
        const SizedBox(height: 8),
        
        // Liked Songs (always first)
        _libraryItem(
          icon: Icons.favorite_rounded,
          iconBgColor: EverblushColors.error.withValues(alpha: 0.2),
          iconColor: EverblushColors.error,
          title: 'Liked Songs',
          subtitle: '0 songs',
          onTap: () {},
        ),
        
        const SizedBox(height: 8),
        
        // Placeholder playlists
        ...List.generate(5, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _libraryItem(
              icon: Icons.queue_music_rounded,
              title: 'My Playlist ${index + 1}',
              subtitle: '${(index + 1) * 5} songs',
              onTap: () {},
            ),
          );
        }),
        
        const SizedBox(height: 100), // mini player space
      ],
    );
  }

  /// Downloads tab
  Widget _buildDownloadsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.download_for_offline_outlined,
            size: 64,
            color: EverblushColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No downloads yet',
            style: TextStyle(
              fontSize: 18,
              color: EverblushColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Songs you download will appear here',
            style: TextStyle(
              color: EverblushColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  /// History tab
  Widget _buildHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 20,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: EverblushColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.music_note_rounded,
              color: EverblushColors.textMuted,
            ),
          ),
          title: Text(
            'Song ${index + 1}',
            style: const TextStyle(color: EverblushColors.textPrimary),
          ),
          subtitle: Text(
            'Artist Name • ${index + 1} days ago',
            style: const TextStyle(
              fontSize: 12,
              color: EverblushColors.textMuted,
            ),
          ),
          trailing: IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
              color: EverblushColors.textMuted,
            ),
          ),
        );
      },
    );
  }

  /// Favorites tab
  Widget _buildFavoritesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 64,
            color: EverblushColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 18,
              color: EverblushColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the heart icon to save songs',
            style: TextStyle(
              color: EverblushColors.textMuted,
            ),
          ),
        ],
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
}
