// ============================================================================
// Favorites Repository - SharedPreferences-based liked songs
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/song.dart';
import '../../core/utils/logger.dart';

/// Repository for managing favorite/liked songs using SharedPreferences
class FavoritesRepository {
  static const _key = 'liked_songs';

  /// Check if song is liked
  Future<bool> isLiked(String videoId) async {
    final prefs = await SharedPreferences.getInstance();
    final songs = await _getLikedSongs(prefs);
    return songs.any((s) => s['id'] == videoId);
  }

  /// Toggle like status for a song
  Future<bool> toggleLike(Song song) async {
    final prefs = await SharedPreferences.getInstance();
    final songs = await _getLikedSongs(prefs);
    
    final existingIndex = songs.indexWhere((s) => s['id'] == song.id);
    
    if (existingIndex >= 0) {
      // Unlike
      songs.removeAt(existingIndex);
      await prefs.setString(_key, jsonEncode(songs));
      Log.info('Unliked: ${song.title}', tag: 'Favorites');
      return false;
    } else {
      // Like
      songs.insert(0, {
        'id': song.id,
        'title': song.title,
        'artistName': song.artistName,
        'thumbnailUrl': song.thumbnailUrl,
        'durationSeconds': song.duration.inSeconds,
        'addedAt': DateTime.now().toIso8601String(),
      });
      await prefs.setString(_key, jsonEncode(songs));
      Log.info('Liked: ${song.title}', tag: 'Favorites');
      return true;
    }
  }

  /// Like a song
  Future<void> like(Song song) async {
    final prefs = await SharedPreferences.getInstance();
    final songs = await _getLikedSongs(prefs);
    
    // Check if already liked
    if (songs.any((s) => s['id'] == song.id)) return;
    
    songs.insert(0, {
      'id': song.id,
      'title': song.title,
      'artistName': song.artistName,
      'thumbnailUrl': song.thumbnailUrl,
      'durationSeconds': song.duration.inSeconds,
      'addedAt': DateTime.now().toIso8601String(),
    });
    
    await prefs.setString(_key, jsonEncode(songs));
    Log.info('Liked: ${song.title}', tag: 'Favorites');
  }

  /// Unlike a song
  Future<void> unlike(String videoId) async {
    final prefs = await SharedPreferences.getInstance();
    final songs = await _getLikedSongs(prefs);
    
    songs.removeWhere((s) => s['id'] == videoId);
    await prefs.setString(_key, jsonEncode(songs));
  }

  /// Get all liked songs
  Future<List<Song>> getLikedSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final songs = await _getLikedSongs(prefs);
    return songs.map(_entryToSong).toList();
  }

  /// Get liked songs count
  Future<int> getLikedCount() async {
    final prefs = await SharedPreferences.getInstance();
    final songs = await _getLikedSongs(prefs);
    return songs.length;
  }

  Future<List<Map<String, dynamic>>> _getLikedSongs(SharedPreferences prefs) async {
    final data = prefs.getString(_key);
    if (data == null) return [];
    
    final list = jsonDecode(data) as List;
    return list.cast<Map<String, dynamic>>();
  }

  Song _entryToSong(Map<String, dynamic> entry) {
    return Song(
      id: entry['id'] as String,
      title: entry['title'] as String,
      artists: [Artist(id: '', name: entry['artistName'] as String)],
      duration: Duration(seconds: (entry['durationSeconds'] as int?) ?? 0),
      thumbnailUrl: entry['thumbnailUrl'] as String?,
    );
  }
}
