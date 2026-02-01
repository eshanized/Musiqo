// ============================================================================
// Playlist Mapper - Convert between Playlist and PlaylistEntity
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import '../models/playlist.dart';
import '../database/collections/playlist_entity.dart';

/// Mapper for Playlist <-> PlaylistEntity conversion.
class PlaylistMapper {
  /// Convert entity to domain model
  static Playlist fromEntity(PlaylistEntity entity) {
    return Playlist(
      id: entity.playlistId,
      name: entity.name,
      description: entity.description,
      thumbnailUrl: entity.thumbnailUrl,
      isLocal: entity.isLocal,
      author: entity.author,
      songs: const [], // Songs loaded separately
      createdAt: entity.createdAt,
    );
  }

  /// Convert domain model to entity
  static PlaylistEntity toEntity(Playlist playlist) {
    return PlaylistEntity()
      ..playlistId = playlist.id
      ..name = playlist.name
      ..description = playlist.description
      ..thumbnailUrl = playlist.thumbnailUrl
      ..isLocal = playlist.isLocal
      ..author = playlist.author
      ..createdAt = playlist.createdAt;
  }
}
