// ============================================================================
// Download Provider - State management for downloads
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/download/download_service.dart';
import '../../data/repositories/download_repository.dart';
import '../../data/models/song.dart';

final downloadServiceProvider = Provider((ref) => DownloadService());
final downloadRepositoryProvider = Provider((ref) => DownloadRepository());

final downloadedSongsProvider = FutureProvider<List<Song>>((ref) async {
  final repo = ref.watch(downloadRepositoryProvider);
  return repo.getDownloadedSongs();
});

/// Notifier to handle download actions
class DownloadNotifier extends StateNotifier<Map<String, double>> {
  final DownloadService _service;
  final DownloadRepository _repo;
  final Ref _ref;

  // State is a map of SongID -> Progress (0.0 to 1.0)
  DownloadNotifier(this._service, this._repo, this._ref) : super({});

  /// Download a song (placeholder - needs stream URL from YouTubeFacade)
  Future<void> downloadSong(Song song) async {
    if (state.containsKey(song.id)) return; // Already downloading

    // For now, this is a placeholder that shows the feature is available
    // In production, you would:
    // 1. Use YouTubeFacade to get the stream URL
    // 2. Download the audio file
    // 3. Save metadata to database
    throw UnimplementedError(
      'Download feature requires YouTube stream URL. '
      'To implement: inject YouTubeFacade, call getSongStreamUrl(), '
      'then use DownloadService to download the file.'
    );
  }
}

final downloadProvider = StateNotifierProvider<DownloadNotifier, Map<String, double>>((ref) {
  return DownloadNotifier(
    ref.watch(downloadServiceProvider),
    ref.watch(downloadRepositoryProvider),
    ref,
  );
});
