// ============================================================================
// Lyrics Mapper
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import '../database/collections/lyrics_entity.dart';
import '../models/lyrics.dart';

/// Mapper for Lyrics <-> LyricsEntity conversion.
class LyricsMapper {
  /// Convert entity to domain model
  static Lyrics fromEntity(LyricsEntity entity) {
    return Lyrics(
      songId: entity.songId,
      syncedLyrics: entity.syncedLrc,
      plainText: entity.plainText,
      source: _parseSource(entity.source),
    );
  }

  /// Convert domain model to entity
  static LyricsEntity toEntity(Lyrics lyrics) {
    return LyricsEntity()
      ..songId = lyrics.songId
      ..syncedLrc = lyrics.syncedLyrics
      ..plainText = lyrics.plainText
      ..source = lyrics.source.name
      ..cachedAt = DateTime.now();
  }

  static LyricsSource _parseSource(String source) {
    return LyricsSource.values.firstWhere(
      (s) => s.name == source,
      orElse: () => LyricsSource.lrclib,
    );
  }
}
