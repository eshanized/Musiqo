// ============================================================================
// Statistics Repository - Play count and recommendation queries
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
//
// Handles all play count tracking and recommendation queries.
// Similar to OpenTune's DatabaseDao methods for statistics.
// ============================================================================

import 'package:isar/isar.dart';

import '../database/database_service.dart';
import '../database/collections/play_count_entity.dart';
import '../models/song.dart';
import '../../core/utils/logger.dart';

/// Repository for tracking play statistics and generating recommendations.
class StatisticsRepository {
  Isar get _db => DatabaseService.instance;

  // ============================================
  // Play Count Tracking
  // ============================================

  /// Increment play count for a song.
  /// Creates a new record if none exists for the current month.
  Future<void> incrementPlayCount(Song song) async {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    await _db.writeTxn(() async {
      // Find existing record for this song and month
      var existing = await _db.playCountEntitys
          .filter()
          .songIdEqualTo(song.id)
          .yearEqualTo(year)
          .monthEqualTo(month)
          .findFirst();

      if (existing != null) {
        // Update existing record
        existing.playCount++;
        existing.lastPlayed = now;
        await _db.playCountEntitys.put(existing);
      } else {
        // Create new record
        final record = PlayCountEntity()
          ..songId = song.id
          ..title = song.title
          ..artistName = song.artistName
          ..thumbnailUrl = song.thumbnailUrl
          ..year = year
          ..month = month
          ..playCount = 1
          ..lastPlayed = now;
        await _db.playCountEntitys.put(record);
      }
    });

    Log.info('Play count incremented: ${song.title}', tag: 'Statistics');
  }

  /// Get lifetime play count for a song
  Future<int> getLifetimePlayCount(String songId) async {
    final records = await _db.playCountEntitys
        .filter()
        .songIdEqualTo(songId)
        .findAll();

    return records.fold(0, (sum, record) => sum + record.playCount);
  }

  /// Get monthly play count for a song
  Future<int> getMonthlyPlayCount(String songId, int year, int month) async {
    final record = await _db.playCountEntitys
        .filter()
        .songIdEqualTo(songId)
        .yearEqualTo(year)
        .monthEqualTo(month)
        .findFirst();

    return record?.playCount ?? 0;
  }

  // ============================================
  // Recommendations / Quick Picks
  // ============================================

  /// Get most played songs for Quick Picks recommendations.
  /// Returns songs ordered by play count within the specified period.
  Future<List<QuickPickSong>> getMostPlayed({
    int limit = 10,
    Duration period = const Duration(days: 30),
  }) async {
    final cutoff = DateTime.now().subtract(period);
    final cutoffYear = cutoff.year;
    final cutoffMonth = cutoff.month;

    // Get all recent play counts
    final records = await _db.playCountEntitys
        .filter()
        .yearGreaterThan(cutoffYear - 1)
        .sortByPlayCountDesc()
        .limit(limit * 2) // Get extra to filter
        .findAll();

    // Aggregate by song ID
    final songCounts = <String, QuickPickSong>{};
    for (final record in records) {
      if (songCounts.containsKey(record.songId)) {
        songCounts[record.songId]!.totalPlays = songCounts[record.songId]!.totalPlays + record.playCount;
        if (record.lastPlayed.isAfter(songCounts[record.songId]!.lastPlayed)) {
          songCounts[record.songId]!.lastPlayed = record.lastPlayed;
        }
      } else {
        songCounts[record.songId] = QuickPickSong(
          songId: record.songId,
          title: record.title,
          artistName: record.artistName,
          thumbnailUrl: record.thumbnailUrl,
          totalPlays: record.playCount,
          lastPlayed: record.lastPlayed,
        );
      }
    }

    // Sort by play count and take top N
    final sorted = songCounts.values.toList()
      ..sort((a, b) => b.totalPlays.compareTo(a.totalPlays));

    return sorted.take(limit).toList();
  }

  /// Get recently played songs (for "Recently Played" section)
  Future<List<QuickPickSong>> getRecentlyPlayed({int limit = 10}) async {
    final records = await _db.playCountEntitys
        .where()
        .sortByLastPlayedDesc()
        .distinctBySongId()
        .limit(limit)
        .findAll();

    return records.map((r) => QuickPickSong(
      songId: r.songId,
      title: r.title,
      artistName: r.artistName,
      thumbnailUrl: r.thumbnailUrl,
      totalPlays: r.playCount,
      lastPlayed: r.lastPlayed,
    )).toList();
  }

  // ============================================
  // Statistics (for Wrapped feature)
  // ============================================

  /// Get total plays for a year
  Future<int> getYearlyTotalPlays(int year) async {
    final records = await _db.playCountEntitys
        .filter()
        .yearEqualTo(year)
        .findAll();

    return records.fold(0, (sum, r) => sum + r.playCount);
  }

  /// Get monthly stats for a year
  Future<Map<int, int>> getMonthlyStats(int year) async {
    final records = await _db.playCountEntitys
        .filter()
        .yearEqualTo(year)
        .findAll();

    final monthlyTotals = <int, int>{};
    for (final record in records) {
      monthlyTotals[record.month] = 
          (monthlyTotals[record.month] ?? 0) + record.playCount;
    }

    return monthlyTotals;
  }

  /// Get top songs for a year (for Wrapped)
  Future<List<QuickPickSong>> getTopSongsOfYear(int year, {int limit = 10}) async {
    final records = await _db.playCountEntitys
        .filter()
        .yearEqualTo(year)
        .findAll();

    // Aggregate by song
    final songCounts = <String, QuickPickSong>{};
    for (final record in records) {
      if (songCounts.containsKey(record.songId)) {
        songCounts[record.songId]!.totalPlays += record.playCount;
      } else {
        songCounts[record.songId] = QuickPickSong(
          songId: record.songId,
          title: record.title,
          artistName: record.artistName,
          thumbnailUrl: record.thumbnailUrl,
          totalPlays: record.playCount,
          lastPlayed: record.lastPlayed,
        );
      }
    }

    final sorted = songCounts.values.toList()
      ..sort((a, b) => b.totalPlays.compareTo(a.totalPlays));

    return sorted.take(limit).toList();
  }
}

/// Quick pick song data for recommendations
class QuickPickSong {
  final String songId;
  final String title;
  final String artistName;
  final String? thumbnailUrl;
  int totalPlays;
  DateTime lastPlayed;

  QuickPickSong({
    required this.songId,
    required this.title,
    required this.artistName,
    this.thumbnailUrl,
    required this.totalPlays,
    required this.lastPlayed,
  });

  /// Convert to Song model for playback
  Song toSong() => Song(
    id: songId,
    title: title,
    artists: [Artist(id: '', name: artistName)],
    duration: Duration.zero,
    thumbnailUrl: thumbnailUrl,
    playCount: totalPlays,
  );
}
