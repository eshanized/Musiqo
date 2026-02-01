// ============================================================================
// Search Provider - State management for search
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/search_result.dart';
import 'youtube_provider.dart';

/// Current search query provider
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Search results provider
///
/// This is a FutureProvider.family - it takes a parameter (the query)
/// and returns search results for that query.
final searchResultsProvider = FutureProvider.family<SearchResponse, String>((
  ref,
  query,
) async {
  if (query.isEmpty) return const SearchResponse();

  final youtube = ref.watch(youtubeProvider);
  return youtube.search(query);
});

/// Search suggestions provider
final searchSuggestionsProvider = FutureProvider.family<List<String>, String>((
  ref,
  query,
) async {
  if (query.isEmpty) return [];

  final youtube = ref.watch(youtubeProvider);
  return youtube.getSuggestions(query);
});

/// Search history (persisted locally)
final searchHistoryProvider =
    StateNotifierProvider<SearchHistoryNotifier, List<String>>(
      (ref) => SearchHistoryNotifier(),
    );

/// Notifier for search history
class SearchHistoryNotifier extends StateNotifier<List<String>> {
  SearchHistoryNotifier() : super([]);

  /// Add a search term to history
  void add(String term) {
    // Remove if already exists (to move to top)
    state = state.where((t) => t != term).toList();
    // Add to beginning
    state = [term, ...state];
    // Keep only last 20
    if (state.length > 20) {
      state = state.sublist(0, 20);
    }
    // TODO: Persist to SharedPreferences
  }

  /// Remove a term from history
  void remove(String term) {
    state = state.where((t) => t != term).toList();
  }

  /// Clear all history
  void clear() {
    state = [];
  }
}
