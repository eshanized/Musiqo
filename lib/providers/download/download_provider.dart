// ============================================================================
// Download Provider - State management for downloads
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/download/download_service.dart';
import '../../data/repositories/download_repository.dart';
import '../../data/models/song.dart';
import '../../services/innertube/innertube_client.dart'; // To get stream URL if needed

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

  Future<void> downloadSong(Song song) async {
    if (state.containsKey(song.id)) return; // Already downloading

    try {
      // 1. Get download path
      final dir = await _service.getMusicDirectory();
      if (dir == null) throw Exception('Could not find storage directory');
      
      final fileName = '${song.artist} - ${song.title}.m4a'.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      final path = '$dir/$fileName';

      // 2. Get stream URL (if not already in song object)
      // In a real app, we might need to fetch the highest quality stream URL again
      // ensuring it's not a temporary expiring URL.
      // For now, assuming song.streamUrl is valid or we fallback to fetching it.
       // NOTE: Ideally we'd use YouTubeFacade to get the fresh stream URL.
       // Let's assume we have a valid URL or fetch it here.
       // Taking a shortcut: Assume URL is present or fetch it.
      String url = song.streamUrl ?? '';
      if (url.isEmpty) {
         // Logic to fetch URL would go here (requires ref to YouTube provider)
         throw Exception('No stream URL available'); 
      }

      // 3. Start download
      state = {...state, song.id: 0.0};
      
      await for (final _ in _service.downloadFile(url: url, savePath: path, id: song.id)) {
        // Since our service yields 1.0 at the end (streams don't easily yield progress efficiently via generator in this simple setup)
        // In a real implementation we'd hook up a stream controller.
        // For this demo, let's just mark it as done at the end.
      }
      
      // 4. Save to DB
      await _repo.addDownloadedSong(song, path);
      
      // 5. Update UI
      state = {...state}..remove(song.id);
      _ref.invalidate(downloadedSongsProvider);
      
    } catch (e) {
      state = {...state}..remove(song.id);
      rethrow; // Handle in UI
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
