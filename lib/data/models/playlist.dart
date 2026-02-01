// ============================================================================
// Playlist Model - User-created song collections
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'song.dart';

/// A playlist, which is a collection of songs.
/// Can be local (user-created) or from YouTube Music.
class Playlist {
  /// Unique ID (local or YouTube playlist ID)
  final String id;
  
  /// Name/title of the playlist
  final String name;
  
  /// Optional description
  final String? description;
  
  /// Thumbnail image URL
  final String? thumbnailUrl;
  
  /// Songs in this playlist
  final List<Song> songs;
  
  /// Is this a local playlist or from YouTube?
  final bool isLocal;
  
  /// Who created this playlist
  final String? author;
  
  /// When was this playlist created
  final DateTime? createdAt;
  
  /// Total play time of all songs
  Duration get totalDuration {
    return songs.fold(
      Duration.zero,
      (total, song) => total + song.duration,
    );
  }
  
  /// Number of songs
  int get songCount => songs.length;

  const Playlist({
    required this.id,
    required this.name,
    this.description,
    this.thumbnailUrl,
    this.songs = const [],
    this.isLocal = true,
    this.author,
    this.createdAt,
  });

  /// Create an empty local playlist
  factory Playlist.empty(String name) {
    return Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      isLocal: true,
      createdAt: DateTime.now(),
    );
  }

  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    String? thumbnailUrl,
    List<Song>? songs,
    bool? isLocal,
    String? author,
    DateTime? createdAt,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      songs: songs ?? this.songs,
      isLocal: isLocal ?? this.isLocal,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      songs: (json['songs'] as List<dynamic>?)
              ?.map((s) => Song.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      isLocal: json['isLocal'] as bool? ?? true,
      author: json['author'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'thumbnailUrl': thumbnailUrl,
        'songs': songs.map((s) => s.toJson()).toList(),
        'isLocal': isLocal,
        'author': author,
      };
}
