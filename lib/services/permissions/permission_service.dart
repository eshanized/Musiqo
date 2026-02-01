// ============================================================================
// Permission Service - Handle permissions
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:permission_handler/permission_handler.dart';

import '../../core/utils/logger.dart';

/// Service for handling app permissions.
class PermissionService {
  /// Request storage permission for downloads
  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    Log.info('Storage permission: $status');
    return status.isGranted;
  }

  /// Request notification permission
  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    Log.info('Notification permission: $status');
    return status.isGranted;
  }

  /// Check if storage permission is granted
  static Future<bool> get hasStoragePermission async {
    return await Permission.storage.isGranted;
  }

  /// Check if notification permission is granted
  static Future<bool> get hasNotificationPermission async {
    return await Permission.notification.isGranted;
  }

  /// Open app settings
  static Future<void> openSettings() async {
    await openAppSettings();
  }
}
