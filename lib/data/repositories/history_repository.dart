// ============================================================================
// History Repository - SharedPreferences-based play history
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/song.dart';
import '../../core/utils/logger.dart';

/// Repository for managing play history using SharedPreferences
class HistoryRepository {
  static const _key = 'play_history';
  static const _maxHistorySize = 100;

  /// Add song to history
  Future<void> addToHistory(Song song) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await _getHistory(prefs);
      
      // Create entry
      final entry = {
        'id': song.id,
        'title': song.title,
        'artistName': song.artistName,
        'thumbnailUrl': song.thumbnailUrl,
        'playedAt': DateTime.now().toIso8601String(),
      };
      
      // Add to front of list
      history.insert(0, entry);
      
      // Limit size
      if (history.length > _maxHistorySize) {
        history.removeRange(_maxHistorySize, history.length);
      }
      
      await prefs.setString(_key, jsonEncode(history));
      Log.info('Added to history: ${song.title}', tag: 'History');
    } catch (e) {
      Log.error('Failed to add to history', error: e, tag: 'History');
    }
  }

  /// Get recent play history (deduplicated by song ID)
  Future<List<Song>> getRecentHistory({int limit = 50}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await _getHistory(prefs);
      
      // Deduplicate by song ID (keep most recent)
      final seen = <String>{};
      final unique = <Map<String, dynamic>>[];
      
      for (final entry in history) {
        final id = entry['id'] as String;
        if (!seen.contains(id)) {
          seen.add(id);
          unique.add(entry);
          if (unique.length >= limit) break;
        }
      }
      
      return unique.map(_entryToSong).toList();
    } catch (e) {
      Log.error('Failed to get history', error: e, tag: 'History');
      return [];
    }
  }

  /// Clear all history
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<List<Map<String, dynamic>>> _getHistory(SharedPreferences prefs) async {
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
      duration: Duration.zero,
      thumbnailUrl: entry['thumbnailUrl'] as String?,
    );
  }
}
