// ============================================================================
// Download Service - Download manager for offline music
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/song.dart';
import '../../data/models/download.dart';
import '../../data/repositories/download_repository.dart';
import '../../core/utils/logger.dart';
import '../innertube/youtube_facade.dart';

/// Service for downloading songs for offline playback.
class DownloadService {
  final Dio _dio = Dio();
  final DownloadRepository _repository = DownloadRepository();
  final YouTubeFacade _youtube = YouTubeFacade();

  final Map<String, CancelToken> _activeDownloads = {};

  /// Download a song
  Future<Download> download(
    Song song, {
    void Function(double)? onProgress,
  }) async {
    Log.info('Starting download: ${song.title}');

    final download = Download(
      id: song.id,
      song: song,
      status: DownloadStatus.downloading,
      createdAt: DateTime.now(),
    );

    try {
      // Get stream URL
      final details = await _youtube.getSongDetails(song.id);
      if (details?.streamUrl == null) {
        throw Exception('Could not get stream URL');
      }

      // Create download directory
      final dir = await _getDownloadDirectory();
      final filePath = '${dir.path}/${song.id}.m4a';

      // Download with progress
      final cancelToken = CancelToken();
      _activeDownloads[song.id] = cancelToken;

      await _dio.download(
        details!.streamUrl!,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            onProgress?.call(progress);
          }
        },
      );

      _activeDownloads.remove(song.id);

      // Get file size
      final file = File(filePath);
      final fileSize = await file.length();

      // Save to database
      await _repository.saveDownload(
        songId: song.id,
        title: song.title,
        artistName: song.artistName,
        thumbnailUrl: song.thumbnailUrl,
        filePath: filePath,
        fileSize: fileSize,
        quality: details.mimeType,
      );

      Log.success('Download complete: ${song.title}');

      return download.copyWith(
        status: DownloadStatus.complete,
        progress: 1.0,
        filePath: filePath,
      );
    } catch (e) {
      Log.error('Download failed: ${song.title}', error: e);
      _activeDownloads.remove(song.id);

      return download.copyWith(
        status: DownloadStatus.failed,
        error: e.toString(),
      );
    }
  }

  /// Cancel a download
  void cancel(String songId) {
    final token = _activeDownloads[songId];
    if (token != null) {
      token.cancel('User cancelled');
      _activeDownloads.remove(songId);
    }
  }

  /// Delete a download
  Future<void> delete(String songId) async {
    final path = await _repository.getDownloadPath(songId);
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
    await _repository.deleteDownload(songId);
  }

  /// Check if song is downloaded
  Future<bool> isDownloaded(String songId) {
    return _repository.isDownloaded(songId);
  }

  /// Get download directory
  Future<Directory> _getDownloadDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${appDir.path}/downloads');

    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }

    return downloadDir;
  }
}
