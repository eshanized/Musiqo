// ============================================================================
// Artist Parser - Parse artist page from InnerTube
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import '../../../data/models/song.dart';

/// Parsed artist data
class ArtistData {
  final String id;
  final String name;
  final String? thumbnailUrl;
  final String? description;
  final int? subscriberCount;
  final List<Song> topSongs;
  final List<AlbumPreview> albums;
  final List<ArtistPreview> similarArtists;

  const ArtistData({
    required this.id,
    required this.name,
    this.thumbnailUrl,
    this.description,
    this.subscriberCount,
    this.topSongs = const [],
    this.albums = const [],
    this.similarArtists = const [],
  });
}

/// Album preview for artist page
class AlbumPreview {
  final String id;
  final String name;
  final String? year;
  final String? thumbnailUrl;

  const AlbumPreview({
    required this.id,
    required this.name,
    this.year,
    this.thumbnailUrl,
  });
}

/// Artist preview for similar artists
class ArtistPreview {
  final String id;
  final String name;
  final String? thumbnailUrl;

  const ArtistPreview({
    required this.id,
    required this.name,
    this.thumbnailUrl,
  });
}

/// Parser for artist pages.
class ArtistParser {
  const ArtistParser();

  /// Parse artist page response
  ArtistData? parse(Map<String, dynamic> response) {
    try {
      final header =
          response['header']?['musicImmersiveHeaderRenderer'] ??
          response['header']?['musicVisualHeaderRenderer'];
      if (header == null) return null;

      final name = _getText(header['title']);
      final thumbnail = _getThumbnail(header);
      final description = _getText(header['description']);
      final subscriberCount = _parseSubscriberCount(
        header['subscriptionButton'],
      );

      final sections = _parseSections(response);

      return ArtistData(
        id: _getBrowseId(response) ?? '',
        name: name,
        thumbnailUrl: thumbnail,
        description: description.isEmpty ? null : description,
        subscriberCount: subscriberCount,
        topSongs: sections.topSongs,
        albums: sections.albums,
        similarArtists: sections.similarArtists,
      );
    } catch (e) {
      return null;
    }
  }

  _ArtistSections _parseSections(Map<String, dynamic> response) {
    final topSongs = <Song>[];
    final albums = <AlbumPreview>[];
    final similarArtists = <ArtistPreview>[];

    final contents =
        response['contents']?['singleColumnBrowseResultsRenderer']?['tabs']?[0]?['tabRenderer']?['content']?['sectionListRenderer']?['contents']
            as List? ??
        [];

    for (final content in contents) {
      final shelf = content['musicShelfRenderer'];
      final carousel = content['musicCarouselShelfRenderer'];

      if (shelf != null) {
        final title = _getShelfTitle(shelf);
        if (title.toLowerCase().contains('songs')) {
          topSongs.addAll(_parseTopSongs(shelf));
        }
      }

      if (carousel != null) {
        final title = _getCarouselTitle(carousel);
        if (title.toLowerCase().contains('album')) {
          albums.addAll(_parseAlbums(carousel));
        } else if (title.toLowerCase().contains('fans')) {
          similarArtists.addAll(_parseSimilarArtists(carousel));
        }
      }
    }

    return _ArtistSections(
      topSongs: topSongs,
      albums: albums,
      similarArtists: similarArtists,
    );
  }

  List<Song> _parseTopSongs(Map<String, dynamic> shelf) {
    final songs = <Song>[];
    final items = shelf['contents'] as List? ?? [];

    for (final item in items) {
      final renderer = item['musicResponsiveListItemRenderer'];
      if (renderer == null) continue;

      final playEndpoint =
          renderer['overlay']?['musicItemThumbnailOverlayRenderer']?['content']?['musicPlayButtonRenderer']?['playNavigationEndpoint']?['watchEndpoint'];

      if (playEndpoint == null) continue;

      final videoId = playEndpoint['videoId'] as String?;
      if (videoId == null) continue;

      final flexColumns = renderer['flexColumns'] as List? ?? [];

      songs.add(
        Song(
          id: videoId,
          title: _getFlexColumnText(flexColumns, 0),
          artists: const [],
          duration: Duration.zero,
          thumbnailUrl: _getItemThumbnail(renderer),
        ),
      );
    }

    return songs;
  }

