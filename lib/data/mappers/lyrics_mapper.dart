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
    // Parse synced LRC string to LyricLine list if available
    final syncedLines = entity.syncedLrc != null 
        ? _parseLrcToLines(entity.syncedLrc!)
        : null;
    
    return Lyrics(
      songId: entity.songId,
      syncedLines: syncedLines,
      plainText: entity.plainText,
      source: _parseSource(entity.source),
    );
  }

  /// Convert domain model to entity
  static LyricsEntity toEntity(Lyrics lyrics) {
    return LyricsEntity()
      ..songId = lyrics.songId
      ..syncedLrc = lyrics.syncedLines != null 
          ? _linesToLrc(lyrics.syncedLines!)
          : null
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

  /// Parse LRC format string to LyricLine list
  static List<LyricLine>? _parseLrcToLines(String lrc) {
    final lines = <LyricLine>[];
    final regex = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\](.*)');
    
    for (final line in lrc.split('\n')) {
      final match = regex.firstMatch(line);
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final msString = match.group(3)!;
        final ms = int.parse(msString.padRight(3, '0'));
        final text = match.group(4)?.trim() ?? '';
        
        lines.add(LyricLine(
          startTime: Duration(
            minutes: minutes,
            seconds: seconds,
            milliseconds: ms,
          ),
          text: text,
        ));
      }
    }
    
    return lines.isEmpty ? null : lines;
  }

  /// Convert LyricLine list back to LRC format
  static String _linesToLrc(List<LyricLine> lines) {
    return lines.map((line) {
      final minutes = line.startTime.inMinutes.remainder(60).toString().padLeft(2, '0');
      final seconds = line.startTime.inSeconds.remainder(60).toString().padLeft(2, '0');
      final ms = (line.startTime.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
      return '[$minutes:$seconds.$ms]${line.text}';
    }).join('\n');
  }
}
