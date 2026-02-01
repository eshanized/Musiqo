// ============================================================================
// Artist Page Parser - Parse artist browse response
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
//
// Parses YouTube Music artist browse response to extract
// artist info, top songs, and albums.
// ============================================================================

import '../../../data/models/song.dart';

/// Parsed artist page data
class ArtistPage {
  final String id;
  final String name;
  final String? thumbnailUrl;
  final String? description;
  final String? subscriberCount;
  final List<Song> topSongs;
  final List<ArtistAlbum> albums;
  final List<ArtistAlbum> singles;
  final List<RelatedArtist> relatedArtists;

  const ArtistPage({
    required this.id,
    required this.name,
    this.thumbnailUrl,
    this.description,
    this.subscriberCount,
    required this.topSongs,
    required this.albums,
    required this.singles,
    required this.relatedArtists,
  });

  /// Parse artist browse response
  factory ArtistPage.fromBrowseResponse(String artistId, Map<String, dynamic> response) {
    final header = _extractHeader(response);
    final sections = _extractSections(response);

    return ArtistPage(
      id: artistId,
      name: header['name'] ?? 'Unknown Artist',
      thumbnailUrl: header['thumbnailUrl'],
      description: header['description'],
      subscriberCount: header['subscriberCount'],
      topSongs: (sections['topSongs'] as List<Song>?) ?? [],
      albums: (sections['albums'] as List<ArtistAlbum>?) ?? [],
      singles: (sections['singles'] as List<ArtistAlbum>?) ?? [],
      relatedArtists: (sections['relatedArtists'] as List<RelatedArtist>?) ?? [],
    );
  }

  /// Extract header info from response
  static Map<String, dynamic> _extractHeader(Map<String, dynamic> response) {
    final result = <String, dynamic>{};

    try {
      final header = response['header']?['musicImmersiveHeaderRenderer'] ??
          response['header']?['musicVisualHeaderRenderer'];

      if (header != null) {
        result['name'] = _getText(header['title']);
        result['description'] = _getText(header['description']);
        result['thumbnailUrl'] = _getThumbnail(header['thumbnail']);
        result['subscriberCount'] = header['subscriptionButton']
            ?['subscribeButtonRenderer']?['subscriberCountText']?['runs']?[0]?['text'];
      }
    } catch (e) {
      // Parsing error
    }

    return result;
  }

  /// Extract content sections from response
  static Map<String, List<dynamic>> _extractSections(Map<String, dynamic> response) {
    final result = <String, List<dynamic>>{
      'topSongs': <Song>[],
      'albums': <ArtistAlbum>[],
      'singles': <ArtistAlbum>[],
      'relatedArtists': <RelatedArtist>[],
    };

    try {
      final contents = response['contents']?['singleColumnBrowseResultsRenderer']
          ?['tabs']?[0]?['tabRenderer']?['content']?['sectionListRenderer']
          ?['contents'] as List?;

      if (contents == null) return result;

      for (final section in contents) {
        final shelfRenderer = section['musicShelfRenderer'];
        final carouselRenderer = section['musicCarouselShelfRenderer'];

        final renderer = shelfRenderer ?? carouselRenderer;
        if (renderer == null) continue;

        final title = _getText(renderer['title'])?.toLowerCase() ?? '';
        final items = (renderer['contents'] as List?) ?? [];

        if (title.contains('song') || title.contains('top')) {
          result['topSongs'] = _parseTopSongs(items);
        } else if (title.contains('album')) {
          result['albums'] = _parseAlbums(items);
        } else if (title.contains('single') || title.contains('ep')) {
          result['singles'] = _parseAlbums(items);
        } else if (title.contains('fan') || title.contains('also like') || title.contains('similar')) {
          result['relatedArtists'] = _parseRelatedArtists(items);
        }
      }
    } catch (e) {
      // Parsing error
    }

    return result;
  }

