// ============================================================================
// History Repository - Play history data
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:isar/isar.dart';

import '../database/database_service.dart';
import '../database/collections/history_entity.dart';
import '../models/song.dart';

/// Repository for play history.
class HistoryRepository {
  Isar get _db => DatabaseService.instance;

  /// Add to history
  Future<void> addToHistory(Song song) async {
    final entity = HistoryEntity()
      ..songId = song.id
      ..title = song.title
      ..artistName = song.artistName
      ..thumbnailUrl = song.thumbnailUrl
      ..playedAt = DateTime.now();

    await _db.writeTxn(() async {
      await _db.historyEntitys.put(entity);
    });
  }

  /// Get play history
  Future<List<HistoryItem>> getHistory({int limit = 100}) async {
    final entities = await _db.historyEntitys
        .where()
        .sortByPlayedAtDesc()
        .limit(limit)
        .findAll();

    return entities
        .map(
          (e) => HistoryItem(
            songId: e.songId,
            title: e.title,
            artistName: e.artistName,
            thumbnailUrl: e.thumbnailUrl,
            playedAt: e.playedAt,
          ),
        )
        .toList();
  }

  /// Clear history
  Future<void> clearHistory() async {
    await _db.writeTxn(() async {
      await _db.historyEntitys.clear();
    });
  }

  /// Remove single item
  Future<void> removeFromHistory(int id) async {
    await _db.writeTxn(() async {
      await _db.historyEntitys.delete(id);
    });
  }
}

/// History item DTO
class HistoryItem {
  final String songId;
  final String title;
  final String artistName;
  final String? thumbnailUrl;
  final DateTime playedAt;

  HistoryItem({
    required this.songId,
    required this.title,
    required this.artistName,
    this.thumbnailUrl,
    required this.playedAt,
  });
}
