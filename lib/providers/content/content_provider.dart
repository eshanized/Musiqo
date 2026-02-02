// ============================================================================
// Content Providers - Artist, Album, Playlist data fetching
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/song.dart';
import '../../services/innertube/innertube_client.dart';
import '../../core/utils/logger.dart';

// ============================================================================
// Client Provider
// ============================================================================

final innerTubeClientProvider = Provider<InnerTubeClient>((ref) {
  return InnerTubeClient();
});

// ============================================================================
// Artist Provider
// ============================================================================

/// Artist details model
class ArtistDetails {
  final String id;
  final String name;
  final String? description;
  final String? thumbnailUrl;
  final String? subscriberCount;
  final List<Song> songs;
  final List<AlbumInfo> albums;
  final List<ArtistInfo> similarArtists;

  const ArtistDetails({
    required this.id,
    required this.name,
    this.description,
    this.thumbnailUrl,
    this.subscriberCount,
    this.songs = const [],
    this.albums = const [],
    this.similarArtists = const [],
  });
}

/// Basic artist info for lists
class ArtistInfo {
  final String id;
  final String name;
  final String? thumbnailUrl;

  const ArtistInfo({
    required this.id,
    required this.name,
    this.thumbnailUrl,
  });
}

/// Basic album info for lists
class AlbumInfo {
  final String id;
  final String title;
  final String? artistName;
  final String? year;
  final String? thumbnailUrl;

  const AlbumInfo({
    required this.id,
    required this.title,
    this.artistName,
    this.year,
    this.thumbnailUrl,
  });
}

/// Fetch artist details by ID
final artistDetailsProvider = FutureProvider.family<ArtistDetails?, String>((ref, artistId) async {
  final client = ref.read(innerTubeClientProvider);
  
  try {
    Log.info('Fetching artist: $artistId', tag: 'Content');
    final response = await client.browse(artistId);
    
    return _parseArtistResponse(artistId, response);
  } catch (e) {
    Log.error('Failed to fetch artist', error: e, tag: 'Content');
    return null;
  }
});

ArtistDetails? _parseArtistResponse(String artistId, Map<String, dynamic> response) {
  try {
    final header = response['header']?['musicImmersiveHeaderRenderer'] ??
                   response['header']?['musicVisualHeaderRenderer'];
    
    if (header == null) return null;
    
    // Get name
    final name = _getText(header['title']) ?? 'Unknown Artist';
    
    // Get description
    final description = _getText(header['description']);
    
    // Get thumbnail
    String? thumbnailUrl;
    final thumbnails = header['thumbnail']?['musicThumbnailRenderer']?['thumbnail']?['thumbnails'] as List?;
    if (thumbnails != null && thumbnails.isNotEmpty) {
      thumbnailUrl = thumbnails.last['url'];
    }
    
    // Get subscriber count
    final subscriberCount = _getText(header['subscriptionButton']?['subscribeButtonRenderer']?['subscriberCountText']);
    
    // Parse content sections
    final contents = response['contents']?['singleColumnBrowseResultsRenderer']?['tabs']?[0]
        ?['tabRenderer']?['content']?['sectionListRenderer']?['contents'] as List?;
    
    final songs = <Song>[];
    final albums = <AlbumInfo>[];
    final similarArtists = <ArtistInfo>[];
    
    if (contents != null) {
      for (final section in contents) {
        final shelfRenderer = section['musicShelfRenderer'];
        final carouselRenderer = section['musicCarouselShelfRenderer'];
        
        if (shelfRenderer != null) {
          // Parse songs
          final items = shelfRenderer['contents'] as List?;
          if (items != null) {
            for (final item in items.take(5)) {
              final song = _parseSongFromShelf(item);
              if (song != null) songs.add(song);
            }
          }
        }
        
        if (carouselRenderer != null) {
          final title = _getText(carouselRenderer['header']?['musicCarouselShelfBasicHeaderRenderer']?['title']);
          final items = carouselRenderer['contents'] as List?;
          
          if (items != null) {
            if (title?.toLowerCase().contains('album') == true || 
                title?.toLowerCase().contains('single') == true) {
              for (final item in items) {
                final album = _parseAlbumFromCarousel(item);
                if (album != null) albums.add(album);
              }
            } else if (title?.toLowerCase().contains('similar') == true ||
                       title?.toLowerCase().contains('fans') == true) {
              for (final item in items) {
                final artist = _parseArtistFromCarousel(item);
                if (artist != null) similarArtists.add(artist);
              }
            }
          }
        }
      }
    }
    
    return ArtistDetails(
      id: artistId,
      name: name,
      description: description,
      thumbnailUrl: thumbnailUrl,
      subscriberCount: subscriberCount,
      songs: songs,
      albums: albums,
      similarArtists: similarArtists,
    );
  } catch (e) {
    Log.error('Failed to parse artist', error: e, tag: 'Content');
    return null;
  }
}

