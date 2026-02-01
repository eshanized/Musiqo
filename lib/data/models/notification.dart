// ============================================================================
// Notification Types
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

/// Types of app notifications
enum NotificationType {
  newRelease,
  playlistUpdate,
  recommendation,
  downloadComplete,
}

/// App notification
class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String? imageUrl;
  final String? actionRoute;
  final DateTime createdAt;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.imageUrl,
    this.actionRoute,
    required this.createdAt,
    this.isRead = false,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      imageUrl: imageUrl,
      actionRoute: actionRoute,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
