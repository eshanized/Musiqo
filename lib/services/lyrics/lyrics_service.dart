// ============================================================================
// Lyrics Service - Fetch synced lyrics from multiple sources
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'dart:convert';
import 'package:dio/dio.dart';

import '../../core/utils/logger.dart';

/// A single line of lyrics with timing
class LyricLine {
  final Duration startTime;
  final Duration endTime;
  final String text;

  const LyricLine({
    required this.startTime,
    required this.endTime,
    required this.text,
  });

  /// Check if this line should be highlighted at given position
  bool isActiveAt(Duration position) {
    return position >= startTime && position < endTime;
  }
}

/// The full lyrics for a song
class SongLyrics {
  final String songId;
  final String title;
  final String artist;
  final List<LyricLine> lines;
  final bool isSynced;
  final String? source;

  const SongLyrics({
    required this.songId,
    required this.title,
    required this.artist,
    required this.lines,
    this.isSynced = false,
    this.source,
  });

  /// Get the currently active line index at given position
  int? getActiveLineIndex(Duration position) {
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].isActiveAt(position)) {
        return i;
      }
    }
    return null;
  }

  /// Check if lyrics are available
  bool get isEmpty => lines.isEmpty;

  /// Plain text lyrics
  String get plainText => lines.map((l) => l.text).join('\n');
}

/// Service for fetching lyrics from YouTube and fallback sources
class LyricsService {
  final Dio _dio = Dio();

