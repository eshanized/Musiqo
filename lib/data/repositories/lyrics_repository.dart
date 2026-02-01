// ============================================================================
// Lyrics Repository
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:isar/isar.dart';

import '../database/database_service.dart';
import '../database/collections/lyrics_entity.dart';
import '../models/lyrics.dart';
import '../mappers/lyrics_mapper.dart';

/// Repository for lyrics caching.
class LyricsRepository {
  Isar get _db => DatabaseService.instance;

  /// Get cached lyrics
  Future<Lyrics?> getCachedLyrics(String songId) async {
    final entity = await _db.lyricsEntitys
        .filter()
        .songIdEqualTo(songId)
        .findFirst();

    return entity != null ? LyricsMapper.fromEntity(entity) : null;
  }

  /// Cache lyrics
  Future<void> cacheLyrics(Lyrics lyrics) async {
    await _db.writeTxn(() async {
      // Remove existing
      await _db.lyricsEntitys
          .filter()
          .songIdEqualTo(lyrics.songId)
          .deleteFirst();

      // Add new
      await _db.lyricsEntitys.put(LyricsMapper.toEntity(lyrics));
    });
  }

  /// Clear all cached lyrics
  Future<void> clearCache() async {
    await _db.writeTxn(() async {
      await _db.lyricsEntitys.clear();
    });
  }
}
