// ============================================================================
// Artist Screen - Artist profile with real data
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../providers/audio/player_provider.dart';
import '../../../providers/content/content_provider.dart';
import '../../navigation/routes.dart';
import '../../widgets/images/cached_artwork.dart';

/// Artist detail screen showing bio, top songs, and albums.
class ArtistScreen extends ConsumerWidget {
  final String artistId;

  const ArtistScreen({
    super.key,
    required this.artistId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artistAsync = ref.watch(artistDetailsProvider(artistId));

    return Scaffold(
      backgroundColor: EverblushColors.background,
      body: artistAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: EverblushColors.primary),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: EverblushColors.error),
              const SizedBox(height: 16),
              Text('Failed to load artist', style: TextStyle(color: EverblushColors.textMuted)),
              TextButton(
                onPressed: () => ref.invalidate(artistDetailsProvider(artistId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (artist) {
          if (artist == null) {
            return const Center(
              child: Text('Artist not found', style: TextStyle(color: EverblushColors.textMuted)),
            );
          }
          return _buildContent(context, ref, artist);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, ArtistDetails artist) {
    return CustomScrollView(
      slivers: [
        // Collapsing header with artist image
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: EverblushColors.background,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              artist.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: EverblushColors.textPrimary,
                fontSize: 18,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Artist image
                if (artist.thumbnailUrl != null)
                  Image.network(
                    artist.thumbnailUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: EverblushColors.surfaceVariant,
                      child: const Icon(Icons.person, size: 80, color: EverblushColors.textMuted),
                    ),
                  )
                else
                  Container(
                    color: EverblushColors.surfaceVariant,
                    child: const Icon(Icons.person, size: 80, color: EverblushColors.textMuted),
                  ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        EverblushColors.background.withValues(alpha: 0.7),
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

        // Content
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Stats row
              if (artist.subscriberCount != null)
                Center(
                  child: Text(
                    artist.subscriberCount!,
                    style: const TextStyle(
                      color: EverblushColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Play and Shuffle buttons
              if (artist.songs.isNotEmpty)
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          final handler = ref.read(audioHandlerProvider);
                          handler.playQueue(artist.songs);
                          context.push(Routes.player);
                        },
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Play'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final handler = ref.read(audioHandlerProvider);
                          handler.toggleShuffle();
                          handler.playQueue(artist.songs);
                          context.push(Routes.player);
                        },
                        icon: const Icon(Icons.shuffle_rounded),
                        label: const Text('Shuffle'),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 24),

              // Top Songs
              if (artist.songs.isNotEmpty) ...[
                _sectionHeader('Top Songs'),
                const SizedBox(height: 8),
                ...artist.songs.map((song) => _songTile(context, ref, song, artist.songs)),
              ],

              const SizedBox(height: 24),

              // Albums
              if (artist.albums.isNotEmpty) ...[
                _sectionHeader('Albums'),
                const SizedBox(height: 8),
              ],
            ]),
          ),
        ),

        // Albums carousel
        if (artist.albums.isNotEmpty)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: artist.albums.length,
                itemBuilder: (context, index) {
                  final album = artist.albums[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () => context.push('${Routes.album}/${album.id}'),
                      child: SizedBox(
                        width: 140,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedArtwork(
                                url: album.thumbnailUrl,
                                size: 140,
                                borderRadius: 8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              album.title,
                              style: const TextStyle(
                                color: EverblushColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (album.year != null)
                              Text(
                                album.year!,
                                style: const TextStyle(
                                  color: EverblushColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

        // Similar Artists
        if (artist.similarArtists.isNotEmpty) ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            sliver: SliverToBoxAdapter(child: _sectionHeader('Similar Artists')),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: artist.similarArtists.length,
                itemBuilder: (context, index) {
                  final similar = artist.similarArtists[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: () => context.push('${Routes.artist}/${similar.id}'),
                      child: SizedBox(
                        width: 100,
                        child: Column(
                          children: [
                            ClipOval(
                              child: CachedArtwork(
                                url: similar.thumbnailUrl,
                                size: 100,
                                borderRadius: 50,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              similar.name,
                              style: const TextStyle(
                                color: EverblushColors.textPrimary,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: EverblushColors.textPrimary,
      ),
    );
  }

  Widget _songTile(BuildContext context, WidgetRef ref, dynamic song, List songs) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () {
        final handler = ref.read(audioHandlerProvider);
        handler.playQueue(songs.cast(), startIndex: songs.indexOf(song));
        context.push(Routes.player);
      },
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedArtwork(
          url: song.thumbnailUrl,
          size: 48,
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
        style: const TextStyle(fontSize: 12, color: EverblushColors.textMuted),
        maxLines: 1,
      ),
      trailing: IconButton(
        onPressed: () {
          final handler = ref.read(audioHandlerProvider);
          handler.addToQueue(song);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Added to queue')),
          );
        },
        icon: const Icon(Icons.add_rounded, color: EverblushColors.textMuted),
      ),
    );
  }
}
