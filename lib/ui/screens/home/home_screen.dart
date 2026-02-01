// ============================================================================
// Home Screen - Enhanced landing page with premium UI
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
import '../../widgets/home/quick_picks_section.dart';
import '../../widgets/home/artist_avatar.dart';
import '../../widgets/home/enhanced_cards.dart';

/// The home screen with personalized content from YouTube Music.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homePageAsync = ref.watch(homePageProvider);

    return Scaffold(
      backgroundColor: EverblushColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(homePageProvider);
        },
        color: EverblushColors.primary,
        backgroundColor: EverblushColors.surface,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Gradient app bar
            _buildAppBar(),

            // Content
            homePageAsync.when(
              loading: () => _buildLoadingState(),
              error: (error, stack) => _buildErrorState(error),
              data: (homeData) => _buildContent(homeData),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              EverblushColors.background,
              EverblushColors.background.withValues(alpha: 0.8),
            ],
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getGreeting(),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: EverblushColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _getSubtitle(),
            style: TextStyle(
              fontSize: 13,
              color: EverblushColors.textMuted.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
      actions: [
        _buildActionButton(
          icon: Icons.search_rounded,
          onPressed: () => context.push(Routes.search),
        ),
        _buildActionButton(
          icon: Icons.settings_outlined,
          onPressed: () => context.push(Routes.settings),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: EverblushColors.surface.withValues(alpha: 0.8),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: EverblushColors.textPrimary, size: 22),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: EverblushColors.primary,
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Loading your music...',
              style: TextStyle(
                color: EverblushColors.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: EverblushColors.error.withValues(alpha: 0.15),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: EverblushColors.error,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                color: EverblushColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your connection and try again',
              style: TextStyle(
                color: EverblushColors.textMuted.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.tonal(
              onPressed: () => ref.refresh(homePageProvider),
              style: FilledButton.styleFrom(
                backgroundColor: EverblushColors.primary.withValues(alpha: 0.2),
                foregroundColor: EverblushColors.primary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(HomePageData homeData) {
    if (homeData.sections.isEmpty) {
      return _buildEmptyState();
    }

    // Separate sections by type for custom layouts
    final List<Song> quickPicksSongs = [];
    final List<Artist> artists = [];
    final List<HomeSection> otherSections = [];

    for (final section in homeData.sections) {
      final titleLower = section.title.toLowerCase();
      
      // Collect quick picks songs
      if (titleLower.contains('quick') || titleLower.contains('pick') || 
          titleLower.contains('listen again')) {
        for (final item in section.items) {
          if (item is Song && quickPicksSongs.length < 6) {
            quickPicksSongs.add(item);
          }
        }
      } 
      // Collect artists
      else if (titleLower.contains('artist') || titleLower.contains('similar')) {
        for (final item in section.items) {
          if (item is Artist) {
            artists.add(item);
          }
        }
        if (artists.isEmpty) {
          otherSections.add(section);
        }
      } 
      else {
        otherSections.add(section);
      }
    }

    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 120),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Quick Picks section
          if (quickPicksSongs.isNotEmpty) ...[
            const SizedBox(height: 12),
            FadeTransition(
              opacity: _animationController,
              child: QuickPicksSection(
                songs: quickPicksSongs,
                onSongTap: _playSong,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Artists section
          if (artists.isNotEmpty) ...[
            FadeTransition(
              opacity: _animationController,
              child: ArtistAvatarList(
                title: 'Artists for you',
                artists: artists,
                onArtistTap: (artist) => context.push('/artist/${artist.id}'),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Other sections with staggered animation
          ...otherSections.asMap().entries.map((entry) {
            final index = entry.key;
            final section = entry.value;
            
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  (0.1 + index * 0.1).clamp(0.0, 0.8),
                  (0.4 + index * 0.1).clamp(0.2, 1.0),
                  curve: Curves.easeOut,
                ),
              )),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(
                    (0.1 + index * 0.1).clamp(0.0, 0.8),
                    (0.4 + index * 0.1).clamp(0.2, 1.0),
                  ),
                ),
                child: _buildEnhancedSection(section),
              ),
            );
          }),
        ]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.library_music_rounded,
              size: 64,
              color: EverblushColors.textMuted,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your music awaits',
              style: TextStyle(
                color: EverblushColors.textMuted,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => ref.refresh(homePageProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
              style: TextButton.styleFrom(
                foregroundColor: EverblushColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedSection(HomeSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            section.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: EverblushColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ),
        if (section.subtitle != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              section.subtitle!,
              style: TextStyle(
                fontSize: 13,
                color: EverblushColors.textMuted.withValues(alpha: 0.8),
              ),
            ),
          ),
        const SizedBox(height: 14),

        // Horizontal carousel
        SizedBox(
          height: 210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: section.items.length,
            itemBuilder: (context, index) {
              final item = section.items[index];
              return Padding(
                padding: const EdgeInsets.only(right: 14),
                child: _buildEnhancedItem(item),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildEnhancedItem(dynamic item) {
    Log.debug('Building item: ${item.runtimeType}', tag: 'HomeScreen');
    
    if (item is Song) {
      return EnhancedSongCard(
        title: item.title,
        artistName: item.artistName,
        imageUrl: item.thumbnailUrl,
        width: 150,
        onTap: () => _playSong(item),
      );
    } else if (item is Album) {
      return EnhancedAlbumCard(
        title: item.name,
        imageUrl: item.thumbnailUrl,
        width: 150,
        onTap: () => context.push('/album/${item.id}'),
      );
    } else if (item is Artist) {
      return ArtistAvatar(
        artist: item,
        size: 120,
        onTap: () => context.push('/artist/${item.id}'),
      );
    } else if (item is Playlist) {
      return EnhancedAlbumCard(
        title: item.name,
        imageUrl: item.thumbnailUrl,
        width: 150,
        onTap: () => context.push('${Routes.playlist}/${item.id}'),
      );
    } else {
      Log.warning('Unknown item type: ${item.runtimeType}', tag: 'HomeScreen');
      return const SizedBox.shrink();
    }
  }

  void _playSong(Song song) {
    final audioHandler = ref.read(audioHandlerProvider);
    audioHandler.playSong(song);
    context.push(Routes.player);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'Late night vibes';
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    if (hour < 21) return 'Good evening';
    return 'Night owl mode';
  }

  String _getSubtitle() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'Music for the night owls';
    if (hour < 12) return 'Start your day with great music';
    if (hour < 17) return 'Perfect tunes for your afternoon';
    if (hour < 21) return 'Wind down with your favorites';
    return 'Let the music keep you company';
  }
}
