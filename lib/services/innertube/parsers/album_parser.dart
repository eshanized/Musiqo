// ============================================================================
// Album Parser - Parse album page from InnerTube
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import '../../../data/models/song.dart';

/// Parsed album data
class AlbumData {
  final String id;
  final String name;
  final String? artistName;
  final String? artistId;
  final String? thumbnailUrl;
  final int? year;
  final List<Song> tracks;
  final int? trackCount;
  final Duration? duration;

  const AlbumData({
    required this.id,
    required this.name,
    this.artistName,
    this.artistId,
    this.thumbnailUrl,
    this.year,
    this.tracks = const [],
    this.trackCount,
    this.duration,
  });
}

/// Parser for album pages.
class AlbumParser {
  const AlbumParser();

  /// Parse album page response
  AlbumData? parse(Map<String, dynamic> response) {
    try {
      final header = response['header']?['musicDetailHeaderRenderer'];
      if (header == null) return null;

      final id = _getBrowseId(response) ?? '';
      final name = _getText(header['title']);

      final subtitleRuns = header['subtitle']?['runs'] as List? ?? [];
      String? artistName;
      String? artistId;
      int? year;

      for (final run in subtitleRuns) {
        final text = run['text'] as String? ?? '';
        if (run['navigationEndpoint'] != null) {
          artistName = text;
          artistId = run['navigationEndpoint']?['browseEndpoint']?['browseId'];
        } else if (RegExp(r'^\d{4}$').hasMatch(text)) {
          year = int.tryParse(text);
        }
      }

      final tracks = _parseTracks(response);
      final thumbnail = _getThumbnail(header);

      return AlbumData(
        id: id,
        name: name,
        artistName: artistName,
        artistId: artistId,
        thumbnailUrl: thumbnail,
        year: year,
        tracks: tracks,
        trackCount: tracks.length,
      );
    } catch (e) {
      return null;
    }
  }

  List<Song> _parseTracks(Map<String, dynamic> response) {
    final songs = <Song>[];

    final contents =
        response['contents']?['singleColumnBrowseResultsRenderer']?['tabs']?[0]?['tabRenderer']?['content']?['sectionListRenderer']?['contents']
            as List? ??
        [];

    for (final content in contents) {
      final shelfContents =
          content['musicShelfRenderer']?['contents'] as List? ?? [];

      for (final item in shelfContents) {
        final renderer = item['musicResponsiveListItemRenderer'];
        if (renderer == null) continue;

        final song = _parseSong(renderer);
        if (song != null) {
          songs.add(song);
        }
      }
    }

    return songs;
  }

  Song? _parseSong(Map<String, dynamic> renderer) {
    final playEndpoint =
        renderer['overlay']?['musicItemThumbnailOverlayRenderer']?['content']?['musicPlayButtonRenderer']?['playNavigationEndpoint']?['watchEndpoint'];

    if (playEndpoint == null) return null;

    final videoId = playEndpoint['videoId'] as String?;
    if (videoId == null) return null;

    final flexColumns = renderer['flexColumns'] as List? ?? [];
    final title = _getFlexColumnText(flexColumns, 0);
    final durationText = _getFlexColumnText(flexColumns, 1);

    return Song(
      id: videoId,
      title: title,
      artists: const [],
      duration: _parseDuration(durationText),
    );
  }

  String _getText(Map<String, dynamic>? textObj) {
    if (textObj == null) return '';
    final runs = textObj['runs'] as List?;
    if (runs != null && runs.isNotEmpty) {
      return runs.map((r) => r['text']).join('');
    }
    return '';
  }

  String _getFlexColumnText(List flexColumns, int index) {
    if (index >= flexColumns.length) return '';
    return _getText(
      flexColumns[index]['musicResponsiveListItemFlexColumnRenderer']?['text'],
    );
  }

  String? _getBrowseId(Map<String, dynamic> response) {
    return response['responseContext']?['serviceTrackingParams']
        ?.firstWhere(
          (p) => p['service'] == 'GFEEDBACK',
          orElse: () => null,
        )?['params']
        ?.firstWhere(
          (p) => p['key'] == 'browse_id',
          orElse: () => null,
        )?['value'];
  }

  String? _getThumbnail(Map<String, dynamic> header) {
    final thumbnails =
        header['thumbnail']?['croppedSquareThumbnailRenderer']?['thumbnail']?['thumbnails']
            as List?;
    if (thumbnails == null || thumbnails.isEmpty) return null;
    return thumbnails.last['url'] as String?;
  }

  Duration _parseDuration(String text) {
    final parts = text.split(':').map(int.tryParse).toList();
    if (parts.length == 2) {
      return Duration(minutes: parts[0] ?? 0, seconds: parts[1] ?? 0);
    }
    return Duration.zero;
  }
}
