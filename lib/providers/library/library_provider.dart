// ============================================================================
// Library Provider - State for user library
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/song.dart';
import '../../data/models/playlist.dart';
import '../../data/repositories/song_repository.dart';
import '../../data/repositories/playlist_repository.dart';

/// Provider for song repository
final songRepositoryProvider = Provider<SongRepository>((ref) {
  return SongRepository();
});

/// Provider for playlist repository
final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  return PlaylistRepository();
});

/// Provider for liked songs
final likedSongsProvider = FutureProvider<List<Song>>((ref) async {
  final repo = ref.watch(songRepositoryProvider);
  return repo.getLikedSongs();
});

/// Provider for recently played
final recentlyPlayedProvider = FutureProvider<List<Song>>((ref) async {
  final repo = ref.watch(songRepositoryProvider);
  return repo.getRecentlyPlayed();
});

/// Provider for most played
final mostPlayedProvider = FutureProvider<List<Song>>((ref) async {
  final repo = ref.watch(songRepositoryProvider);
  return repo.getMostPlayed();
});

/// Provider for local playlists
final localPlaylistsProvider = FutureProvider<List<Playlist>>((ref) async {
  final repo = ref.watch(playlistRepositoryProvider);
  return repo.getLocalPlaylists();
});

/// Check if song is liked
final isLikedProvider = FutureProvider.family<bool, String>((
  ref,
  songId,
) async {
  final repo = ref.watch(songRepositoryProvider);
  return repo.isLiked(songId);
});