// ============================================================================
// Album Provider
// ============================================================================

/// Album details model
class AlbumDetails {
  final String id;
  final String title;
  final String artistName;
  final String? artistId;
  final String? year;
  final String? thumbnailUrl;
  final String? trackCount;
  final String? duration;
  final List<Song> tracks;

  const AlbumDetails({
    required this.id,
    required this.title,
    required this.artistName,
    this.artistId,
    this.year,
    this.thumbnailUrl,
    this.trackCount,
    this.duration,
    this.tracks = const [],
  });
}

/// Fetch album details by ID
final albumDetailsProvider = FutureProvider.family<AlbumDetails?, String>((ref, albumId) async {
  final client = ref.read(innerTubeClientProvider);
  
  try {
    Log.info('Fetching album: $albumId', tag: 'Content');
    final response = await client.browse(albumId);
    
    return _parseAlbumResponse(albumId, response);
  } catch (e) {
    Log.error('Failed to fetch album', error: e, tag: 'Content');
    return null;
  }
});

AlbumDetails? _parseAlbumResponse(String albumId, Map<String, dynamic> response) {
  try {
    final header = response['header']?['musicDetailHeaderRenderer'] ??
                   response['header']?['musicResponsiveHeaderRenderer'];
    if (header == null) {
      Log.error('Album header not found in response', tag: 'Content');
      return null;
    }
    
    // Get title
    final title = _getText(header['title']) ?? 'Unknown Album';
    
    // Get artist
    final subtitleRuns = header['subtitle']?['runs'] as List?;
    String artistName = 'Unknown Artist';
    String? artistId;
    String? year;
    
    if (subtitleRuns != null) {
      for (final run in subtitleRuns) {
        final text = run['text']?.toString() ?? '';
        final navEndpoint = run['navigationEndpoint']?['browseEndpoint'];
        
        if (navEndpoint != null) {
          artistName = text;
          artistId = navEndpoint['browseId'];
        } else if (RegExp(r'^\d{4}$').hasMatch(text)) {
          year = text;
        }
      }
    }
    
    // Get thumbnail
    String? thumbnailUrl;
    final thumbnailRenderer = header['thumbnail']?['croppedSquareThumbnailRenderer'] ??
                            header['thumbnail']?['musicThumbnailRenderer'];
    final thumbnails = thumbnailRenderer?['thumbnail']?['thumbnails'] as List?;
    if (thumbnails != null && thumbnails.isNotEmpty) {
      thumbnailUrl = thumbnails.last['url'];
    }
    
    // Get metadata
    final secondSubtitle = header['secondSubtitle']?['runs'] as List?;
    String? trackCount;
    String? duration;
    
    if (secondSubtitle != null) {
      for (final run in secondSubtitle) {
        final text = run['text']?.toString() ?? '';
        if (text.contains('song')) {
          trackCount = text;
        } else if (text.contains('minute') || text.contains('hour')) {
          duration = text;
        }
      }
    }
    
    // Parse tracks
    final contents = response['contents']?['singleColumnBrowseResultsRenderer']?['tabs']?[0]
        ?['tabRenderer']?['content']?['sectionListRenderer']?['contents'] as List?;
    
    final tracks = <Song>[];
    
    if (contents != null) {
      for (final section in contents) {
        final shelfContents = section['musicShelfRenderer']?['contents'] as List?;
        if (shelfContents != null) {
          for (int i = 0; i < shelfContents.length; i++) {
            final song = _parseSongFromShelf(shelfContents[i], trackNumber: i + 1);
            if (song != null) tracks.add(song);
          }
        }
      }
    }
    
    return AlbumDetails(
      id: albumId,
      title: title,
      artistName: artistName,
      artistId: artistId,
      year: year,
      thumbnailUrl: thumbnailUrl,
      trackCount: trackCount,
      duration: duration,
      tracks: tracks,
    );
  } catch (e) {
    Log.error('Failed to parse album', error: e, tag: 'Content');
    return null;
  }
}

// ============================================================================
// Helper Parsing Functions
// ============================================================================

String? _getText(dynamic textObj) {
  if (textObj == null) return null;
  if (textObj is String) return textObj;
  if (textObj is Map) {
    final runs = textObj['runs'] as List?;
    if (runs != null && runs.isNotEmpty) {
      return runs.map((r) => r['text']).join('');
    }
  }
  return null;
}

