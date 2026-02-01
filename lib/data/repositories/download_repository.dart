// ============================================================================
// Download Repository - Downloaded songs data
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:isar/isar.dart';

import '../database/database_service.dart';
import '../database/collections/download_entity.dart';

/// Repository for downloaded songs.
class DownloadRepository {
  Isar get _db => DatabaseService.instance;

  /// Get all downloads
  Future<List<DownloadEntity>> getDownloads() async {
    return _db.downloadEntitys.where().sortByDownloadedAtDesc().findAll();
  }

  /// Check if song is downloaded
  Future<bool> isDownloaded(String songId) async {
    final entity = await _db.downloadEntitys
        .filter()
        .songIdEqualTo(songId)
        .findFirst();
    return entity != null;
  }

  /// Get download path
  Future<String?> getDownloadPath(String songId) async {
    final entity = await _db.downloadEntitys
        .filter()
        .songIdEqualTo(songId)
        .findFirst();
    return entity?.filePath;
  }

  /// Save download info
  Future<void> saveDownload({
    required String songId,
    required String title,
    required String artistName,
    String? thumbnailUrl,
    required String filePath,
    required int fileSize,
    String? quality,
  }) async {
    final entity = DownloadEntity()
      ..songId = songId
      ..title = title
      ..artistName = artistName
      ..thumbnailUrl = thumbnailUrl
      ..filePath = filePath
      ..fileSize = fileSize
      ..quality = quality
      ..downloadedAt = DateTime.now();

    await _db.writeTxn(() async {
      await _db.downloadEntitys.put(entity);
    });
  }

  /// Delete download
  Future<void> deleteDownload(String songId) async {
    await _db.writeTxn(() async {
      await _db.downloadEntitys.filter().songIdEqualTo(songId).deleteAll();
    });
  }

  /// Get total download size
  Future<int> getTotalSize() async {
    final downloads = await getDownloads();
    return downloads.fold(0, (sum, d) => sum + d.fileSize);
  }
}
