// ============================================================================
// Play Count Entity - Track song play statistics
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
//
// Tracks how many times songs are played, with monthly granularity
// for "Wrapped" style statistics and Quick Picks recommendations.
// ============================================================================

import 'package:isar/isar.dart';

part 'play_count_entity.g.dart';

/// Entity for tracking song play counts with monthly granularity.
///
/// This allows for:
/// - Lifetime play count per song
/// - Monthly play statistics (for "Wrapped" feature)
/// - Quick Picks recommendations based on listening history
@collection
class PlayCountEntity {
  Id id = Isar.autoIncrement;

  /// Song ID (YouTube video ID)
  @Index()
  late String songId;

  /// Song title (for display without additional lookup)
  late String title;

  /// Artist name
  late String artistName;

  /// Thumbnail URL
  String? thumbnailUrl;

  /// Year of the play count record
  @Index()
  int year = 0;

  /// Month of the play count record (1-12)
  int month = 0;

  /// Number of times played in this month
  int playCount = 0;

  /// Last time this song was played
  DateTime lastPlayed = DateTime.now();

  /// Composite index for efficient queries by song and period
  @Index(composite: [CompositeIndex('year'), CompositeIndex('month')])
  String get songPeriodIndex => songId;
}
