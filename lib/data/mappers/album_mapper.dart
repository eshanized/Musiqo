// ============================================================================
// Album Mapper
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import '../database/collections/album_entity.dart';
import '../models/song.dart';

/// Mapper for Album <-> AlbumEntity conversion.
class AlbumMapper {
  /// Convert entity to domain model
  static Album fromEntity(AlbumEntity entity) {
    return Album(
      id: entity.albumId,
      name: entity.name,
      thumbnailUrl: entity.thumbnailUrl,
    );
  }

  /// Convert domain model to entity
  static AlbumEntity toEntity(Album album) {
    return AlbumEntity()
      ..albumId = album.id
      ..name = album.name
      ..thumbnailUrl = album.thumbnailUrl;
  }
}
