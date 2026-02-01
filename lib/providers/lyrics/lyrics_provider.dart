// ============================================================================
// Lyrics Provider - State for lyrics
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/lyrics.dart';
import '../../services/lyrics/lyrics_service.dart';
import '../audio/player_provider.dart';

/// Provider for lyrics service
final lyricsServiceProvider = Provider<LyricsService>((ref) {
  return LyricsService();
});

/// Provider for current song lyrics
final currentLyricsProvider = FutureProvider<Lyrics?>((ref) async {
  final currentSongAsync = ref.watch(currentSongProvider);

  return currentSongAsync.when(
    data: (song) async {
      if (song == null) return null;
      final service = ref.watch(lyricsServiceProvider);
      return service.fetchLyrics(
        title: song.title,
        artist: song.artistName,
        duration: song.duration,
      );
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider for lyrics by song ID
final lyricsProvider = FutureProvider.family<Lyrics?, String>((
  ref,
  songId,
) async {
  // Fetch lyrics by song ID from cache or API
  return null;
});