Song? _parseSongFromShelf(Map<String, dynamic> item, {int? trackNumber}) {
  try {
    final renderer = item['musicResponsiveListItemRenderer'];
    if (renderer == null) return null;
    
    // Get video ID
    final overlay = renderer['overlay']?['musicItemThumbnailOverlayRenderer']?['content']
        ?['musicPlayButtonRenderer']?['playNavigationEndpoint']?['watchEndpoint'];
    final videoId = overlay?['videoId']?.toString();
    if (videoId == null) return null;
    
    // Get flex columns
    final columns = renderer['flexColumns'] as List?;
    if (columns == null || columns.isEmpty) return null;
    
    // Title from first column
    final titleRuns = columns[0]['musicResponsiveListItemFlexColumnRenderer']
        ?['text']?['runs'] as List?;
    final title = titleRuns?.firstOrNull?['text']?.toString() ?? 'Unknown';
    
    // Artist from second column
    String artistName = 'Unknown Artist';
    if (columns.length > 1) {
      final artistRuns = columns[1]['musicResponsiveListItemFlexColumnRenderer']
          ?['text']?['runs'] as List?;
      if (artistRuns != null && artistRuns.isNotEmpty) {
        artistName = artistRuns.first['text']?.toString() ?? 'Unknown Artist';
      }
    }
    
    // Thumbnail
    String? thumbnailUrl;
    final thumbnails = renderer['thumbnail']?['musicThumbnailRenderer']
        ?['thumbnail']?['thumbnails'] as List?;
    if (thumbnails != null && thumbnails.isNotEmpty) {
      thumbnailUrl = thumbnails.last['url']?.toString();
    }
    
    // Duration from fixed columns
    Duration duration = Duration.zero;
    final fixedColumns = renderer['fixedColumns'] as List?;
    if (fixedColumns != null && fixedColumns.isNotEmpty) {
      final durationText = _getText(fixedColumns[0]
          ['musicResponsiveListItemFixedColumnRenderer']?['text']);
      if (durationText != null) {
        duration = _parseDuration(durationText);
      }
    }
    
    return Song(
      id: videoId,
      title: title,
      artists: [Artist(id: '', name: artistName)],
      duration: duration,
      thumbnailUrl: thumbnailUrl,
    );
  } catch (e) {
    return null;
  }
}

AlbumInfo? _parseAlbumFromCarousel(Map<String, dynamic> item) {
  try {
    final renderer = item['musicTwoRowItemRenderer'];
    if (renderer == null) return null;
    
    final browseId = renderer['navigationEndpoint']?['browseEndpoint']?['browseId']?.toString();
    if (browseId == null) return null;
    
    final title = _getText(renderer['title']) ?? 'Unknown Album';
    final subtitle = _getText(renderer['subtitle']);
    
    String? thumbnailUrl;
    final thumbnails = renderer['thumbnailRenderer']?['musicThumbnailRenderer']
        ?['thumbnail']?['thumbnails'] as List?;
    if (thumbnails != null && thumbnails.isNotEmpty) {
      thumbnailUrl = thumbnails.last['url']?.toString();
    }
    
    // Extract year from subtitle
    String? year;
    if (subtitle != null) {
      final yearMatch = RegExp(r'\b(\d{4})\b').firstMatch(subtitle);
      year = yearMatch?.group(1);
    }
    
    return AlbumInfo(
      id: browseId,
      title: title,
      year: year,
      thumbnailUrl: thumbnailUrl,
    );
  } catch (e) {
    return null;
  }
}

ArtistInfo? _parseArtistFromCarousel(Map<String, dynamic> item) {
  try {
    final renderer = item['musicTwoRowItemRenderer'];
    if (renderer == null) return null;
    
    final browseId = renderer['navigationEndpoint']?['browseEndpoint']?['browseId']?.toString();
    if (browseId == null) return null;
    
    final name = _getText(renderer['title']) ?? 'Unknown Artist';
    
    String? thumbnailUrl;
    final thumbnails = renderer['thumbnailRenderer']?['musicThumbnailRenderer']
        ?['thumbnail']?['thumbnails'] as List?;
    if (thumbnails != null && thumbnails.isNotEmpty) {
      thumbnailUrl = thumbnails.last['url']?.toString();
    }
    
    return ArtistInfo(
      id: browseId,
      name: name,
      thumbnailUrl: thumbnailUrl,
    );
  } catch (e) {
    return null;
  }
}

Duration _parseDuration(String text) {
  final parts = text.split(':');
  if (parts.length == 2) {
    final minutes = int.tryParse(parts[0]) ?? 0;
    final seconds = int.tryParse(parts[1]) ?? 0;
    return Duration(minutes: minutes, seconds: seconds);
  }
  if (parts.length == 3) {
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    final seconds = int.tryParse(parts[2]) ?? 0;
    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }
  return Duration.zero;
}
