// ============================================================================
// Home Screen - The main landing page with real YouTube Music data
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/song.dart';
import '../../../data/models/playlist.dart';
import '../../../providers/data/youtube_provider.dart';
import '../../../providers/audio/player_provider.dart';
import '../../../services/innertube/youtube_facade.dart';
import '../../navigation/routes.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/lists/carousel_card.dart';
import '../../widgets/images/cached_artwork.dart';

/// The home screen with personalized content from YouTube Music.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final homePageAsync = ref.watch(homePageProvider);

    return Scaffold(
      backgroundColor: EverblushColors.background,
      body: CustomScrollView(
        slivers: [
          // App bar with greeting
          SliverAppBar(
            floating: true,
            backgroundColor: EverblushColors.background,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: EverblushColors.textPrimary,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () => context.push(Routes.search),
                icon: const Icon(
                  Icons.search_rounded,
                  color: EverblushColors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () => context.push(Routes.settings),
                icon: const Icon(
                  Icons.settings_outlined,
                  color: EverblushColors.textPrimary,
                ),
              ),
            ],
          ),

          // Content based on async state
          homePageAsync.when(
            loading:
                () => const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: EverblushColors.primary,
                    ),
                  ),
                ),
            error:
                (error, stack) => SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: EverblushColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load content',
                          style: const TextStyle(
                            color: EverblushColors.textPrimary,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => ref.refresh(homePageProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
            data: (homeData) => _buildContent(homeData),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(HomePageData homeData) {
    if (homeData.sections.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.music_off,
                size: 64,
                color: EverblushColors.textMuted,
              ),
              const SizedBox(height: 16),
              const Text(
                'No content available',
                style: TextStyle(
                  color: EverblushColors.textMuted,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => ref.refresh(homePageProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final section = homeData.sections[index];
          return _buildSection(section);
        }, childCount: homeData.sections.length),
      ),
    );
  }

  Widget _buildSection(HomeSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        SectionHeader(title: section.title, subtitle: section.subtitle),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: section.items.length,
            itemBuilder: (context, index) {
              final item = section.items[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildCarouselItem(item),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCarouselItem(dynamic item) {
    Log.debug('Building item: ${item.runtimeType}', tag: 'HomeScreen');
    if (item is Song) {
      return _buildSongCard(item);
    } else if (item is Album) {
      return _buildAlbumCard(item);
    } else if (item is Artist) {
      return _buildArtistCard(item);
    } else if (item is Playlist) {
      return _buildPlaylistCard(item);
    } else {
      Log.warning('Unknown item type: ${item.runtimeType}', tag: 'HomeScreen');
      return CarouselCard(width: 140, title: 'Unknown', subtitle: item.runtimeType.toString());
    }
  }

  Widget _buildPlaylistCard(Playlist playlist) {
    return GestureDetector(
      onTap: () => context.push('${Routes.playlist}/${playlist.id}'),
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedArtwork(
                url: playlist.thumbnailUrl,
                size: 140,
                borderRadius: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              playlist.name,
              style: const TextStyle(
                color: EverblushColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongCard(Song song) {
    return GestureDetector(
      onTap: () => _playSong(song),
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with play overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      song.thumbnailUrl != null
                          ? CachedArtwork(
                            url: song.thumbnailUrl,
                            size: 140,
                            borderRadius: 12,
                          )
                          : Container(
                            width: 140,
                            height: 140,
                            color: EverblushColors.surface,
                            child: const Icon(
                              Icons.music_note,
                              color: EverblushColors.textMuted,
                              size: 48,
                            ),
                          ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.black26,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        color: Colors.white70,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              song.title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: EverblushColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              song.artistName,
              style: const TextStyle(
                fontSize: 11,
                color: EverblushColors.textMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumCard(Album album) {
    return CarouselCard(
      width: 140,
      title: album.name,
      imageUrl: album.thumbnailUrl,
      onTap: () {
        context.push('/album/${album.id}');
      },
    );
  }

  Widget _buildArtistCard(Artist artist) {
    return CarouselCard(
      width: 140,
      title: artist.name,
      imageUrl: artist.thumbnailUrl,
      isCircular: true,
      onTap: () {
        context.push('/artist/${artist.id}');
      },
    );
  }

  void _playSong(Song song) {
    final audioHandler = ref.read(audioHandlerProvider);
    audioHandler.playSong(song);

    // Navigate to player
    context.push(Routes.player);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
