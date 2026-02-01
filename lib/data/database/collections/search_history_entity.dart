// ============================================================================
// Search History Entity - Recent searches
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:isar/isar.dart';

part 'search_history_entity.g.dart';

@collection
class SearchHistoryEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String query;

  DateTime searchedAt = DateTime.now();
}
