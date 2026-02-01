// ============================================================================
// Artist Entity - Cached artist info
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:isar/isar.dart';

part 'artist_entity.g.dart';

@collection
class ArtistEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String artistId;

  late String name;
  String? thumbnailUrl;
  String? description;
  int? subscriberCount;

  /// Is this artist followed/subscribed
  bool isFollowed = false;

  DateTime? cachedAt;
}
