// ============================================================================
// Song Mapper - Convert between Song and SongEntity
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import '../models/song.dart';
import '../database/collections/song_entity.dart';

/// Mapper for Song <-> SongEntity conversion.
///
/// WHY MAPPERS?
/// Domain models (Song) and database entities (SongEntity) are separate.
/// Mappers translate between them. This keeps our code clean and flexible.
class SongMapper {
  /// Convert entity to domain model
  static Song fromEntity(SongEntity entity) {
    return Song(
      id: entity.videoId,
      title: entity.title,
      artists: [Artist(id: '', name: entity.artistName)],
      album: entity.albumId != null
          ? Album(id: entity.albumId!, name: entity.albumName ?? '')
          : null,
      duration: Duration(seconds: entity.durationSeconds),
      thumbnailUrl: entity.thumbnailUrl,
      isExplicit: entity.isExplicit,
    );
  }

  /// Convert domain model to entity
  static SongEntity toEntity(Song song) {
    return SongEntity()
      ..videoId = song.id
      ..title = song.title
      ..artistName = song.artistName
      ..albumName = song.album?.name
      ..albumId = song.album?.id
      ..durationSeconds = song.duration.inSeconds
      ..thumbnailUrl = song.thumbnailUrl
      ..isExplicit = song.isExplicit;
  }
}
