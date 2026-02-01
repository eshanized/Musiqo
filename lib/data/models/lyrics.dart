// ============================================================================
// Lyrics Model - Synced and unsynced lyrics
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

/// Represents lyrics for a song, either synced or plain text.
class Lyrics {
  /// The song ID these lyrics belong to
  final String songId;
  
  /// Synced lines with timestamps (null if unsynced)
  final List<LyricLine>? syncedLines;
  
  /// Plain text lyrics (fallback when synced not available)
  final String? plainText;
  
  /// Where did we get these lyrics from?
  final LyricsSource source;

  const Lyrics({
    required this.songId,
    this.syncedLines,
    this.plainText,
    this.source = LyricsSource.unknown,
  });

  /// Do we have synced lyrics?
  bool get isSynced => syncedLines != null && syncedLines!.isNotEmpty;

  /// Get the current line index for a given position
  /// 
  /// HOW SYNCED LYRICS WORK:
  /// Each line has a start time. We find the last line whose
  /// start time is <= current playback position.
  int getCurrentLineIndex(Duration position) {
    if (!isSynced) return -1;
    
    for (int i = syncedLines!.length - 1; i >= 0; i--) {
      if (syncedLines![i].startTime <= position) {
        return i;
      }
    }
    return 0;
  }

  factory Lyrics.fromJson(Map<String, dynamic> json) {
    return Lyrics(
      songId: json['songId'] as String,
      syncedLines: (json['syncedLines'] as List<dynamic>?)
          ?.map((l) => LyricLine.fromJson(l as Map<String, dynamic>))
          .toList(),
      plainText: json['plainText'] as String?,
      source: LyricsSource.values.firstWhere(
        (s) => s.name == json['source'],
        orElse: () => LyricsSource.unknown,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'songId': songId,
        'syncedLines': syncedLines?.map((l) => l.toJson()).toList(),
        'plainText': plainText,
        'source': source.name,
      };
}

/// A single line of synced lyrics
class LyricLine {
  /// When this line starts playing
  final Duration startTime;
  
  /// The actual lyrics text
  final String text;

  const LyricLine({
    required this.startTime,
    required this.text,
  });

  factory LyricLine.fromJson(Map<String, dynamic> json) {
    return LyricLine(
      startTime: Duration(milliseconds: json['startTime'] as int),
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'startTime': startTime.inMilliseconds,
        'text': text,
      };
}

/// Where did the lyrics come from
enum LyricsSource {
  youtube,   // From YouTube captions/subtitles
  lrclib,    // From LRCLIB API
  kugou,     // From KuGou
  local,     // User-added
  unknown,
}
