// ============================================================================
// Playlist Provider - State management for playlists
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/playlist.dart';
import '../../data/models/song.dart';
import '../../data/repositories/playlist_repository.dart';

/// Repository provider
final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  return PlaylistRepository();
});

/// All playlists provider
final playlistsProvider = FutureProvider<List<Playlist>>((ref) async {
  final repo = ref.watch(playlistRepositoryProvider);
  return repo.getAllPlaylists();
});

/// Stream of playlists for reactive updates
final playlistsStreamProvider = StreamProvider<List<Playlist>>((ref) {
  final repo = ref.watch(playlistRepositoryProvider);
  return repo.playlistsStream;
});

/// Single playlist by ID
final playlistProvider = FutureProvider.family<Playlist?, String>((ref, id) async {
  final repo = ref.watch(playlistRepositoryProvider);
  return repo.getPlaylist(id);
});

/// Playlist actions notifier
class PlaylistActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final PlaylistRepository _repo;
  final Ref _ref;

  PlaylistActionsNotifier(this._repo, this._ref) : super(const AsyncValue.data(null));

  Future<Playlist> createPlaylist(String name, {String? description}) async {
    state = const AsyncValue.loading();
    try {
      final playlist = await _repo.createPlaylist(name: name, description: description);
      _ref.invalidate(playlistsProvider);
      state = const AsyncValue.data(null);
      return playlist;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deletePlaylist(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repo.deletePlaylist(id);
      _ref.invalidate(playlistsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addSongToPlaylist(String playlistId, Song song) async {
    await _repo.addSongToPlaylist(playlistId, song);
    _ref.invalidate(playlistsProvider);
    _ref.invalidate(playlistProvider(playlistId));
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    await _repo.removeSongFromPlaylist(playlistId, songId);
    _ref.invalidate(playlistProvider(playlistId));
  }

  Future<void> updatePlaylist(Playlist playlist) async {
    await _repo.updatePlaylist(playlist);
    _ref.invalidate(playlistsProvider);
    _ref.invalidate(playlistProvider(playlist.id));
  }
}

final playlistActionsProvider = StateNotifierProvider<PlaylistActionsNotifier, AsyncValue<void>>((ref) {
  final repo = ref.watch(playlistRepositoryProvider);
  return PlaylistActionsNotifier(repo, ref);
});
