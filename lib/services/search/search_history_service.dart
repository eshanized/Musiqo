// ============================================================================
// Search History Service - Manage search history
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:isar/isar.dart';

import '../../data/database/database_service.dart';
import '../../data/database/collections/search_history_entity.dart';

/// Service for managing search history.
class SearchHistoryService {
  Isar get _db => DatabaseService.instance;

  /// Get search history
  Future<List<String>> getHistory({int limit = 10}) async {
    final entities = await _db.searchHistoryEntitys
        .where()
        .sortBySearchedAtDesc()
        .limit(limit)
        .findAll();

    return entities.map((e) => e.query).toList();
  }

  /// Add to history
  Future<void> addToHistory(String query) async {
    if (query.trim().isEmpty) return;

    await _db.writeTxn(() async {
      // Remove existing if present (to update position)
      await _db.searchHistoryEntitys
          .filter()
          .queryEqualTo(query.trim())
          .deleteFirst();

      // Add new entry
      final entity = SearchHistoryEntity()
        ..query = query.trim()
        ..searchedAt = DateTime.now();

      await _db.searchHistoryEntitys.put(entity);
    });
  }

  /// Remove from history
  Future<void> removeFromHistory(String query) async {
    await _db.writeTxn(() async {
      await _db.searchHistoryEntitys.filter().queryEqualTo(query).deleteFirst();
    });
  }

  /// Clear all history
  Future<void> clearHistory() async {
    await _db.writeTxn(() async {
      await _db.searchHistoryEntitys.clear();
    });
  }
}
