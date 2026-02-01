// ============================================================================
// Download Provider - State for downloads
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/download.dart';
import '../../data/models/song.dart';
import '../../services/download/download_service.dart';
import '../../data/repositories/download_repository.dart';
import '../../data/database/collections/download_entity.dart';

/// Provider for download service
final downloadServiceProvider = Provider<DownloadService>((ref) {
  return DownloadService();
});

/// Provider for download repository
final downloadRepositoryProvider = Provider<DownloadRepository>((ref) {
  return DownloadRepository();
});

/// Provider for all downloads
final downloadsProvider = FutureProvider<List<DownloadEntity>>((ref) async {
  final repo = ref.watch(downloadRepositoryProvider);
  return repo.getDownloads();
});

/// Check if song is downloaded
final isDownloadedProvider = FutureProvider.family<bool, String>((
  ref,
  songId,
) async {
  final repo = ref.watch(downloadRepositoryProvider);
  return repo.isDownloaded(songId);
});

/// Active downloads state
final activeDownloadsProvider =
    StateNotifierProvider<ActiveDownloadsNotifier, Map<String, Download>>(
      (ref) => ActiveDownloadsNotifier(ref.watch(downloadServiceProvider)),
    );

/// Notifier for active downloads
class ActiveDownloadsNotifier extends StateNotifier<Map<String, Download>> {
  final DownloadService _downloadService;

  ActiveDownloadsNotifier(this._downloadService) : super({});

  /// Start a download
  Future<void> startDownload(Song song) async {
    final download = Download(
      id: song.id,
      song: song,
      status: DownloadStatus.downloading,
      createdAt: DateTime.now(),
    );

    state = {...state, song.id: download};

    final result = await _downloadService.download(
      song,
      onProgress: (progress) {
        state = {
          ...state,
          song.id: state[song.id]!.copyWith(progress: progress),
        };
      },
    );

    state = {...state, song.id: result};

    // Remove from active after completion
    if (result.isComplete || result.hasFailed) {
      await Future.delayed(const Duration(seconds: 2));
      state = Map.from(state)..remove(song.id);
    }
  }

  /// Cancel a download
  void cancelDownload(String songId) {
    _downloadService.cancel(songId);
    state = Map.from(state)..remove(songId);
  }
}
