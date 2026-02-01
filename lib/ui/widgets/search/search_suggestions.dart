// ============================================================================
// Search Suggestions Screen
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';

/// Search suggestions widget displayed during search.
class SearchSuggestions extends StatelessWidget {
  final List<String> suggestions;
  final List<String> history;
  final ValueChanged<String>? onSuggestionTap;
  final ValueChanged<String>? onHistoryRemove;
  final VoidCallback? onClearHistory;

  const SearchSuggestions({
    super.key,
    this.suggestions = const [],
    this.history = const [],
    this.onSuggestionTap,
    this.onHistoryRemove,
    this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // History section
        if (history.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: EverblushColors.textSecondary,
                ),
              ),
              TextButton(onPressed: onClearHistory, child: const Text('Clear')),
            ],
          ),
          ...history.map(
            (item) => ListTile(
              leading: const Icon(
                Icons.history_rounded,
                color: EverblushColors.textMuted,
              ),
              title: Text(
                item,
                style: const TextStyle(color: EverblushColors.textPrimary),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () => onHistoryRemove?.call(item),
                color: EverblushColors.textMuted,
              ),
              onTap: () => onSuggestionTap?.call(item),
            ),
          ),
          const Divider(color: EverblushColors.outline),
        ],

        // Suggestions section
        if (suggestions.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
              'Suggestions',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: EverblushColors.textSecondary,
              ),
            ),
          ),
          ...suggestions.map(
            (item) => ListTile(
              leading: const Icon(
                Icons.search_rounded,
                color: EverblushColors.textMuted,
              ),
              title: Text(
                item,
                style: const TextStyle(color: EverblushColors.textPrimary),
              ),
              trailing: const Icon(
                Icons.north_west_rounded,
                size: 16,
                color: EverblushColors.textMuted,
              ),
              onTap: () => onSuggestionTap?.call(item),
            ),
          ),
        ],
      ],
    );
  }
}
