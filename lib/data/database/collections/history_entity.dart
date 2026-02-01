// ============================================================================
// History Entity - Play history tracking
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:isar/isar.dart';

part 'history_entity.g.dart';

@collection
class HistoryEntity {
  Id id = Isar.autoIncrement;

  late String songId;
  late String title;
  late String artistName;
  String? thumbnailUrl;

  DateTime playedAt = DateTime.now();
}
