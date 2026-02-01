// ============================================================================
// Album Page Parser - Parse album browse response
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
//
// Parses YouTube Music album browse response to extract
// album details and track list.
// ============================================================================

import '../../../data/models/song.dart';

/// Parsed album page data
class AlbumPage {
  final String id;
  final String title;
  final String? artistName;
  final String? artistId;
  final String? thumbnailUrl;
  final int? year;
  final int? trackCount;
  final String? duration;
  final String? description;
  final List<Song> tracks;

  const AlbumPage({
    required this.id,
    required this.title,
    this.artistName,
    this.artistId,
    this.thumbnailUrl,
    this.year,
    this.trackCount,
    this.duration,
    this.description,
    required this.tracks,
  });

  /// Parse album browse response
  factory AlbumPage.fromBrowseResponse(String albumId, Map<String, dynamic> response) {
    final header = _extractHeader(response);
    final tracks = _extractTracks(response);

    return AlbumPage(
      id: albumId,
      title: header['title'] ?? 'Unknown Album',
      artistName: header['artistName'],
      artistId: header['artistId'],
      thumbnailUrl: header['thumbnailUrl'],
      year: header['year'],
      trackCount: tracks.length,
      duration: header['duration'],
      description: header['description'],
      tracks: tracks,
    );
  }

  /// Extract header info from response
  static Map<String, dynamic> _extractHeader(Map<String, dynamic> response) {
    final result = <String, dynamic>{};

    try {
      // Try different header paths
      final header = response['header']?['musicDetailHeaderRenderer'] ??
          response['header']?['musicImmersiveHeaderRenderer'];

      if (header != null) {
        result['title'] = _getText(header['title']);
        result['description'] = _getText(header['description']);
        result['thumbnailUrl'] = _getThumbnail(header['thumbnail']);

        // Get subtitle info (artist, year)
        final subtitle = header['subtitle']?['runs'] as List?;
        if (subtitle != null && subtitle.isNotEmpty) {
          for (var i = 0; i < subtitle.length; i++) {
            final run = subtitle[i];
            final text = run['text'] as String?;
            final navEndpoint = run['navigationEndpoint'];

            if (navEndpoint != null) {
              final browseId = navEndpoint['browseEndpoint']?['browseId'] as String?;
              if (browseId != null && browseId.startsWith('UC')) {
                result['artistName'] = text;
                result['artistId'] = browseId;
              }
            } else if (text != null) {
              // Try to parse year
              final yearMatch = RegExp(r'\b(19|20)\d{2}\b').firstMatch(text);
              if (yearMatch != null) {
                result['year'] = int.tryParse(yearMatch.group(0)!);
              }
            }
          }
        }

        // Get duration from menu
        final menu = header['menu']?['menuRenderer']?['items'] as List?;
        if (menu != null) {
          for (final item in menu) {
            final text = item['menuServiceItemRenderer']?['text']?['runs']?[0]?['text'] as String?;
            if (text != null && text.contains(':')) {
              result['duration'] = text;
              break;
            }
          }
        }
      }
    } catch (e) {
      // Parsing error, return partial result
    }

    return result;
  }

  /// Extract tracks from response
  static List<Song> _extractTracks(Map<String, dynamic> response) {
    final tracks = <Song>[];

    try {
      final contents = response['contents']?['singleColumnBrowseResultsRenderer']
          ?['tabs']?[0]?['tabRenderer']?['content']?['sectionListRenderer']
          ?['contents'] as List?;

      if (contents == null) return tracks;

      for (final section in contents) {
        final shelfContents = section['musicShelfRenderer']?['contents'] as List?;
        if (shelfContents == null) continue;

        for (final item in shelfContents) {
          final renderer = item['musicResponsiveListItemRenderer'];
          if (renderer == null) continue;

          final song = _parseMusicItem(renderer);
          if (song != null) {
            tracks.add(song);
          }
        }
      }
    } catch (e) {
      // Parsing error
    }

    return tracks;
  }

  /// Parse a music item renderer to Song
  static Song? _parseMusicItem(Map<String, dynamic> renderer) {
    try {
      // Get video ID
      final videoId = renderer['playlistItemData']?['videoId'] as String?;
      if (videoId == null) return null;

      // Get flex columns
      final flexColumns = renderer['flexColumns'] as List?;
      if (flexColumns == null || flexColumns.isEmpty) return null;

      // Title is in first flex column
      final titleRuns = flexColumns[0]['musicResponsiveListItemFlexColumnRenderer']
          ?['text']?['runs'] as List?;
      final title = titleRuns?.isNotEmpty == true 
          ? titleRuns![0]['text'] as String 
          : 'Unknown';

      // Artist in second flex column
      String artistName = 'Unknown Artist';
      String artistId = '';
      if (flexColumns.length > 1) {
        final artistRuns = flexColumns[1]['musicResponsiveListItemFlexColumnRenderer']
            ?['text']?['runs'] as List?;
        if (artistRuns != null && artistRuns.isNotEmpty) {
          artistName = artistRuns[0]['text'] as String? ?? artistName;
          artistId = artistRuns[0]['navigationEndpoint']?['browseEndpoint']
              ?['browseId'] as String? ?? '';
        }
      }

      // Duration from fixed columns
      Duration duration = Duration.zero;
      final fixedColumns = renderer['fixedColumns'] as List?;
      if (fixedColumns != null && fixedColumns.isNotEmpty) {
        final durationText = fixedColumns[0]['musicResponsiveListItemFixedColumnRenderer']
            ?['text']?['runs']?[0]?['text'] as String?;
        if (durationText != null) {
          duration = _parseDuration(durationText);
        }
      }

      // Thumbnail
      final thumbnail = _getThumbnail(renderer['thumbnail']?['musicThumbnailRenderer']?['thumbnail']);

      return Song(
        id: videoId,
        title: title,
        artists: [Artist(id: artistId, name: artistName)],
        duration: duration,
        thumbnailUrl: thumbnail,
      );
    } catch (e) {
      return null;
    }
  }

  /// Parse duration string like "3:45" to Duration
  static Duration _parseDuration(String text) {
    final parts = text.split(':').reversed.toList();
    int seconds = 0;
    for (int i = 0; i < parts.length; i++) {
      final value = int.tryParse(parts[i]) ?? 0;
      seconds += value * [1, 60, 3600][i.clamp(0, 2)];
    }
    return Duration(seconds: seconds);
  }

  /// Extract text from text object
  static String? _getText(Map<String, dynamic>? textObj) {
    if (textObj == null) return null;
    final runs = textObj['runs'] as List?;
    if (runs == null || runs.isEmpty) return null;
    return runs.map((r) => r['text'] as String).join();
  }

  /// Extract thumbnail URL
  static String? _getThumbnail(Map<String, dynamic>? thumbnailObj) {
    if (thumbnailObj == null) return null;
    final thumbnails = thumbnailObj['thumbnails'] as List?;
    if (thumbnails == null || thumbnails.isEmpty) return null;
    // Get largest thumbnail
    return thumbnails.last['url'] as String?;
  }
}
