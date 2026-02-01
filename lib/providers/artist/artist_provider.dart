// ============================================================================
// Artist Provider - Artist data state
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/innertube/youtube_facade.dart';
import '../../services/innertube/parsers/artist_parser.dart';
import '../data/youtube_provider.dart';

/// Provider for artist details
final artistDetailsProvider = FutureProvider.family<ArtistData?, String>((
  ref,
  artistId,
) async {
  final facade = ref.watch(youtubeFacadeProvider);
  return facade.getArtistDetails(artistId);
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
final artistAlbumsProvider = FutureProvider.family<List<AlbumPreview>, String>((
  ref,
  artistId,
) async {
  final details = await ref.watch(artistDetailsProvider(artistId).future);
  return details?.albums ?? [];
});
