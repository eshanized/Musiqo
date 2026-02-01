// ============================================================================
// Lyrics Entity - Cached lyrics
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:isar/isar.dart';

part 'lyrics_entity.g.dart';

@collection
class LyricsEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String songId;

  /// Synced lyrics in LRC format
  String? syncedLrc;

  /// Plain text lyrics
  String? plainText;

  /// Source of lyrics
  String source = 'unknown';

  DateTime cachedAt = DateTime.now();
}
