// ============================================================================
// Artist Repository
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:isar/isar.dart';

import '../database/database_service.dart';
import '../database/collections/artist_entity.dart';

/// Repository for artist data.
class ArtistRepository {
  Isar get _db => DatabaseService.instance;

  /// Get followed artists
  Future<List<ArtistEntity>> getFollowedArtists() async {
    return _db.artistEntitys
        .filter()
        .isFollowedEqualTo(true)
        .sortByName()
        .findAll();
  }

  /// Check if artist is followed
  Future<bool> isFollowed(String artistId) async {
    final entity = await _db.artistEntitys
        .filter()
        .artistIdEqualTo(artistId)
        .findFirst();
    return entity?.isFollowed ?? false;
  }

  /// Toggle follow status
  Future<void> toggleFollow(
    String artistId, {
    required String name,
    String? thumbnailUrl,
  }) async {
    await _db.writeTxn(() async {
      var entity = await _db.artistEntitys
          .filter()
          .artistIdEqualTo(artistId)
          .findFirst();

      if (entity != null) {
        entity.isFollowed = !entity.isFollowed;
      } else {
        entity = ArtistEntity()
          ..artistId = artistId
          ..name = name
          ..thumbnailUrl = thumbnailUrl
          ..isFollowed = true;
      }

      await _db.artistEntitys.put(entity);
    });
  }
}