  LyricsService() {
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  /// Fetch lyrics for a song from YouTube Music
  Future<SongLyrics?> fetchLyrics({
    required String videoId,
    required String title,
    required String artist,
  }) async {
    Log.info('Fetching lyrics for: $title', tag: 'Lyrics');

    try {
      // Try YouTube Music first (via InnerTube)
      final ytLyrics = await _fetchFromYouTubeMusic(videoId, title, artist);
      if (ytLyrics != null && !ytLyrics.isEmpty) {
        return ytLyrics;
      }

      // Fallback to LRCLIB (free lyrics API)
      final lrcLyrics = await _fetchFromLrcLib(title, artist);
      if (lrcLyrics != null && !lrcLyrics.isEmpty) {
        return lrcLyrics;
      }

      Log.warning('No lyrics found for: $title', tag: 'Lyrics');
      return null;
    } catch (e) {
      Log.error('Failed to fetch lyrics', error: e, tag: 'Lyrics');
      return null;
    }
  }

  /// Fetch from YouTube Music using browse endpoint
  Future<SongLyrics?> _fetchFromYouTubeMusic(
    String videoId,
    String title,
    String artist,
  ) async {
    try {
      // YouTube Music lyrics are available via browse endpoint
      // browseId: "MPLYvid_{videoId}"
      final response = await _dio.post(
        'https://music.youtube.com/youtubei/v1/browse',
        queryParameters: {'key': 'AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30'},
        data: jsonEncode({
          'context': {
            'client': {
              'clientName': 'WEB_REMIX',
              'clientVersion': '1.20250310.01.00',
            },
          },
          'browseId': 'MPLYvid_$videoId',
        }),
        options: Options(headers: {
          'Content-Type': 'application/json',
        }),
      );

      if (response.data == null) return null;

      final data = response.data as Map<String, dynamic>;
      final lyrics = _parseYouTubeLyrics(data, videoId, title, artist);
      return lyrics;
    } catch (e) {
      Log.debug('YouTube lyrics not available: $e', tag: 'Lyrics');
      return null;
    }
  }

  /// Parse YouTube Music lyrics response
  SongLyrics? _parseYouTubeLyrics(
    Map<String, dynamic> data,
    String videoId,
    String title,
    String artist,
  ) {
    try {
      // Navigate to lyrics content
      final contents = data['contents']?['sectionListRenderer']?['contents'] as List?;
      if (contents == null || contents.isEmpty) return null;

      // Find lyrics in musicDescriptionShelfRenderer
      for (final section in contents) {
        final renderer = section['musicDescriptionShelfRenderer'];
        if (renderer != null) {
          final description = renderer['description']?['runs'] as List?;
          if (description != null && description.isNotEmpty) {
            final lyricsText = description.map((r) => r['text']).join('');
            
            // Parse as plain lyrics (YouTube rarely provides synced)
            final lines = _parseUntimedLyrics(lyricsText);
            
            return SongLyrics(
              songId: videoId,
              title: title,
              artist: artist,
              lines: lines,
              isSynced: false,
              source: 'YouTube Music',
            );
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Fetch from LRCLIB - free synced lyrics API
  Future<SongLyrics?> _fetchFromLrcLib(String title, String artist) async {
    try {
      final response = await _dio.get(
        'https://lrclib.net/api/get',
        queryParameters: {
          'track_name': title,
          'artist_name': artist,
        },
      );

      if (response.statusCode != 200 || response.data == null) return null;

      final data = response.data as Map<String, dynamic>;
      
      // Try synced lyrics first
      final syncedLyrics = data['syncedLyrics'] as String?;
      if (syncedLyrics != null && syncedLyrics.isNotEmpty) {
        final lines = _parseLrcLyrics(syncedLyrics);
        return SongLyrics(
          songId: '',
          title: title,
          artist: artist,
          lines: lines,
          isSynced: true,
          source: 'LRCLIB',
        );
      }

      // Fall back to plain lyrics
      final plainLyrics = data['plainLyrics'] as String?;
      if (plainLyrics != null && plainLyrics.isNotEmpty) {
        final lines = _parseUntimedLyrics(plainLyrics);
        return SongLyrics(
          songId: '',
          title: title,
          artist: artist,
          lines: lines,
          isSynced: false,
          source: 'LRCLIB',
        );
      }

      return null;
    } catch (e) {
      Log.debug('LRCLIB request failed: $e', tag: 'Lyrics');
      return null;
    }
  }

  /// Parse LRC format lyrics (synced)
  /// Format: [mm:ss.xx] lyrics text
  List<LyricLine> _parseLrcLyrics(String lrc) {
    final lines = <LyricLine>[];
    final regex = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\](.*)');

    final lrcLines = lrc.split('\n');
    
    for (int i = 0; i < lrcLines.length; i++) {
      final match = regex.firstMatch(lrcLines[i]);
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final millis = int.parse(match.group(3)!.padRight(3, '0'));
        final text = match.group(4)!.trim();

        if (text.isEmpty) continue;

        final startTime = Duration(
          minutes: minutes,
          seconds: seconds,
          milliseconds: millis,
        );

        // End time is start of next line or +5 seconds
        Duration endTime;
        if (i + 1 < lrcLines.length) {
          final nextMatch = regex.firstMatch(lrcLines[i + 1]);
          if (nextMatch != null) {
            endTime = Duration(
              minutes: int.parse(nextMatch.group(1)!),
              seconds: int.parse(nextMatch.group(2)!),
              milliseconds: int.parse(nextMatch.group(3)!.padRight(3, '0')),
            );
          } else {
            endTime = startTime + const Duration(seconds: 5);
          }
        } else {
          endTime = startTime + const Duration(seconds: 5);
        }

        lines.add(LyricLine(
          startTime: startTime,
          endTime: endTime,
          text: text,
        ));
      }
    }

    return lines;
  }

  /// Parse plain text lyrics (no timing)
  List<LyricLine> _parseUntimedLyrics(String text) {
    final lines = <LyricLine>[];
    final textLines = text.split('\n');

    // Assign fake timing (5 seconds per line) for display purposes
    for (int i = 0; i < textLines.length; i++) {
      final line = textLines[i].trim();
      if (line.isEmpty) continue;

      lines.add(LyricLine(
        startTime: Duration(seconds: i * 5),
        endTime: Duration(seconds: (i + 1) * 5),
        text: line,
      ));
    }

    return lines;
  }
}
