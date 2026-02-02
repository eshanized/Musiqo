// ============================================================================
// Lyrics Provider - Riverpod state for lyrics fetching
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../services/lyrics/lyrics_service.dart';
import '../audio/player_provider.dart';

/// Lyrics service provider
final lyricsServiceProvider = Provider<LyricsService>((ref) {
  return LyricsService();
});

/// Current song lyrics provider
/// Automatically fetches lyrics when the current song changes
final currentLyricsProvider = FutureProvider.autoDispose<SongLyrics?>((ref) async {
  final currentSong = ref.watch(currentSongProvider).value;
  
  if (currentSong == null) return null;
  
  final lyricsService = ref.read(lyricsServiceProvider);
  
  return lyricsService.fetchLyrics(
    videoId: currentSong.id,
    title: currentSong.title,
    artist: currentSong.artistName,
  );
});

/// Provider to get the currently active lyric line index
final activeLyricIndexProvider = Provider.autoDispose<int?>((ref) {
  final lyrics = ref.watch(currentLyricsProvider).value;
  final position = ref.watch(positionProvider).value ?? Duration.zero;
  
  if (lyrics == null || lyrics.isEmpty) return null;
  
  return lyrics.getActiveLineIndex(position);
});
