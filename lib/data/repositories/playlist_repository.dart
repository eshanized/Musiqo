// ============================================================================
// Playlist Repository - Data layer for playlists
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:isar/isar.dart';

import '../database/database_service.dart';
import '../database/collections/playlist_entity.dart';
import '../models/playlist.dart';
import '../mappers/playlist_mapper.dart';

/// Repository for playlist operations.
class PlaylistRepository {
  Isar get _db => DatabaseService.instance;

  /// Get all local playlists
  Future<List<Playlist>> getLocalPlaylists() async {
    final entities = await _db.playlistEntitys
        .filter()
        .isLocalEqualTo(true)
        .sortByCreatedAtDesc()
        .findAll();

    return entities.map(PlaylistMapper.fromEntity).toList();
  }

  /// Create a new playlist
  Future<Playlist> create(String name, {String? description}) async {
    final entity = PlaylistEntity()
      ..playlistId = DateTime.now().millisecondsSinceEpoch.toString()
      ..name = name
      ..description = description
      ..isLocal = true
      ..createdAt = DateTime.now();

    await _db.writeTxn(() async {
      await _db.playlistEntitys.put(entity);
    });

    return PlaylistMapper.fromEntity(entity);
  }

  /// Add song to playlist
  Future<void> addSong(String playlistId, String songId) async {
    await _db.writeTxn(() async {
      final entity = await _db.playlistEntitys
          .filter()
          .playlistIdEqualTo(playlistId)
          .findFirst();

      if (entity != null && !entity.songIds.contains(songId)) {
        entity.songIds = [...entity.songIds, songId];
        entity.updatedAt = DateTime.now();
        await _db.playlistEntitys.put(entity);
      }
    });
  }

  /// Remove song from playlist
  Future<void> removeSong(String playlistId, String songId) async {
    await _db.writeTxn(() async {
      final entity = await _db.playlistEntitys
          .filter()
          .playlistIdEqualTo(playlistId)
          .findFirst();

      if (entity != null) {
        entity.songIds = entity.songIds.where((id) => id != songId).toList();
        entity.updatedAt = DateTime.now();
        await _db.playlistEntitys.put(entity);
      }
    });
  }

  /// Delete playlist
  Future<void> delete(String playlistId) async {
    await _db.writeTxn(() async {
      await _db.playlistEntitys
          .filter()
          .playlistIdEqualTo(playlistId)
          .deleteFirst();
    });
  }

  /// Rename playlist
  Future<void> rename(String playlistId, String newName) async {
    await _db.writeTxn(() async {
      final entity = await _db.playlistEntitys
          .filter()
          .playlistIdEqualTo(playlistId)
          .findFirst();

      if (entity != null) {
        entity.name = newName;
        entity.updatedAt = DateTime.now();
        await _db.playlistEntitys.put(entity);
      }
    });
  }
}
