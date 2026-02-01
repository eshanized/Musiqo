// ============================================================================
// YouTube Facade - High-level API for YouTube Music
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
//
// This class provides a clean, easy-to-use interface for YouTube Music.
// It uses InnerTubeClient internally but returns nice Dart objects.
// ============================================================================

import '../../data/models/song.dart';
import '../../data/models/playlist.dart';
import '../../data/models/search_result.dart';
import '../../core/utils/logger.dart';
import 'innertube_client.dart';
import 'parsers/search_parser.dart';
import 'parsers/song_parser.dart';
import 'pages/album_page.dart';
import 'pages/artist_page.dart';
import 'pages/playlist_page.dart';

/// High-level YouTube Music API.
///
/// DESIGN PATTERN: FACADE
/// A facade provides a simplified interface to a complex subsystem.
/// Instead of calling InnerTubeClient directly and parsing JSON,
/// you call methods like youtube.search() and get nice objects back.
class YouTubeFacade {
  final InnerTubeClient _client;
  final SearchParser _searchParser;
  final SongParser _songParser;

  YouTubeFacade()
    : _client = InnerTubeClient(),
      _searchParser = const SearchParser(),
      _songParser = const SongParser();

  /// Search for songs, albums, artists, etc.
  Future<SearchResponse> search(String query) async {
    try {
      Log.info('Searching: $query');
      final response = await _client.search(query);
      return _searchParser.parse(response);
    } catch (e) {
      Log.error('Search failed', error: e);
      return const SearchResponse();
    }
  }

  /// Search specifically for songs
  Future<List<Song>> searchSongs(String query) async {
    // YouTube Music filter params for songs only
    // This magic string comes from reverse engineering the web app
    const songFilter = 'EgWKAQIIAWoKEAkQBRAKEAMQBA%3D%3D';

    try {
      final response = await _client.search(query, filter: songFilter);
      return _searchParser.parseSongs(response);
    } catch (e) {
      Log.error('Song search failed', error: e);
      return [];
    }
  }

  /// Get search suggestions as user types
  Future<List<String>> getSuggestions(String query) {
    return _client.searchSuggestions(query);
  }

  /// Get song details and stream URL
  Future<SongDetails?> getSongDetails(String videoId) async {
    try {
      final response = await _client.player(videoId);
      return _songParser.parseDetails(response);
    } catch (e) {
      Log.error('Failed to get song details', error: e);
      return null;
    }
  }

  /// Get related songs / what to play next
  Future<List<Song>> getRelated(String videoId) async {
    try {
      final response = await _client.next(videoId: videoId);
      return _songParser.parseRelated(response);
    } catch (e) {
      Log.error('Failed to get related songs', error: e);
      return [];
    }
  }

  /// Get home page content
  Future<HomePageData> getHomePage() async {
    try {
      Log.info('Calling browse(FEmusic_home)...', tag: 'YouTubeFacade');
      final response = await _client.browse('FEmusic_home');
      Log.info('Browse response keys: ${response.keys.toList()}', tag: 'YouTubeFacade');
      final result = _parseHomePage(response);
      Log.info('Parsed ${result.sections.length} sections', tag: 'YouTubeFacade');
      return result;
    } catch (e) {
      Log.error('Failed to get home page', error: e);
      return const HomePageData();
    }
  }

  // ============================================
  // Page Endpoints (Album, Artist, Playlist)
  // ============================================

  /// Get album page with details and tracks
  Future<AlbumPage?> getAlbum(String albumId) async {
    try {
      Log.info('Getting album: $albumId', tag: 'YouTubeFacade');
      final response = await _client.browse(albumId);
      return AlbumPage.fromBrowseResponse(albumId, response);
    } catch (e) {
      Log.error('Failed to get album', error: e);
      return null;
    }
  }

  /// Get artist page with top songs, albums, etc.
  Future<ArtistPage?> getArtist(String artistId) async {
    try {
      Log.info('Getting artist: $artistId', tag: 'YouTubeFacade');
      final response = await _client.browse(artistId);
      return ArtistPage.fromBrowseResponse(artistId, response);
    } catch (e) {
      Log.error('Failed to get artist', error: e);
      return null;
    }
  }