  /// Parse top songs from shelf
  static List<Song> _parseTopSongs(List<dynamic> items) {
    final songs = <Song>[];

    for (final item in items) {
      final renderer = item['musicResponsiveListItemRenderer'];
      if (renderer == null) continue;

      try {
        final videoId = renderer['playlistItemData']?['videoId'] as String?;
        if (videoId == null) continue;

        final flexColumns = renderer['flexColumns'] as List?;
        if (flexColumns == null || flexColumns.isEmpty) continue;

        final titleRuns = flexColumns[0]['musicResponsiveListItemFlexColumnRenderer']
            ?['text']?['runs'] as List?;
        final title = titleRuns?.isNotEmpty == true
            ? titleRuns![0]['text'] as String
            : 'Unknown';

        String artistName = 'Unknown Artist';
        if (flexColumns.length > 1) {
          final artistRuns = flexColumns[1]['musicResponsiveListItemFlexColumnRenderer']
              ?['text']?['runs'] as List?;
          if (artistRuns != null && artistRuns.isNotEmpty) {
            artistName = artistRuns[0]['text'] as String? ?? artistName;
          }
        }

        final thumbnail = _getThumbnail(
            renderer['thumbnail']?['musicThumbnailRenderer']?['thumbnail']);

        songs.add(Song(
          id: videoId,
          title: title,
          artists: [Artist(id: '', name: artistName)],
          duration: Duration.zero,
          thumbnailUrl: thumbnail,
        ));
      } catch (e) {
        continue;
      }
    }

    return songs;
  }

  /// Parse albums from carousel
  static List<ArtistAlbum> _parseAlbums(List<dynamic> items) {
    final albums = <ArtistAlbum>[];

    for (final item in items) {
      final renderer = item['musicTwoRowItemRenderer'];
      if (renderer == null) continue;

      try {
        final browseId = renderer['navigationEndpoint']?['browseEndpoint']?['browseId'] as String?;
        if (browseId == null) continue;

        final title = _getText(renderer['title']) ?? 'Unknown Album';
        final subtitle = _getText(renderer['subtitle']) ?? '';
        final thumbnail = _getThumbnail(renderer['thumbnailRenderer']?['musicThumbnailRenderer']?['thumbnail']);

        // Parse year from subtitle
        int? year;
        final yearMatch = RegExp(r'\b(19|20)\d{2}\b').firstMatch(subtitle);
        if (yearMatch != null) {
          year = int.tryParse(yearMatch.group(0)!);
        }

        albums.add(ArtistAlbum(
          id: browseId,
          title: title,
          year: year,
          thumbnailUrl: thumbnail,
        ));
      } catch (e) {
        continue;
      }
    }

    return albums;
  }

  /// Parse related artists
  static List<RelatedArtist> _parseRelatedArtists(List<dynamic> items) {
    final artists = <RelatedArtist>[];

    for (final item in items) {
      final renderer = item['musicTwoRowItemRenderer'];
      if (renderer == null) continue;

      try {
        final browseId = renderer['navigationEndpoint']?['browseEndpoint']?['browseId'] as String?;
        if (browseId == null || !browseId.startsWith('UC')) continue;

        final name = _getText(renderer['title']) ?? 'Unknown Artist';
        final thumbnail = _getThumbnail(renderer['thumbnailRenderer']?['musicThumbnailRenderer']?['thumbnail']);

        artists.add(RelatedArtist(
          id: browseId,
          name: name,
          thumbnailUrl: thumbnail,
        ));
      } catch (e) {
        continue;
      }
    }

    return artists;
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

/// Simple album representation for artist page
class ArtistAlbum {
  final String id;
  final String title;
  final int? year;
  final String? thumbnailUrl;

  const ArtistAlbum({
    required this.id,
    required this.title,
    this.year,
    this.thumbnailUrl,
  });
}

/// Related artist for artist page
class RelatedArtist {
  final String id;
  final String name;
  final String? thumbnailUrl;

  const RelatedArtist({
    required this.id,
    required this.name,
    this.thumbnailUrl,
  });
}
