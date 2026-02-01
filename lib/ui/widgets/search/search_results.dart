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
  final SearchResult result;
  final Function(SearchResultItem)? onItemTap;

  const SearchResults({super.key, required this.result, this.onItemTap});

  @override
  Widget build(BuildContext context) {
    if (result.items.isEmpty) {
      return const Center(
        child: Text(
          'No results found',
          style: TextStyle(color: EverblushColors.textMuted),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: result.items.length,
      itemBuilder: (context, index) {
        final item = result.items[index];
        return SearchResultTile(item: item, onTap: () => onItemTap?.call(item));
      },
    );
  }
}
