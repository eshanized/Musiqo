// ============================================================================
// Album Provider - Album data state
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/innertube/pages/album_page.dart';
import '../data/youtube_provider.dart';

/// Provider for album details
final albumDetailsProvider = FutureProvider.family<AlbumPage?, String>((
  ref,
  albumId,
) async {
  final facade = ref.watch(youtubeProvider);
  return facade.getAlbum(albumId);
});

/// Provider for album tracks
final albumTracksProvider = FutureProvider.family<List<dynamic>, String>((
  ref,
  albumId,
) async {
  final details = await ref.watch(albumDetailsProvider(albumId).future);
  return details?.tracks ?? [];
});
