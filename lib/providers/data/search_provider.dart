// ============================================================================
// Search Provider - State management for search
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const _key = 'search_history';

  SearchHistoryNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getStringList(_key) ?? [];
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, state);
  }

  /// Add a search term to history
  void add(String term) {
    if (term.trim().isEmpty) return;
    // Remove if already exists (to move to top)
    state = state.where((t) => t != term).toList();
    // Add to beginning
    state = [term, ...state];
    // Keep only last 20
    if (state.length > 20) {
      state = state.sublist(0, 20);
    }
    _save();
  }

  /// Remove a term from history
  void remove(String term) {
    state = state.where((t) => t != term).toList();
    _save();
  }

  /// Clear all history
  void clear() {
    state = [];
    _save();
  }
}