  List<AlbumPreview> _parseAlbums(Map<String, dynamic> carousel) {
    final albums = <AlbumPreview>[];
    final items = carousel['contents'] as List? ?? [];

    for (final item in items) {
      final renderer = item['musicTwoRowItemRenderer'];
      if (renderer == null) continue;

      final browseEndpoint = renderer['navigationEndpoint']?['browseEndpoint'];
      if (browseEndpoint == null) continue;

      albums.add(
        AlbumPreview(
          id: browseEndpoint['browseId'] ?? '',
          name: _getText(renderer['title']),
          year: _getText(renderer['subtitle']),
          thumbnailUrl: _getTwoRowThumbnail(renderer),
        ),
      );
    }

    return albums;
  }

  List<ArtistPreview> _parseSimilarArtists(Map<String, dynamic> carousel) {
    final artists = <ArtistPreview>[];
    final items = carousel['contents'] as List? ?? [];

    for (final item in items) {
      final renderer = item['musicTwoRowItemRenderer'];
      if (renderer == null) continue;

      final browseEndpoint = renderer['navigationEndpoint']?['browseEndpoint'];
      if (browseEndpoint == null) continue;

      artists.add(
        ArtistPreview(
          id: browseEndpoint['browseId'] ?? '',
          name: _getText(renderer['title']),
          thumbnailUrl: _getTwoRowThumbnail(renderer),
        ),
      );
    }

    return artists;
  }

  String _getText(Map<String, dynamic>? textObj) {
    if (textObj == null) return '';
    final runs = textObj['runs'] as List?;
    if (runs != null && runs.isNotEmpty) {
      return runs.map((r) => r['text']).join('');
    }
    return textObj['simpleText'] as String? ?? '';
  }

  String _getFlexColumnText(List flexColumns, int index) {
    if (index >= flexColumns.length) return '';
    return _getText(
      flexColumns[index]['musicResponsiveListItemFlexColumnRenderer']?['text'],
    );
  }

  String _getShelfTitle(Map<String, dynamic> shelf) {
    return _getText(shelf['title']);
  }

  String _getCarouselTitle(Map<String, dynamic> carousel) {
    return _getText(
      carousel['header']?['musicCarouselShelfBasicHeaderRenderer']?['title'],
    );
  }

  String? _getThumbnail(Map<String, dynamic> header) {
    final thumbnails =
        header['thumbnail']?['musicThumbnailRenderer']?['thumbnail']?['thumbnails']
            as List?;
    if (thumbnails == null || thumbnails.isEmpty) return null;
    return thumbnails.last['url'] as String?;
  }

  String? _getItemThumbnail(Map<String, dynamic> renderer) {
    final thumbnails =
        renderer['thumbnail']?['musicThumbnailRenderer']?['thumbnail']?['thumbnails']
            as List?;
    if (thumbnails == null || thumbnails.isEmpty) return null;
    return thumbnails.last['url'] as String?;
  }

  String? _getTwoRowThumbnail(Map<String, dynamic> renderer) {
    final thumbnails =
        renderer['thumbnailRenderer']?['musicThumbnailRenderer']?['thumbnail']?['thumbnails']
            as List?;
    if (thumbnails == null || thumbnails.isEmpty) return null;
    return thumbnails.last['url'] as String?;
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

  int? _parseSubscriberCount(Map<String, dynamic>? button) {
    final text = button?['subscribeButtonRenderer']?['subscriberCountText'];
    if (text == null) return null;
    final str = _getText(text);
    // Parse "1.2M subscribers" format
    final match = RegExp(r'([\d.]+)([KMB])?').firstMatch(str);
    if (match == null) return null;

    var value = double.parse(match.group(1)!);
    switch (match.group(2)) {
      case 'K':
        value *= 1000;
      case 'M':
        value *= 1000000;
      case 'B':
        value *= 1000000000;
    }
    return value.round();
  }
}

class _ArtistSections {
  final List<Song> topSongs;
  final List<AlbumPreview> albums;
  final List<ArtistPreview> similarArtists;

  _ArtistSections({
    required this.topSongs,
    required this.albums,
    required this.similarArtists,
  });
}
