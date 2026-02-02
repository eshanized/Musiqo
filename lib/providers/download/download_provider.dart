// ============================================================================
// Download Provider - State management for downloads
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/download/download_service.dart';
import '../../data/repositories/download_repository.dart';
import '../../data/models/song.dart';
import '../../core/utils/logger.dart';
import '../../providers/data/youtube_provider.dart';

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

  /// Download a song
  Future<void> downloadSong(Song song) async {
    if (state.containsKey(song.id)) return; // Already downloading

    try {
      Log.info('Starting download for ${song.title}', tag: 'Download');
      final youtube = _ref.read(youtubeProvider);
      
      // 1. Get Stream URL
      final details = await youtube.getSongDetails(song.id);
      if (details?.streamUrl == null) {
        throw Exception('Could not get stream URL');
      }

      // 2. Get save path
      final dir = await _service.getMusicDirectory();
      if (dir == null) throw Exception('Storage not accessible');
      
      final cleanTitle = song.title.replaceAll(RegExp(r'[^\w\s\-]'), '').trim();
      final filePath = '$dir/$cleanTitle.m4a';
      
      state = {...state, song.id: 0.0};

      // 3. Download
      await for (final progress in _service.downloadFile(
        url: details!.streamUrl!, 
        savePath: filePath, 
        id: song.id,
      )) {
        state = {...state, song.id: progress};
      }

      // 4. Save metadata
      await _repo.addDownloadedSong(song, filePath);
      
      Log.success('Download complete: ${song.title}', tag: 'Download');
    } catch (e) {
      Log.error('Download failed', error: e, tag: 'Download');
    } finally {
      final newState = {...state};
      newState.remove(song.id);
      state = newState;
    }
  }
}

final downloadProvider = StateNotifierProvider<DownloadNotifier, Map<String, double>>((ref) {
  return DownloadNotifier(
    ref.watch(downloadServiceProvider),
    ref.watch(downloadRepositoryProvider),
    ref,
  );
});
