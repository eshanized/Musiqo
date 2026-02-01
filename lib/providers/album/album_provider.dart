// ============================================================================
// Album Provider - Album data state
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/innertube/youtube_facade.dart';
import '../../services/innertube/parsers/album_parser.dart';
import '../data/youtube_provider.dart';

/// Provider for album details
final albumDetailsProvider = FutureProvider.family<AlbumData?, String>((
  ref,
  albumId,
) async {
  final facade = ref.watch(youtubeFacadeProvider);
  return facade.getAlbumDetails(albumId);
});

/// Provider for album tracks
final albumTracksProvider = FutureProvider.family<List<dynamic>, String>((
  ref,
  albumId,
) async {
  final details = await ref.watch(albumDetailsProvider(albumId).future);
  return details?.tracks ?? [];
});
