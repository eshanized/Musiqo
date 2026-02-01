// ============================================================================
// Download Repository - Track downloaded songs
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/song.dart';

/// Manages metadata of downloaded songs using SharedPreferences
class DownloadRepository {
  static const String _downloadsKey = 'downloaded_songs';
  
  Future<List<Song>> getDownloadedSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> downloads = prefs.getStringList(_downloadsKey) ?? [];
    
    return downloads.map((json) {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return Song.fromJson(map);
    }).toList();
  }

  Future<void> addDownloadedSong(Song song, String localPath) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> downloads = prefs.getStringList(_downloadsKey) ?? [];

    // Remove if already exists to update
    downloads.removeWhere((json) {
       final map = jsonDecode(json) as Map<String, dynamic>;
       return map['id'] == song.id;
    });

    // Determine the actual path field. 
    // Assuming the Song entity plays from `streamUrl` usually, 
    // but for offline we want to use the local file.
    // Ideally Song model has a `localPath` field. 
    // If not, we might reuse `streamUrl` or add `localPath` to the json.
    // For now, let's inject a 'localPath' property into the JSON map 
    // if the Song model doesn't support it directly, or rely on Song having it.
    
    // Let's assume we store the song object AS IS, but we need to know it's downloaded.
    // A better approach: store song with isLocal or localPath set.
    
    // We'll create a copy of the song map and add/update fields
    final songMap = song.toJson();
    songMap['localPath'] = localPath; 
    
    downloads.add(jsonEncode(songMap));
    await prefs.setStringList(_downloadsKey, downloads);
  }

  Future<void> removeDownloadedSong(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> downloads = prefs.getStringList(_downloadsKey) ?? [];
    
    downloads.removeWhere((json) {
       final map = jsonDecode(json) as Map<String, dynamic>;
       return map['id'] == id;
    });
    
    await prefs.setStringList(_downloadsKey, downloads);
  }

  Future<bool> isDownloaded(String id) async {
    final songs = await getDownloadedSongs();
    return songs.any((s) => s.id == id);
  }
}
