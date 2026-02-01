// ============================================================================
// Playlist Repository - CRUD operations for user playlists
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/song.dart';
import '../models/playlist.dart';
import '../../core/utils/logger.dart';

/// Repository for managing user-created playlists using SharedPreferences
class PlaylistRepository {
  static const String _playlistsKey = 'user_playlists';
  
  final _playlistsController = StreamController<List<Playlist>>.broadcast();
  Stream<List<Playlist>> get playlistsStream => _playlistsController.stream;
  
  List<Playlist> _cachedPlaylists = [];

  PlaylistRepository() {
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final playlistsJson = prefs.getStringList(_playlistsKey) ?? [];
    
    _cachedPlaylists = playlistsJson.map((json) {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return Playlist.fromJson(map);
    }).toList();
    
    _playlistsController.add(_cachedPlaylists);
    Log.info('Loaded ${_cachedPlaylists.length} playlists', tag: 'Playlist');
  }

  Future<void> _savePlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final playlistsJson = _cachedPlaylists.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_playlistsKey, playlistsJson);
    _playlistsController.add(_cachedPlaylists);
  }

  /// Get all playlists
  Future<List<Playlist>> getAllPlaylists() async {
    if (_cachedPlaylists.isEmpty) {
      await _loadPlaylists();
    }
    return _cachedPlaylists;
  }

  /// Get playlist by ID
  Future<Playlist?> getPlaylist(String id) async {
    final playlists = await getAllPlaylists();
    try {
      return playlists.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Create a new playlist
  Future<Playlist> createPlaylist({
    required String name,
    String? description,
    String? thumbnailUrl,
  }) async {
    final playlist = Playlist(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      thumbnailUrl: thumbnailUrl,
      songs: [],
      isLocal: true,
      createdAt: DateTime.now(),
    );
    
    _cachedPlaylists.insert(0, playlist);
    await _savePlaylists();
    
    Log.info('Created playlist: ${playlist.name}', tag: 'Playlist');
    return playlist;
  }

  /// Update playlist details
  Future<void> updatePlaylist(Playlist playlist) async {
    final index = _cachedPlaylists.indexWhere((p) => p.id == playlist.id);
    if (index >= 0) {
      _cachedPlaylists[index] = playlist;
      await _savePlaylists();
      Log.info('Updated playlist: ${playlist.name}', tag: 'Playlist');
    }
  }

  /// Delete a playlist
  Future<void> deletePlaylist(String id) async {
    _cachedPlaylists.removeWhere((p) => p.id == id);
    await _savePlaylists();
    Log.info('Deleted playlist: $id', tag: 'Playlist');
  }

  /// Add song to playlist
  Future<void> addSongToPlaylist(String playlistId, Song song) async {
    final playlist = await getPlaylist(playlistId);
    if (playlist != null) {
      // Check if song already exists
      if (!playlist.songs.any((s) => s.id == song.id)) {
        final updatedSongs = [...playlist.songs, song];
        final updatedPlaylist = playlist.copyWith(
          songs: updatedSongs,
          thumbnailUrl: playlist.thumbnailUrl ?? song.thumbnailUrl,
        );
        await updatePlaylist(updatedPlaylist);
        Log.info('Added ${song.title} to ${playlist.name}', tag: 'Playlist');
      }
    }
  }

  /// Remove song from playlist
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final playlist = await getPlaylist(playlistId);
    if (playlist != null) {
      final updatedSongs = playlist.songs.where((s) => s.id != songId).toList();
      final updatedPlaylist = playlist.copyWith(songs: updatedSongs);
      await updatePlaylist(updatedPlaylist);
      Log.info('Removed song from ${playlist.name}', tag: 'Playlist');
    }
  }

  /// Reorder songs in playlist
  Future<void> reorderSongs(String playlistId, int oldIndex, int newIndex) async {
    final playlist = await getPlaylist(playlistId);
    if (playlist != null) {
      final songs = List<Song>.from(playlist.songs);
      final song = songs.removeAt(oldIndex);
      songs.insert(newIndex, song);
      final updatedPlaylist = playlist.copyWith(songs: songs);
      await updatePlaylist(updatedPlaylist);
    }
  }

  void dispose() {
    _playlistsController.close();
  }
}
