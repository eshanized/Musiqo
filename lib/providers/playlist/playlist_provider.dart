// ============================================================================
// Playlist Provider - Playlist data state
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/playlist.dart';
import '../../services/innertube/youtube_facade.dart';
import '../data/youtube_provider.dart';

/// Provider for playlist details
final playlistDetailsProvider = FutureProvider.family<Playlist?, String>((
  ref,
  playlistId,
) async {
  final facade = ref.watch(youtubeFacadeProvider);
  return facade.getPlaylistDetails(playlistId);
});

/// Provider for playlist songs (for large playlists)
final playlistSongsProvider = FutureProvider.family<List<dynamic>, String>((
  ref,
  playlistId,
) async {
  final playlist = await ref.watch(playlistDetailsProvider(playlistId).future);
  return playlist?.songs ?? [];
});
