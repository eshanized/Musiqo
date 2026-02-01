// ============================================================================
// Queue Model - Playback queue state
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'song.dart';

/// Represents the current playback queue.
class PlaybackQueue {
  final List<Song> songs;
  final int currentIndex;
  final List<Song>? originalOrder;
  final bool isShuffled;

  const PlaybackQueue({
    this.songs = const [],
    this.currentIndex = 0,
    this.originalOrder,
    this.isShuffled = false,
  });

  /// Current song
  Song? get currentSong {
    if (currentIndex >= 0 && currentIndex < songs.length) {
      return songs[currentIndex];
    }
    return null;
  }

  /// Has next song
  bool get hasNext => currentIndex < songs.length - 1;

  /// Has previous song
  bool get hasPrevious => currentIndex > 0;

  /// Upcoming songs (after current)
  List<Song> get upcoming {
    if (currentIndex >= songs.length - 1) return [];
    return songs.sublist(currentIndex + 1);
  }

  PlaybackQueue copyWith({
    List<Song>? songs,
    int? currentIndex,
    List<Song>? originalOrder,
    bool? isShuffled,
  }) {
    return PlaybackQueue(
      songs: songs ?? this.songs,
      currentIndex: currentIndex ?? this.currentIndex,
      originalOrder: originalOrder ?? this.originalOrder,
      isShuffled: isShuffled ?? this.isShuffled,
    );
  }
}
