// ============================================================================
// Database Service - Isar initialization and management
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'collections/song_entity.dart';
import 'collections/playlist_entity.dart';
import 'collections/artist_entity.dart';
import 'collections/album_entity.dart';
import 'collections/lyrics_entity.dart';
import 'collections/history_entity.dart';
import 'collections/download_entity.dart';
import 'collections/search_history_entity.dart';

/// Database service for initializing and accessing Isar.
class DatabaseService {
  static Isar? _instance;

  /// Get the database instance
  static Isar get instance {
    if (_instance == null) {
      throw Exception('Database not initialized! Call init() first.');
    }
    return _instance!;
  }

  /// Initialize the database
  ///
  /// Call this once at app startup (in main.dart).
  static Future<void> init() async {
    if (_instance != null) return;

    final dir = await getApplicationDocumentsDirectory();

    _instance = await Isar.open(
      [
        SongEntitySchema,
        PlaylistEntitySchema,
        ArtistEntitySchema,
        AlbumEntitySchema,
        LyricsEntitySchema,
        HistoryEntitySchema,
        DownloadEntitySchema,
        SearchHistoryEntitySchema,
      ],
      directory: dir.path,
      name: 'musiqo',
    );
  }

  /// Close database connection
  static Future<void> close() async {
    await _instance?.close();
    _instance = null;
  }

  /// Clear all data
  static Future<void> clearAll() async {
    await _instance?.writeTxn(() async {
      await _instance?.clear();
    });
  }
}
