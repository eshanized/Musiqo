// ============================================================================
// Download Service - Manage file downloads
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/utils/logger.dart';

/// Service to handle file downloads (e.g. songs)
class DownloadService {
  final Dio _dio = Dio();
  final Map<String, CancelToken> _cancelTokens = {};

  /// Download a file from [url] to [savePath]
  /// Returns stream of progress (0.0 to 1.0)
  Stream<double> downloadFile({
    required String url,
    required String savePath,
    required String id, // Unique ID for the download (e.g. song ID)
  }) async* {
    if (_cancelTokens.containsKey(id)) {
      Log.warning('Download already in progress for $id', tag: 'Download');
      return;
    }

    final cancelToken = CancelToken();
    _cancelTokens[id] = cancelToken;

    try {
      Log.info('Starting download: $url -> $savePath', tag: 'Download');
      
      // Ensure directory exists
      final directory = Directory(savePath).parent;
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      await _dio.download(
        url,
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
             // Progress handled by Dio, but we can't yield from callback easily
          }
        },
      );
      
      yield 1.0; // Retrieve complete
      Log.success('Download complete: $id', tag: 'Download');
      
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        Log.info('Download cancelled: $id', tag: 'Download');
      } else {
        Log.error('Download failed for $id', error: e, tag: 'Download');
        rethrow;
      }
    } catch (e) {
      Log.error('Download failed for $id', error: e, tag: 'Download');
      rethrow;
    } finally {
      _cancelTokens.remove(id);
    }
  }

  /// Cancel an ongoing download
  void cancelDownload(String id) {
    if (_cancelTokens.containsKey(id)) {
      _cancelTokens[id]?.cancel();
      _cancelTokens.remove(id);
    }
  }

  /// Get standard music directory
  Future<String?> getMusicDirectory() async {
    if (Platform.isAndroid) {
      if (await Permission.audio.request().isGranted || 
          await Permission.storage.request().isGranted) {
        // Try to get external storage
        final dir = await getExternalStorageDirectory();
        return dir?.path;
      }
    } else if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      final dir = await getApplicationDocumentsDirectory();
      return '${dir.path}/Music';
    }
    return null;
  }
}
