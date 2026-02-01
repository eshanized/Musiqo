// ============================================================================
// Lyrics Service - Fetch synced and plain lyrics
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
//
// This service fetches lyrics from multiple sources:
// 1. LRCLIB - Free synced lyrics API
// 2. YouTube captions (fallback)
// ============================================================================

import 'package:dio/dio.dart';

import '../../data/models/lyrics.dart';
import '../../core/utils/logger.dart';

/// Service for fetching song lyrics from various sources.
class LyricsService {
  final Dio _dio;

  LyricsService() : _dio = Dio();

  /// Get lyrics for a song, trying multiple sources.
  ///
  /// STRATEGY:
  /// 1. Try LRCLIB first (best synced lyrics)
  /// 2. Fall back to other sources if needed
  /// 3. Return null if nothing found
  Future<Lyrics?> getLyrics({
    required String title,
    required String artist,
    Duration? duration,
  }) async {
    // Try LRCLIB first - they have great synced lyrics
    final lrclib = await _tryLrclib(title, artist, duration);
    if (lrclib != null) return lrclib;

    // TODO: Add more lyrics sources here
    // - KuGou (Chinese music)
    // - YouTube captions
    // - Genius (plain text only)

    return null;
  }

  /// Try to get lyrics from LRCLIB
  ///
  /// LRCLIB is an open-source lyrics API that provides synced lyrics.
  /// It's similar to Spotify's lyrics but free and open.
  Future<Lyrics?> _tryLrclib(
    String title,
    String artist,
    Duration? duration,
  ) async {
    try {
      Log.info('Trying LRCLIB for: $artist - $title');

      final response = await _dio.get(
        'https://lrclib.net/api/get',
        queryParameters: {
          'track_name': title,
          'artist_name': artist,
          if (duration != null) 'duration': duration.inSeconds,
        },
      );

      if (response.statusCode != 200) return null;

      final data = response.data as Map<String, dynamic>;

      // LRCLIB returns both synced and plain lyrics
      final syncedLrc = data['syncedLyrics'] as String?;
      final plainLrc = data['plainLyrics'] as String?;

      if (syncedLrc == null && plainLrc == null) return null;

      return Lyrics(
        songId: '', // Caller will set this
        syncedLines: syncedLrc != null ? _parseLrc(syncedLrc) : null,
        plainText: plainLrc,
        source: LyricsSource.lrclib,
      );
    } catch (e) {
      Log.warning('LRCLIB failed: $e');
      return null;
    }
  }

  /// Parse LRC format into list of lines
  ///
  /// LRC FORMAT:
  /// [00:12.34] First line of lyrics
  /// [00:15.67] Second line of lyrics
  ///
  /// The timestamp [mm:ss.xx] tells when to show each line.
  List<LyricLine> _parseLrc(String lrc) {
    final lines = <LyricLine>[];
    final regex = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\](.*)');

    for (final line in lrc.split('\n')) {
      final match = regex.firstMatch(line);
      if (match == null) continue;

      final minutes = int.parse(match.group(1)!);
      final seconds = int.parse(match.group(2)!);
      final millisStr = match.group(3)!;
      // Handle both .xx and .xxx formats
      final millis = int.parse(millisStr.padRight(3, '0'));
      final text = match.group(4)!.trim();

      if (text.isEmpty) continue;

      lines.add(
        LyricLine(
          startTime: Duration(
            minutes: minutes,
            seconds: seconds,
            milliseconds: millis,
          ),
          text: text,
        ),
      );
    }

    // Sort by start time (they should already be sorted, but just in case)
    lines.sort((a, b) => a.startTime.compareTo(b.startTime));

    return lines;
  }
}
