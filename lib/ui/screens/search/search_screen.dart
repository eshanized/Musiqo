// ============================================================================
// Search Screen - Find songs, albums, artists with real YouTube Music data
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../core/utils/debouncer.dart';
import '../../../data/models/song.dart';
import '../../../data/models/search_result.dart';
import '../../../providers/data/youtube_provider.dart';
import '../../../providers/audio/player_provider.dart';
import '../../navigation/routes.dart';
import '../../widgets/images/cached_artwork.dart';

/// Provider for search results
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for search suggestions
final suggestionsProvider = FutureProvider<List<String>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];

  final youtube = ref.watch(youtubeProvider);
  return youtube.getSuggestions(query);
});

/// Provider for search results
final searchResultsProvider = FutureProvider<SearchResponse>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return const SearchResponse();

  final youtube = ref.watch(youtubeProvider);
  return youtube.search(query);
});

/// Search screen with real-time suggestions.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final Debouncer _debouncer = Debouncer(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debouncer.run(() {
      ref.read(searchQueryProvider.notifier).state = value;
    });
  }

  void _playSong(Song song) {
    final audioHandler = ref.read(audioHandlerProvider);
    audioHandler.playSong(song);
    context.push(Routes.player);
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      backgroundColor: EverblushColors.background,
      appBar: AppBar(
        backgroundColor: EverblushColors.background,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: _onQueryChanged,
          onSubmitted: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
          },
          style: const TextStyle(color: EverblushColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search songs, albums, artists...',
            hintStyle: const TextStyle(color: EverblushColors.textMuted),
            border: InputBorder.none,
            suffixIcon:
                query.isNotEmpty
                    ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        ref.read(searchQueryProvider.notifier).state = '';
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        color: EverblushColors.textMuted,
                      ),
                    )
                    : null,
          ),
        ),
      ),
      body: query.isEmpty ? _buildSuggestions() : _buildResults(),
    );
  }

  Widget _buildSuggestions() {
    final suggestionsAsync = ref.watch(suggestionsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Recent Searches',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: EverblushColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // Show suggestions if available
        suggestionsAsync.when(
          data: (suggestions) {
            if (suggestions.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              children:
                  suggestions.take(5).map((term) {
                    return ListTile(
                      leading: const Icon(
                        Icons.search,
                        color: EverblushColors.textMuted,
                      ),
                      title: Text(
                        term,
                        style: const TextStyle(
                          color: EverblushColors.textPrimary,
                        ),
                      ),
                      onTap: () {
                        _searchController.text = term;
                        ref.read(searchQueryProvider.notifier).state = term;
                      },
                    );
                  }).toList(),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),

        const SizedBox(height: 24),

        const Text(
          'Trending',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: EverblushColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              [
                'Arijit Singh',
                'K-Pop',
                'Bollywood',
                'Hip Hop',
                'Indie',
                'Electronic',
              ].map((tag) {
                return ActionChip(
                  label: Text(tag),
                  onPressed: () {
                    _searchController.text = tag;
                    ref.read(searchQueryProvider.notifier).state = tag;
                  },
                  backgroundColor: EverblushColors.surface,
                  labelStyle: const TextStyle(
                    color: EverblushColors.textPrimary,
                  ),
                  side: const BorderSide(color: EverblushColors.outline),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildResults() {
    final resultsAsync = ref.watch(searchResultsProvider);

    return resultsAsync.when(
      loading:
          () => const Center(
            child: CircularProgressIndicator(color: EverblushColors.primary),
          ),
      error:
          (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: EverblushColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Search failed',
                  style: const TextStyle(color: EverblushColors.textPrimary),
                ),
                TextButton(
                  onPressed: () => ref.refresh(searchResultsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
      data: (results) {
        final allItems = <Widget>[];

        // Songs section
        if (results.songs.isNotEmpty) {
          allItems.add(_buildSectionHeader('Songs'));
          allItems.addAll(
            results.songs.map((songResult) => _buildSongTile(songResult.song)),
          );
        }

        // Albums section
        if (results.albums.isNotEmpty) {
          allItems.add(_buildSectionHeader('Albums'));
          allItems.addAll(
            results.albums.map((album) => _buildAlbumTile(album)),
          );
        }

        // Artists section
        if (results.artists.isNotEmpty) {
          allItems.add(_buildSectionHeader('Artists'));
          allItems.addAll(
            results.artists.map((artist) => _buildArtistTile(artist)),
          );
        }

        if (allItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search_off,
                  size: 64,
                  color: EverblushColors.textMuted,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No results found',
                  style: TextStyle(
                    color: EverblushColors.textMuted,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: allItems,
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: EverblushColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSongTile(Song song) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child:
            song.thumbnailUrl != null
                ? CachedArtwork(
                  url: song.thumbnailUrl,
                  size: 48,
                  borderRadius: 8,
                )
                : Container(
                  width: 48,
                  height: 48,
                  color: EverblushColors.surfaceVariant,
                  child: const Icon(
                    Icons.music_note,
                    color: EverblushColors.textMuted,
                  ),
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
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        onPressed: () {},
        icon: const Icon(Icons.more_vert, color: EverblushColors.textMuted),
      ),
      onTap: () => _playSong(song),
    );
  }

  Widget _buildAlbumTile(AlbumResult album) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child:
            album.thumbnailUrl != null
                ? CachedArtwork(
                  url: album.thumbnailUrl,
                  size: 48,
                  borderRadius: 8,
                )
                : Container(
                  width: 48,
                  height: 48,
                  color: EverblushColors.surfaceVariant,
                  child: const Icon(
                    Icons.album,
                    color: EverblushColors.textMuted,
                  ),
                ),
      ),
      title: Text(
        album.name,
        style: const TextStyle(color: EverblushColors.textPrimary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        album.artistName ?? 'Album',
        style: const TextStyle(fontSize: 12, color: EverblushColors.textMuted),
      ),
      onTap: () => context.push('/album/${album.id}'),
    );
  }

  Widget _buildArtistTile(ArtistResult artist) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child:
            artist.thumbnailUrl != null
                ? CachedArtwork(
                  url: artist.thumbnailUrl,
                  size: 48,
                  borderRadius: 24,
                  isCircular: true,
                )
                : Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: EverblushColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: EverblushColors.textMuted,
                  ),
                ),
      ),
      title: Text(
        artist.name,
        style: const TextStyle(color: EverblushColors.textPrimary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: const Text(
        'Artist',
        style: TextStyle(fontSize: 12, color: EverblushColors.textMuted),
      ),
      onTap: () => context.push('/artist/${artist.id}'),
    );
  }
}
