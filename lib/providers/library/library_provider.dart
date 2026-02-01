// ============================================================================
// Library Providers - State for history, favorites, playlists
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/song.dart';
import '../../data/repositories/history_repository.dart';
import '../../data/repositories/favorites_repository.dart';

// ============================================================================
// Repository Providers
// ============================================================================

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository();
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository();
});

// ============================================================================
// History Providers
// ============================================================================

/// Recent play history
final recentHistoryProvider = FutureProvider<List<Song>>((ref) async {
  final repo = ref.watch(historyRepositoryProvider);
  return repo.getRecentHistory(limit: 50);
});

/// Add song to history (call when song starts playing)
Future<void> addToHistory(WidgetRef ref, Song song) async {
  final repo = ref.read(historyRepositoryProvider);
  await repo.addToHistory(song);
  ref.invalidate(recentHistoryProvider);
}

// ============================================================================
// Favorites Providers
// ============================================================================

/// All liked songs
final likedSongsProvider = FutureProvider<List<Song>>((ref) async {
  final repo = ref.watch(favoritesRepositoryProvider);
  return repo.getLikedSongs();
});

/// Liked songs count
final likedCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(favoritesRepositoryProvider);
  return repo.getLikedCount();
});

/// Check if specific song is liked
final isLikedProvider = FutureProvider.family<bool, String>((ref, videoId) async {
  final repo = ref.watch(favoritesRepositoryProvider);
  return repo.isLiked(videoId);
});

/// Toggle like status and refresh providers
Future<bool> toggleLike(WidgetRef ref, Song song) async {
  final repo = ref.read(favoritesRepositoryProvider);
  final isNowLiked = await repo.toggleLike(song);
  
  // Refresh providers
  ref.invalidate(likedSongsProvider);
  ref.invalidate(likedCountProvider);
  ref.invalidate(isLikedProvider(song.id));
  
  return isNowLiked;
}

/// Like a song and refresh providers
Future<void> likeSong(WidgetRef ref, Song song) async {
  final repo = ref.read(favoritesRepositoryProvider);
  await repo.like(song);
  
  ref.invalidate(likedSongsProvider);
  ref.invalidate(likedCountProvider);
  ref.invalidate(isLikedProvider(song.id));
}

/// Unlike a song and refresh providers
Future<void> unlikeSong(WidgetRef ref, String videoId) async {
  final repo = ref.read(favoritesRepositoryProvider);
  await repo.unlike(videoId);
  
  ref.invalidate(likedSongsProvider);
  ref.invalidate(likedCountProvider);
  ref.invalidate(isLikedProvider(videoId));
}