  /// Get playlist page with tracks
  Future<PlaylistPage?> getPlaylist(String playlistId) async {
    try {
      Log.info('Getting playlist: $playlistId', tag: 'YouTubeFacade');
      // Playlist IDs need VL prefix for browse
      final browseId = playlistId.startsWith('VL') ? playlistId : 'VL$playlistId';
      final response = await _client.browse(browseId);
      return PlaylistPage.fromBrowseResponse(playlistId, response);
    } catch (e) {
      Log.error('Failed to get playlist', error: e);
      return null;
    }
  }

  /// Get radio/automix songs for a song
  Future<List<Song>> getRadio(String videoId) async {
    try {
      Log.info('Getting radio: $videoId', tag: 'YouTubeFacade');
      // The 'next' endpoint with a playlist prefix gives radio songs
      final response = await _client.next(
        videoId: videoId,
        playlistId: 'RDAMVM$videoId', // Radio playlist format
      );
      return _songParser.parseRelated(response);
    } catch (e) {
      Log.error('Failed to get radio', error: e);
      return [];
    }
  }

  /// Parse home page response
  HomePageData _parseHomePage(Map<String, dynamic> response) {
    final sections = <HomeSection>[];

    // Navigate to contents
    final contents =
        response['contents']?['singleColumnBrowseResultsRenderer']?['tabs']?[0]?['tabRenderer']?['content']?['sectionListRenderer']?['contents']
            as List? ??
        [];

    for (final section in contents) {
      final musicCarousel = section['musicCarouselShelfRenderer'];
      final musicShelf = section['musicShelfRenderer'];

      if (musicCarousel != null) {
        final parsed = _parseCarouselSection(musicCarousel);
        if (parsed != null) sections.add(parsed);
      } else if (musicShelf != null) {
        final parsed = _parseShelfSection(musicShelf);
        if (parsed != null) sections.add(parsed);
      }
    }

    return HomePageData(sections: sections);
  }

  /// Parse a carousel section
  HomeSection? _parseCarouselSection(Map<String, dynamic> renderer) {
    final header = renderer['header']?['musicCarouselShelfBasicHeaderRenderer'];
    final title = _getText(header?['title']);

    if (title.isEmpty) return null;

    final items = <dynamic>[];
    final contents = renderer['contents'] as List? ?? [];

    for (final item in contents) {
      final musicItem = item['musicTwoRowItemRenderer'];
      if (musicItem != null) {
        final parsed = _parseTwoRowItem(musicItem);
        if (parsed != null) items.add(parsed);
      }

      final responsiveItem = item['musicResponsiveListItemRenderer'];
      if (responsiveItem != null) {
        final parsed = _parseResponsiveItem(responsiveItem);
        if (parsed != null) items.add(parsed);
      }
    }

    return HomeSection(title: title, items: items);
  }

  /// Parse a shelf section (like quick picks)
  HomeSection? _parseShelfSection(Map<String, dynamic> renderer) {
    final header = renderer['header']?['musicShelfBasicHeaderRenderer'];
    final title = _getText(header?['title']);

    if (title.isEmpty) return null;

    final items = <Song>[];
    final contents = renderer['contents'] as List? ?? [];

    for (final item in contents) {
      final renderer = item['musicResponsiveListItemRenderer'];
      if (renderer != null) {
        final song = _parseResponsiveItem(renderer);
        if (song is Song) items.add(song);
      }
    }

    return HomeSection(title: title, items: items);
  }

