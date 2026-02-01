// ============================================================================
// Song Repository - Data layer for songs
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
//
// Repositories abstract data sources (API, database) from the rest of app.
// ============================================================================

import 'package:isar/isar.dart';

import '../database/database_service.dart';
import '../database/collections/song_entity.dart';
import '../models/song.dart';
import '../mappers/song_mapper.dart';

/// Repository for song-related data operations.
class SongRepository {
  Isar get _db => DatabaseService.instance;

  /// Get all liked songs
  Future<List<Song>> getLikedSongs() async {
    final entities = await _db.songEntitys
        .filter()
        .isLikedEqualTo(true)
        .sortByAddedAtDesc()
        .findAll();

    return entities.map(SongMapper.fromEntity).toList();
  }

  /// Check if song is liked
  Future<bool> isLiked(String videoId) async {
    final entity = await _db.songEntitys
        .filter()
        .videoIdEqualTo(videoId)
        .findFirst();

    return entity?.isLiked ?? false;
  }

  /// Toggle like status
  Future<void> toggleLike(Song song) async {
    await _db.writeTxn(() async {
      var entity = await _db.songEntitys
          .filter()
          .videoIdEqualTo(song.id)
          .findFirst();

      if (entity != null) {
        entity.isLiked = !entity.isLiked;
      } else {
        entity = SongMapper.toEntity(song);
        entity.isLiked = true;
        entity.addedAt = DateTime.now();
      }

      await _db.songEntitys.put(entity);
    });
  }

  /// Record a play
  Future<void> recordPlay(Song song) async {
    await _db.writeTxn(() async {
      var entity = await _db.songEntitys
          .filter()
          .videoIdEqualTo(song.id)
          .findFirst();

      if (entity != null) {
        entity.playCount++;
        entity.playedAt = DateTime.now();
      } else {
        entity = SongMapper.toEntity(song);
        entity.playCount = 1;
        entity.playedAt = DateTime.now();
      }

      await _db.songEntitys.put(entity);
    });
  }

  /// Get recently played songs
  Future<List<Song>> getRecentlyPlayed({int limit = 20}) async {
    final entities = await _db.songEntitys
        .filter()
        .playedAtIsNotNull()
        .sortByPlayedAtDesc()
        .limit(limit)
        .findAll();

    return entities.map(SongMapper.fromEntity).toList();
  }

  /// Get most played songs
  Future<List<Song>> getMostPlayed({int limit = 20}) async {
    final entities = await _db.songEntitys
        .filter()
        .playCountGreaterThan(0)
        .sortByPlayCountDesc()
        .limit(limit)
        .findAll();

    return entities.map(SongMapper.fromEntity).toList();
  }
}
