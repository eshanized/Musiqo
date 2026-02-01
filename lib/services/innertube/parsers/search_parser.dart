// ============================================================================
// Search Parser - Parse search API responses
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import '../../../data/models/song.dart';
import '../../../data/models/search_result.dart';

/// Parses search responses from InnerTube API.
///
/// WHY IS THIS SO COMPLEX?
/// YouTube's API responses are deeply nested JSON with lots of redundancy.
/// This parser navigates through the mess to extract the data we need.
class SearchParser {
  const SearchParser();

  /// Parse a full search response
  SearchResponse parse(Map<String, dynamic> response) {
    final songs = <SongResult>[];
    final albums = <AlbumResult>[];
    final artists = <ArtistResult>[];
    final playlists = <PlaylistResult>[];
    final videos = <VideoResult>[];

    // Navigate to the actual results
    // Path: contents.tabbedSearchResultsRenderer.tabs[0].tabRenderer.content
    //       .sectionListRenderer.contents[]
    final contents =
        _navigateTo(response, [
              'contents',
              'tabbedSearchResultsRenderer',
              'tabs',
              '0',
              'tabRenderer',
              'content',
              'sectionListRenderer',
              'contents',
            ])
            as List? ??
        [];

    for (final section in contents) {
      final musicShelf = section['musicShelfRenderer'];
      if (musicShelf == null) continue;

      final items = musicShelf['contents'] as List? ?? [];

      for (final item in items) {
        final renderer = item['musicResponsiveListItemRenderer'];
        if (renderer == null) continue;

        final result = _parseItem(renderer);
        if (result == null) continue;

        switch (result) {
          case SongResult():
            songs.add(result);
          case AlbumResult():
            albums.add(result);
          case ArtistResult():
            artists.add(result);
          case PlaylistResult():
            playlists.add(result);
          case VideoResult():
            videos.add(result);
        }
      }
    }

    return SearchResponse(
      songs: songs,
      albums: albums,
      artists: artists,
      playlists: playlists,
      videos: videos,
    );
  }

  /// Parse songs only from search response
  List<Song> parseSongs(Map<String, dynamic> response) {
    final result = parse(response);
    return result.songs.map((r) => r.song).toList();
  }

  /// Parse a single search result item
  SearchResult? _parseItem(Map<String, dynamic> renderer) {
    final flexColumns = renderer['flexColumns'] as List? ?? [];
    if (flexColumns.isEmpty) return null;

    // First column usually has the title
    final titleRun = _getTextRun(flexColumns, 0);
    final title = titleRun?['text'] as String? ?? '';

    // Navigation endpoint tells us what type this is
    final navEndpoint = titleRun?['navigationEndpoint'];
    final browseEndpoint = navEndpoint?['browseEndpoint'];
    final watchEndpoint = navEndpoint?['watchEndpoint'];

    // Get thumbnail
    final thumbnail = _getThumbnail(renderer);

    if (watchEndpoint != null) {
      // It's a song or video
      final videoId = watchEndpoint['videoId'] as String;

      // Second column has artist
      final subtitleRuns = _getSubtitleRuns(flexColumns);
      final artistName = subtitleRuns.isNotEmpty
          ? subtitleRuns.first['text'] as String?
          : null;

      // Check if it's a video (has "Video" in subtitle)
      final isVideo = subtitleRuns.any(
        (r) => (r['text'] as String?)?.toLowerCase() == 'video',
      );

      if (isVideo) {
        return VideoResult(
          id: videoId,
          title: title,
          artistName: artistName,
          thumbnailUrl: thumbnail,
        );
      }

      return SongResult(
        Song(
          id: videoId,
          title: title,
          artists: artistName != null ? [Artist(id: '', name: artistName)] : [],
          duration: Duration.zero, // Would need to parse from subtitle
          thumbnailUrl: thumbnail,
        ),
      );
    }

    if (browseEndpoint != null) {
      final browseId = browseEndpoint['browseId'] as String;
      final pageType =
          browseEndpoint['browseEndpointContextSupportedConfigs']?['browseEndpointContextMusicConfig']?['pageType']
              as String? ??
          '';

      if (pageType.contains('ARTIST')) {
        return ArtistResult(id: browseId, name: title, thumbnailUrl: thumbnail);
      }

      if (pageType.contains('ALBUM')) {
        final subtitleRuns = _getSubtitleRuns(flexColumns);
        final artistName = subtitleRuns.isNotEmpty
            ? subtitleRuns.first['text'] as String?
            : null;

        return AlbumResult(
          id: browseId,
          name: title,
          artistName: artistName,
          thumbnailUrl: thumbnail,
        );
      }

      if (pageType.contains('PLAYLIST')) {
        return PlaylistResult(
          id: browseId,
          name: title,
          thumbnailUrl: thumbnail,
        );
      }
    }

    return null;
  }

  /// Navigate through nested JSON
  dynamic _navigateTo(dynamic json, List<String> path) {
    dynamic current = json;
    for (final key in path) {
      if (current is Map) {
        current = current[key];
      } else if (current is List) {
        final index = int.tryParse(key);
        if (index != null && index < current.length) {
          current = current[index];
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
    return current;
  }

  /// Get text run from flex column
  Map<String, dynamic>? _getTextRun(List flexColumns, int index) {
    if (index >= flexColumns.length) return null;
    final column = flexColumns[index];
    final runs =
        column['musicResponsiveListItemFlexColumnRenderer']?['text']?['runs']
            as List?;
    return runs?.firstOrNull as Map<String, dynamic>?;
  }

  /// Get subtitle runs (second column usually)
  List<Map<String, dynamic>> _getSubtitleRuns(List flexColumns) {
    if (flexColumns.length < 2) return [];
    final column = flexColumns[1];
    final runs =
        column['musicResponsiveListItemFlexColumnRenderer']?['text']?['runs']
            as List?;
    return runs?.cast<Map<String, dynamic>>() ?? [];
  }

  /// Get thumbnail URL
  String? _getThumbnail(Map<String, dynamic> renderer) {
    final thumbnails =
        renderer['thumbnail']?['musicThumbnailRenderer']?['thumbnail']?['thumbnails']
            as List?;
    if (thumbnails == null || thumbnails.isEmpty) return null;
    return thumbnails.last['url'] as String?;
  }
}
