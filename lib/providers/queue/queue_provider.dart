// ============================================================================
// Queue Provider - Playback queue state
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/song.dart';
import '../../data/models/queue.dart';

/// Provider for current playback queue
final queueProvider = StateNotifierProvider<QueueNotifier, PlaybackQueue>(
  (ref) => QueueNotifier(),
);

/// Notifier for queue management
class QueueNotifier extends StateNotifier<PlaybackQueue> {
  QueueNotifier() : super(const PlaybackQueue());

  /// Set the queue
  void setQueue(List<Song> songs, {int startIndex = 0}) {
    state = PlaybackQueue(
      songs: songs,
      currentIndex: startIndex,
      isShuffled: false,
    );
  }

  /// Add song to queue
  void addToQueue(Song song) {
    state = state.copyWith(songs: [...state.songs, song]);
  }

  /// Remove song from queue
  void removeFromQueue(int index) {
    if (index < 0 || index >= state.songs.length) return;

    final newSongs = List<Song>.from(state.songs)..removeAt(index);
    var newIndex = state.currentIndex;
    if (index < state.currentIndex) {
      newIndex--;
    }

    state = state.copyWith(
      songs: newSongs,
      currentIndex: newIndex.clamp(0, newSongs.length - 1),
    );
  }

  /// Move to next
  void next() {
    if (state.hasNext) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  /// Move to previous
  void previous() {
    if (state.hasPrevious) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  /// Skip to index
  void skipToIndex(int index) {
    if (index >= 0 && index < state.songs.length) {
      state = state.copyWith(currentIndex: index);
    }
  }

  /// Shuffle queue
  void shuffle() {
    if (state.songs.isEmpty) return;

    final current = state.songs[state.currentIndex];
    final shuffled = List<Song>.from(state.songs)..shuffle();
    shuffled.remove(current);
    shuffled.insert(0, current);

    state = PlaybackQueue(
      songs: shuffled,
      currentIndex: 0,
      originalOrder: state.isShuffled ? state.originalOrder : state.songs,
      isShuffled: true,
    );
  }

  /// Unshuffle queue
  void unshuffle() {
    if (!state.isShuffled || state.originalOrder == null) return;

    final current = state.currentSong;
    final original = state.originalOrder!;
    final newIndex = current != null
        ? original.indexWhere((s) => s.id == current.id)
        : 0;

    state = PlaybackQueue(
      songs: original,
      currentIndex: newIndex >= 0 ? newIndex : 0,
      isShuffled: false,
    );
  }

  /// Clear queue
  void clear() {
    state = const PlaybackQueue();
  }
}
