// ============================================================================
// Album Entity - Cached album info
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:isar/isar.dart';

part 'album_entity.g.dart';

@collection
class AlbumEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String albumId;

  late String name;
  String? artistName;
  String? artistId;
  String? thumbnailUrl;
  int? year;
  int? trackCount;

  /// Song IDs in this album
  List<String> songIds = [];

  DateTime? cachedAt;
}
