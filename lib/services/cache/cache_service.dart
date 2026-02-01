// ============================================================================
// Cache Service - Manage app cache
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../core/utils/logger.dart';

/// Service for managing app cache.
class CacheService {
  /// Clear image cache
  static Future<void> clearImageCache() async {
    await DefaultCacheManager().emptyCache();
    Log.info('Image cache cleared');
  }

  /// Get cache size
  static Future<int> getCacheSize() async {
    final cacheDir = await getTemporaryDirectory();
    return _getDirectorySize(cacheDir);
  }

  /// Clear all cache
  static Future<void> clearAllCache() async {
    final cacheDir = await getTemporaryDirectory();

    if (await cacheDir.exists()) {
      await for (final entity in cacheDir.list()) {
        if (entity is File) {
          await entity.delete();
        } else if (entity is Directory) {
          await entity.delete(recursive: true);
        }
      }
    }

    Log.info('All cache cleared');
  }

  /// Get directory size recursively
  static int _getDirectorySize(Directory dir) {
    int size = 0;

    try {
      if (dir.existsSync()) {
        for (final entity in dir.listSync(recursive: true)) {
          if (entity is File) {
            size += entity.lengthSync();
          }
        }
      }
    } catch (e) {
      Log.warning('Error calculating directory size: $e');
    }

    return size;
  }
}
