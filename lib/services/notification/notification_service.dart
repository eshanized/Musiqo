// ============================================================================
// Notification Service - Real implementation using flutter_local_notifications
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../core/utils/logger.dart';

/// Service for displaying system notifications.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  bool _initialized = false;

  /// Android notification channel for main notifications
  static const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
    'musiqo_main',
    'Musiqo Notifications',
    description: 'Notifications for downloads and updates',
    importance: Importance.defaultImportance,
  );

  /// Initialize the notification service
  Future<void> init() async {
    if (_initialized) return;
    
    try {
      // Android initialization
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS/macOS initialization
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      // Linux initialization
      const linuxSettings = LinuxInitializationSettings(
        defaultActionName: 'Open',
      );
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
        linux: linuxSettings,
      );
      
      await _notifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      
      // Create notification channel on Android
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(_androidChannel);
      
      _initialized = true;
      Log.info('Notification service initialized');
    } catch (e) {
      Log.error('Failed to initialize notifications: $e');
      _initialized = true; // Mark as initialized to prevent repeated attempts
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    Log.debug('Notification tapped: ${response.payload}');
    // Navigation can be handled here if needed
  }

  /// Show a notification
  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await init();
    
    try {
      const androidDetails = AndroidNotificationDetails(
        'musiqo_main',
        'Musiqo Notifications',
        channelDescription: 'Notifications for downloads and updates',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      );
      
      const linuxDetails = LinuxNotificationDetails();
      
      const details = NotificationDetails(
        android: androidDetails,
        linux: linuxDetails,
      );
      
      await _notifications.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload,
      );
      Log.debug('Notification shown: $title');
    } catch (e) {
      Log.error('Failed to show notification: $e');
    }
  }

  /// Show download complete notification
  Future<void> showDownloadComplete(String songTitle) async {
    await show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: 'Download Complete',
      body: '$songTitle is ready for offline playback',
      payload: 'download_complete',
    );
  }

  /// Show download progress notification
  Future<void> showDownloadProgress(String songTitle, int progress) async {
    final androidDetails = AndroidNotificationDetails(
      'musiqo_downloads',
      'Downloads',
      channelDescription: 'Download progress notifications',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: 100,
      progress: progress,
      ongoing: true,
      icon: '@mipmap/ic_launcher',
    );
    
    final details = NotificationDetails(android: androidDetails);
    
    await _notifications.show(
      id: 0, // Use fixed ID for progress
      title: 'Downloading',
      body: songTitle,
      notificationDetails: details,
    );
  }

  /// Cancel a notification
  Future<void> cancel(int id) async {
    try {
      await _notifications.cancel(id: id);
    } catch (e) {
      Log.error('Failed to cancel notification: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {
      Log.error('Failed to cancel all notifications: $e');
    }
  }
}
