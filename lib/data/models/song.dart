// ============================================================================
// Song Model - The core data model for a song
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
//
// This is one of the most important models in the app.
// It represents all the information about a single song.
// ============================================================================

/// Represents a song/track from YouTube Music.
/// 
/// WHAT'S A MODEL?
/// A model is just a class that holds data. Think of it as a container
/// that groups related information together. Instead of passing around
/// 10 different variables, you pass one Song object.
class Song {
  /// YouTube video ID - this is unique for each song
  final String id;
  
  /// The song's title
  final String title;
  
  /// List of artists who made this song
  final List<Artist> artists;
  
  /// Album this song belongs to (optional, singles don't have albums)
  final Album? album;
  
  /// How long the song is
  final Duration duration;
  
  /// URL to the thumbnail image (album art)
  final String? thumbnailUrl;
  
  /// Is this an explicit/adult song?
  final bool isExplicit;
  
  /// High quality thumbnail for player screen
  final String? thumbnailMaxRes;
  
  /// For local tracks only - file path
  final String? localPath;
  
  /// When was this song added to library (null if not in library)
  final DateTime? addedAt;
  
  /// Play count (for stats)
  final int playCount;

  const Song({
    required this.id,
    required this.title,
    required this.artists,
    this.album,
    required this.duration,
    this.thumbnailUrl,
    this.isExplicit = false,
    this.thumbnailMaxRes,
    this.localPath,
    this.addedAt,
    this.playCount = 0,
  });

  /// Get the main artist name (first artist)
  String get artistName {
    if (artists.isEmpty) return 'Unknown Artist';
    return artists.first.name;
  }

  /// Get all artist names joined with ", "
  String get artistsText {
    if (artists.isEmpty) return 'Unknown Artist';
    return artists.map((a) => a.name).join(', ');
  }

  /// Get a short description like "Artist • Album"
  String get subtitle {
    final parts = <String>[artistName];
    if (album != null) parts.add(album!.name);
    return parts.join(' • ');
  }

  /// Is this song downloaded for offline play?
  bool get isDownloaded => localPath != null;

  /// Copy this song with some fields changed
  /// 
  /// WHY COPYTWITH?
  /// Objects are often immutable (can't be changed after creation).
  /// When you need to "modify" something, you create a new copy
  /// with the changes. This is safer and prevents bugs.
  Song copyWith({
    String? id,
    String? title,
    List<Artist>? artists,
    Album? album,
    Duration? duration,
    String? thumbnailUrl,
    bool? isExplicit,
    String? thumbnailMaxRes,
    String? localPath,
    DateTime? addedAt,
    int? playCount,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artists: artists ?? this.artists,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isExplicit: isExplicit ?? this.isExplicit,
      thumbnailMaxRes: thumbnailMaxRes ?? this.thumbnailMaxRes,
      localPath: localPath ?? this.localPath,
      addedAt: addedAt ?? this.addedAt,
      playCount: playCount ?? this.playCount,
    );
  }

  /// Create from JSON (for API responses)
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String,
      title: json['title'] as String,
      artists: (json['artists'] as List<dynamic>?)
              ?.map((a) => Artist.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      album: json['album'] != null
          ? Album.fromJson(json['album'] as Map<String, dynamic>)
          : null,
      duration: Duration(seconds: json['duration'] as int? ?? 0),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      isExplicit: json['isExplicit'] as bool? ?? false,
    );
  }

  /// Convert to JSON (for saving)
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artists': artists.map((a) => a.toJson()).toList(),
        'album': album?.toJson(),
        'duration': duration.inSeconds,
        'thumbnailUrl': thumbnailUrl,
        'isExplicit': isExplicit,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Song(id: $id, title: $title)';
}

/// Basic artist info (used within Song)
class Artist {
  final String id;
  final String name;
  final String? thumbnailUrl;

  const Artist({
    required this.id,
    required this.name,
    this.thumbnailUrl,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'] as String? ?? '',
      name: json['name'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'thumbnailUrl': thumbnailUrl,
      };
}

/// Basic album info (used within Song)
class Album {
  final String id;
  final String name;
  final String? thumbnailUrl;
  final int? year;

  const Album({
    required this.id,
    required this.name,
    this.thumbnailUrl,
    this.year,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'] as String? ?? '',
      name: json['name'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      year: json['year'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'thumbnailUrl': thumbnailUrl,
        'year': year,
      };
}