  /// Parse a two-row item (album, playlist, etc.)
  dynamic _parseTwoRowItem(Map<String, dynamic> renderer) {
    final title = _getText(renderer['title']);
    final subtitle = _getText(renderer['subtitle']);
    final thumbnails =
        renderer['thumbnailRenderer']?['musicThumbnailRenderer']?['thumbnail']?['thumbnails']
            as List?;
    final thumbnailUrl =
        thumbnails?.isNotEmpty == true
            ? thumbnails!.last['url'] as String?
            : null;

    final navEndpoint = renderer['navigationEndpoint'];
    final browseEndpoint = navEndpoint?['browseEndpoint'];
    final watchEndpoint = navEndpoint?['watchEndpoint'];

    if (watchEndpoint != null) {
      final videoId = watchEndpoint['videoId'] as String?;
      if (videoId != null) {
        return Song(
          id: videoId,
          title: title,
          artists: [Artist(id: '', name: subtitle)],
          duration: Duration.zero,
          thumbnailUrl: thumbnailUrl,
        );
      }
    }

    if (browseEndpoint != null) {
      final browseId = browseEndpoint['browseId'] as String?;
      final pageType =
          browseEndpoint['browseEndpointContextSupportedConfigs']?['browseEndpointContextMusicConfig']?['pageType']
              as String?;

      if (pageType?.contains('ALBUM') == true && browseId != null) {
        return Album(id: browseId, name: title, thumbnailUrl: thumbnailUrl);
      }

      if (pageType?.contains('PLAYLIST') == true && browseId != null) {
        return Playlist(
          id: browseId,
          name: title,
          thumbnailUrl: thumbnailUrl,
          songs: [],
        );
      }

      if (pageType?.contains('ARTIST') == true && browseId != null) {
        return Artist(id: browseId, name: title, thumbnailUrl: thumbnailUrl);
      }
    }

    return null;
  }

  /// Parse responsive list item (song)
  dynamic _parseResponsiveItem(Map<String, dynamic> renderer) {
    final flexColumns = renderer['flexColumns'] as List? ?? [];
    if (flexColumns.isEmpty) return null;

    // Get title from first column
    final titleColumn =
        flexColumns[0]['musicResponsiveListItemFlexColumnRenderer'];
    final titleText = _getText(titleColumn?['text']);

    // Navigation endpoint
    final playlistItemData = renderer['playlistItemData'];
    final videoId = playlistItemData?['videoId'] as String?;

    if (videoId == null) return null;

    // Get artist from second column
    String? artistName;
    if (flexColumns.length > 1) {
      final subtitleColumn =
          flexColumns[1]['musicResponsiveListItemFlexColumnRenderer'];
      final runs = subtitleColumn?['text']?['runs'] as List?;
      if (runs != null && runs.isNotEmpty) {
        artistName = runs.first['text'] as String?;
      }
    }

    // Get thumbnail
    final thumbnails =
        renderer['thumbnail']?['musicThumbnailRenderer']?['thumbnail']?['thumbnails']
            as List?;
    final thumbnailUrl =
        thumbnails?.isNotEmpty == true
            ? thumbnails!.last['url'] as String?
            : null;

    return Song(
      id: videoId,
      title: titleText,
      artists: artistName != null ? [Artist(id: '', name: artistName)] : [],
      duration: Duration.zero,
      thumbnailUrl: thumbnailUrl,
    );
  }

  /// Get text from a text object
  String _getText(Map<String, dynamic>? textObj) {
    if (textObj == null) return '';
    if (textObj.containsKey('simpleText')) {
      return textObj['simpleText'] as String;
    }
    final runs = textObj['runs'] as List?;
    if (runs != null && runs.isNotEmpty) {
      return runs.map((r) => r['text']).join('');
    }
    return '';
  }
}

/// Song details including stream URL
class SongDetails {
  final String id;
  final String title;
  final String? artistName;
  final String? thumbnailUrl;
  final Duration duration;
  final String? streamUrl;
  final String? mimeType;
  final int? bitrate;

  const SongDetails({
    required this.id,
    required this.title,
    this.artistName,
    this.thumbnailUrl,
    required this.duration,
    this.streamUrl,
    this.mimeType,
    this.bitrate,
  });
}

/// Home page data container
class HomePageData {
  final List<HomeSection> sections;

  const HomePageData({this.sections = const []});
}

/// A section on the home page (e.g., "Quick picks", "Your mixes")
class HomeSection {
  final String title;
  final String? subtitle;
  final List<dynamic> items; // Can be Song, Album, Playlist, etc.

  const HomeSection({
    required this.title,
    this.subtitle,
    this.items = const [],
  });
}
