// ============================================================================
// Search Result Model - Different types of search results
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'song.dart';

/// A search result can be a song, album, artist, or playlist.
/// We use a sealed class to represent this "one of many" relationship.
/// 
/// WHAT'S A SEALED CLASS?
/// A sealed class is like an enum on steroids. It lets you define
/// a limited set of subclasses. This is perfect for search results
/// where we know exactly what types are possible.
sealed class SearchResult {
  const SearchResult();
}

/// Search result: a single song
class SongResult extends SearchResult {
  final Song song;
  const SongResult(this.song);
}

/// Search result: an album
class AlbumResult extends SearchResult {
  final String id;
  final String name;
  final String? artistName;
  final String? thumbnailUrl;
  final int? year;
  final bool isExplicit;
  
  const AlbumResult({
    required this.id,
    required this.name,
    this.artistName,
    this.thumbnailUrl,
    this.year,
    this.isExplicit = false,
  });
}

/// Search result: an artist
class ArtistResult extends SearchResult {
  final String id;
  final String name;
  final String? thumbnailUrl;
  final String? subscriberCount;
  
  const ArtistResult({
    required this.id,
    required this.name,
    this.thumbnailUrl,
    this.subscriberCount,
  });
}

/// Search result: a playlist
class PlaylistResult extends SearchResult {
  final String id;
  final String name;
  final String? author;
  final String? thumbnailUrl;
  final int? songCount;
  
  const PlaylistResult({
    required this.id,
    required this.name,
    this.author,
    this.thumbnailUrl,
    this.songCount,
  });
}

/// Search result: a video (music video)
class VideoResult extends SearchResult {
  final String id;
  final String title;
  final String? artistName;
  final String? thumbnailUrl;
  final Duration? duration;
  final String? viewCount;
  
  const VideoResult({
    required this.id,
    required this.title,
    this.artistName,
    this.thumbnailUrl,
    this.duration,
    this.viewCount,
  });
}

/// Container for all search results, grouped by type
class SearchResponse {
  final List<SongResult> songs;
  final List<AlbumResult> albums;
  final List<ArtistResult> artists;
  final List<PlaylistResult> playlists;
  final List<VideoResult> videos;
  
  /// For loading more results
  final String? continuation;

  const SearchResponse({
    this.songs = const [],
    this.albums = const [],
    this.artists = const [],
    this.playlists = const [],
    this.videos = const [],
    this.continuation,
  });

  /// Total number of results
  int get totalCount =>
      songs.length +
      albums.length +
      artists.length +
      playlists.length +
      videos.length;

  /// Is this response empty?
  bool get isEmpty => totalCount == 0;

  /// All results as a single list (for mixed display)
  List<SearchResult> get all => [
        ...songs,
        ...albums,
        ...artists,
        ...playlists,
        ...videos,
      ];
}

/// Generic search result item type for widgets
enum SearchResultType { song, album, artist, playlist, video }

/// Generic search result item for widgets
class SearchResultItem {
  final String id;
  final String title;
  final String? subtitle;
  final String? thumbnailUrl;
  final SearchResultType type;

  const SearchResultItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.thumbnailUrl,
    required this.type,
  });

  /// Create from SongResult
  factory SearchResultItem.fromSong(SongResult result) {
    return SearchResultItem(
      id: result.song.id,
      title: result.song.title,
      subtitle: result.song.artistName,
      thumbnailUrl: result.song.thumbnailUrl,
      type: SearchResultType.song,
    );
  }

  /// Create from AlbumResult
  factory SearchResultItem.fromAlbum(AlbumResult result) {
    return SearchResultItem(
      id: result.id,
      title: result.name,
      subtitle: result.artistName,
      thumbnailUrl: result.thumbnailUrl,
      type: SearchResultType.album,
    );
  }

  /// Create from ArtistResult
  factory SearchResultItem.fromArtist(ArtistResult result) {
    return SearchResultItem(
      id: result.id,
      title: result.name,
      subtitle: result.subscriberCount,
      thumbnailUrl: result.thumbnailUrl,
      type: SearchResultType.artist,
    );
  }

  /// Create from PlaylistResult
  factory SearchResultItem.fromPlaylist(PlaylistResult result) {
    return SearchResultItem(
      id: result.id,
      title: result.name,
      subtitle: result.author,
      thumbnailUrl: result.thumbnailUrl,
      type: SearchResultType.playlist,
    );
  }
}
