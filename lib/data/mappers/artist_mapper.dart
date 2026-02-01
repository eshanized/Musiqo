// ============================================================================
// Artist Mapper
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import '../database/collections/artist_entity.dart';
import '../models/song.dart';

/// Mapper for Artist <-> ArtistEntity conversion.
class ArtistMapper {
  /// Convert entity to domain model
  static Artist fromEntity(ArtistEntity entity) {
    return Artist(
      id: entity.artistId,
      name: entity.name,
      thumbnailUrl: entity.thumbnailUrl,
    );
  }

  /// Convert domain model to entity
  static ArtistEntity toEntity(Artist artist) {
    return ArtistEntity()
      ..artistId = artist.id
      ..name = artist.name
      ..thumbnailUrl = artist.thumbnailUrl;
  }
}
