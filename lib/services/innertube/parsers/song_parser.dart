// ============================================================================
// Song Parser - Parse song details from API
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import '../../../data/models/song.dart';
import '../youtube_facade.dart';

/// Parses song details and related songs from InnerTube responses.
class SongParser {
  const SongParser();

  /// Parse song details from player response
  SongDetails? parseDetails(Map<String, dynamic> response) {
    final videoDetails = response['videoDetails'];
    if (videoDetails == null) return null;

    final streamingData = response['streamingData'];

    // Find best audio stream
    String? streamUrl;
    String? mimeType;
    int? bitrate;

    if (streamingData != null) {
      final formats = <Map<String, dynamic>>[
        ...(streamingData['adaptiveFormats'] as List? ?? [])
            .cast<Map<String, dynamic>>(),
      ];

      // Find audio-only format with highest bitrate
      // MIME types for audio: audio/mp4, audio/webm
      final audioFormats = formats
          .where(
            (f) => (f['mimeType'] as String?)?.startsWith('audio/') ?? false,
          )
          .toList();

      if (audioFormats.isNotEmpty) {
        // Sort by bitrate descending
        audioFormats.sort(
          (a, b) =>
              (b['bitrate'] as int? ?? 0).compareTo(a['bitrate'] as int? ?? 0),
        );

        final best = audioFormats.first;
        streamUrl = best['url'] as String?;
        mimeType = best['mimeType'] as String?;
        bitrate = best['bitrate'] as int?;
      }
    }

    return SongDetails(
      id: videoDetails['videoId'] as String,
      title: videoDetails['title'] as String,
      artistName: videoDetails['author'] as String?,
      thumbnailUrl: _getBestThumbnail(videoDetails['thumbnail']?['thumbnails']),
      duration: Duration(
        seconds: int.parse(videoDetails['lengthSeconds'] ?? '0'),
      ),
      streamUrl: streamUrl,
      mimeType: mimeType,
      bitrate: bitrate,
    );
  }

  /// Parse related songs from next() response
  List<Song> parseRelated(Map<String, dynamic> response) {
    final songs = <Song>[];

    // Navigate to watch next results
    // The structure varies, so we try multiple paths
    final contents =
        response['contents']?['singleColumnMusicWatchNextResultsRenderer']?['tabbedRenderer']?['watchNextTabbedResultsRenderer']?['tabs']
            as List?;

    if (contents == null) return songs;

    for (final tab in contents) {
      final tabRenderer = tab['tabRenderer'];
      final content = tabRenderer?['content'];

      final musicQueue = content?['musicQueueRenderer'];
      if (musicQueue != null) {
        final items =
            musicQueue['content']?['playlistPanelRenderer']?['contents']
                as List? ??
            [];

        for (final item in items) {
          final song = _parsePanelItem(item);
          if (song != null) songs.add(song);
        }
      }
    }

    return songs;
  }

  /// Parse a single panel item (used in queue/related)
  Song? _parsePanelItem(Map<String, dynamic> item) {
    final renderer = item['playlistPanelVideoRenderer'];
    if (renderer == null) return null;

    final videoId = renderer['videoId'] as String?;
    if (videoId == null) return null;

    final title = _getText(renderer['title']);
    final artists = <Artist>[];

    // Parse artist from longBylineText
    final bylineRuns = renderer['longBylineText']?['runs'] as List?;
    if (bylineRuns != null && bylineRuns.isNotEmpty) {
      final artistRun = bylineRuns.first as Map<String, dynamic>;
      artists.add(Artist(id: '', name: artistRun['text'] as String));
    }

    // Parse duration
    final durationText = _getText(renderer['lengthText']);
    final duration = _parseDuration(durationText);

    return Song(
      id: videoId,
      title: title,
      artists: artists,
      duration: duration,
      thumbnailUrl: _getBestThumbnail(renderer['thumbnail']?['thumbnails']),
    );
  }

  /// Get text from a run object
  String _getText(Map<String, dynamic>? textObj) {
    if (textObj == null) return '';

    // Check for simpleText
    if (textObj.containsKey('simpleText')) {
      return textObj['simpleText'] as String;
    }

    // Check for runs
    final runs = textObj['runs'] as List?;
    if (runs != null && runs.isNotEmpty) {
      return runs.map((r) => r['text']).join('');
    }

    return '';
  }

  /// Get best quality thumbnail
  String? _getBestThumbnail(List? thumbnails) {
    if (thumbnails == null || thumbnails.isEmpty) return null;

    // Thumbnails are usually sorted by quality ascending
    // Get the last (highest quality) one
    final best = thumbnails.last as Map<String, dynamic>;
    return best['url'] as String?;
  }

  /// Parse duration string like "3:45" or "1:23:45"
  Duration _parseDuration(String text) {
    if (text.isEmpty) return Duration.zero;

    final parts = text.split(':').map(int.tryParse).toList();

    if (parts.length == 2) {
      // mm:ss
      return Duration(minutes: parts[0] ?? 0, seconds: parts[1] ?? 0);
    } else if (parts.length == 3) {
      // hh:mm:ss
      return Duration(
        hours: parts[0] ?? 0,
        minutes: parts[1] ?? 0,
        seconds: parts[2] ?? 0,
      );
    }

    return Duration.zero;
  }
}
