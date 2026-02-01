// ============================================================================
// Search Results Widget
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../data/models/search_result.dart';
import '../lists/search_result_tile.dart';

/// Search results grid/list display.
class SearchResults extends StatelessWidget {
  final SearchResponse result;
  final Function(SearchResultItem)? onItemTap;

  const SearchResults({super.key, required this.result, this.onItemTap});

  @override
  Widget build(BuildContext context) {
    final items = _convertToItems();
    
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No results found',
          style: TextStyle(color: EverblushColors.textMuted),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return SearchResultTile(item: item, onTap: () => onItemTap?.call(item));
      },
    );
  }

  List<SearchResultItem> _convertToItems() {
    final items = <SearchResultItem>[];
    
    for (final song in result.songs) {
      items.add(SearchResultItem.fromSong(song));
    }
    for (final album in result.albums) {
      items.add(SearchResultItem.fromAlbum(album));
    }
    for (final artist in result.artists) {
      items.add(SearchResultItem.fromArtist(artist));
    }
    for (final playlist in result.playlists) {
      items.add(SearchResultItem.fromPlaylist(playlist));
    }
    
    return items;
  }
}

