// ============================================================================
// Artist Provider - Artist data state
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/innertube/pages/artist_page.dart';
import '../data/youtube_provider.dart';

/// Provider for artist details
final artistDetailsProvider = FutureProvider.family<ArtistPage?, String>((
  ref,
  artistId,
) async {
  final facade = ref.watch(youtubeProvider);
  return facade.getArtist(artistId);
});

/// Provider for artist's top songs
final artistTopSongsProvider = FutureProvider.family<List<dynamic>, String>((
  ref,
  artistId,
) async {
  final details = await ref.watch(artistDetailsProvider(artistId).future);
  return details?.topSongs ?? [];
});

/// Provider for artist's albums
final artistAlbumsProvider = FutureProvider.family<List<ArtistAlbum>, String>((
  ref,
  artistId,
) async {
  final details = await ref.watch(artistDetailsProvider(artistId).future);
  return details?.albums ?? [];
});
