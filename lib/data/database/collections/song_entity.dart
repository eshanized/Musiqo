// ============================================================================
// Song Entity - Isar database collection for songs
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
//
// This is a database "entity" - it defines how songs are stored locally.
// Isar is a super-fast NoSQL database for Flutter.
// ============================================================================

import 'package:isar/isar.dart';

part 'song_entity.g.dart';

/// Song entity for Isar database.
///
/// WHY ISAR?
/// - No SQL knowledge needed
/// - Type-safe queries
/// - Crazy fast performance
/// - Works offline perfectly
@collection
class SongEntity {
  Id id = Isar.autoIncrement;

  /// YouTube video ID
  @Index(unique: true)
  late String videoId;

  late String title;
  late String artistName;
  String? albumName;
  String? albumId;

  /// Duration in seconds
  int durationSeconds = 0;

  String? thumbnailUrl;
  String? thumbnailMaxRes;

  bool isExplicit = false;

  /// Local file path if downloaded
  String? localPath;

  /// When was this song added to library
  DateTime? addedAt;

  /// Last played timestamp
  DateTime? playedAt;

  /// Play count for stats
  int playCount = 0;

  /// Is this song liked/favorited
  bool isLiked = false;
}
