// ============================================================================
// Playlist Page Parser - Parse playlist browse response
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
//
// Parses YouTube Music playlist browse response to extract
// playlist details and tracks.
// ============================================================================

import '../../../data/models/song.dart';

/// Parsed playlist page data
class PlaylistPage {
  final String id;
  final String title;
  final String? ownerName;
  final String? thumbnailUrl;
  final int? trackCount;
  final String? duration;
  final String? description;
  final bool isEditable;
  final List<Song> tracks;

  const PlaylistPage({
    required this.id,
    required this.title,
    this.ownerName,
    this.thumbnailUrl,
    this.trackCount,
    this.duration,
    this.description,
    this.isEditable = false,
    required this.tracks,
  });

  /// Parse playlist browse response
  factory PlaylistPage.fromBrowseResponse(String playlistId, Map<String, dynamic> response) {
    final header = _extractHeader(response);
    final tracks = _extractTracks(response);

    return PlaylistPage(
      id: playlistId,
      title: header['title'] ?? 'Unknown Playlist',
      ownerName: header['ownerName'],
      thumbnailUrl: header['thumbnailUrl'],
      trackCount: tracks.length,
      duration: header['duration'],
      description: header['description'],
      isEditable: header['isEditable'] ?? false,
      tracks: tracks,
    );
  }

  /// Extract header info from response
  static Map<String, dynamic> _extractHeader(Map<String, dynamic> response) {
    final result = <String, dynamic>{};

    try {
      final header = response['header']?['musicDetailHeaderRenderer'] ??
          response['header']?['musicEditablePlaylistDetailHeaderRenderer']
              ?['header']?['musicDetailHeaderRenderer'];

      // Check if editable
      result['isEditable'] = response['header']?['musicEditablePlaylistDetailHeaderRenderer'] != null;

      if (header != null) {
        result['title'] = _getText(header['title']);
        result['description'] = _getText(header['description']);
        result['thumbnailUrl'] = _getThumbnail(header['thumbnail']);

        // Get subtitle info (owner, track count, duration)
        final subtitle = header['subtitle']?['runs'] as List?;
        if (subtitle != null) {
          for (final run in subtitle) {
            final text = run['text'] as String?;
            if (text == null) continue;

            // Owner has navigation endpoint
            if (run['navigationEndpoint'] != null) {
              result['ownerName'] = text;
            } else if (text.contains('song') || text.contains('track')) {
              // Track count like "50 songs"
            } else if (text.contains(':') || text.contains('hour') || text.contains('minute')) {
              result['duration'] = text;
            }
          }
        }

        // Secondary subtitle might have more info
        final secondSubtitle = header['secondSubtitle']?['runs'] as List?;
        if (secondSubtitle != null) {
          for (final run in secondSubtitle) {
            final text = run['text'] as String?;
            if (text != null && (text.contains(':') || text.contains('hour'))) {
              result['duration'] = text;
            }
          }
        }
      }
    } catch (e) {
      // Parsing error
    }

    return result;
  }

  /// Extract tracks from response
  static List<Song> _extractTracks(Map<String, dynamic> response) {
    final tracks = <Song>[];

    try {
      final contents = response['contents']?['singleColumnBrowseResultsRenderer']
              ?['tabs']?[0]?['tabRenderer']?['content']?['sectionListRenderer']
              ?['contents'] as List? ??
          response['contents']?['twoColumnBrowseResultsRenderer']
              ?['secondaryContents']?['sectionListRenderer']?['contents'] as List?;

      if (contents == null) return tracks;

      for (final section in contents) {
        final shelfContents = section['musicShelfRenderer']?['contents'] as List? ??
            section['musicPlaylistShelfRenderer']?['contents'] as List?;
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
      final videoId = renderer['playlistItemData']?['videoId'] as String? ??
          renderer['overlay']?['musicItemThumbnailOverlayRenderer']
              ?['content']?['musicPlayButtonRenderer']?['playNavigationEndpoint']
              ?['watchEndpoint']?['videoId'] as String?;
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

      // Album in third flex column  
      Album? album;
      if (flexColumns.length > 2) {
        final albumRuns = flexColumns[2]['musicResponsiveListItemFlexColumnRenderer']
            ?['text']?['runs'] as List?;
        if (albumRuns != null && albumRuns.isNotEmpty) {
          final albumName = albumRuns[0]['text'] as String?;
          final albumId = albumRuns[0]['navigationEndpoint']?['browseEndpoint']
              ?['browseId'] as String?;
          if (albumName != null) {
            album = Album(id: albumId ?? '', name: albumName);
          }
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
        album: album,
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
    return thumbnails.last['url'] as String?;
  }
}
