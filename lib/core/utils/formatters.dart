// ============================================================================
// Formatters - Number and text formatting utilities
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:intl/intl.dart';

/// Various formatters for numbers, dates, and counts.
class Formatters {
  Formatters._();

  /// Format a number with commas: 1000000 -> "1,000,000"
  static String number(int value) {
    return NumberFormat('#,###').format(value);
  }
  
  /// Format play count in a compact way: 1500000 -> "1.5M views"
  static String playCount(int count) {
    if (count >= 1000000000) {
      return '${(count / 1000000000).toStringAsFixed(1)}B plays';
    } else if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M plays';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K plays';
    }
    return '$count plays';
  }
  
  /// Format subscriber/follower count
  static String subscriberCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M subscribers';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K subscribers';
    }
    return '$count subscribers';
  }
  
  /// Format file size: 10485760 bytes -> "10 MB"
  static String fileSize(int bytes) {
    if (bytes >= 1073741824) {
      return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
    } else if (bytes >= 1048576) {
      return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '$bytes B';
  }
  
  /// Format relative time: "2 hours ago", "Just now"
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${difference.inDays >= 730 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${difference.inDays >= 60 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min ago';
    } else {
      return 'Just now';
    }
  }
  
  /// Format date: "Jan 15, 2024"
  static String date(DateTime dateTime) {
    return DateFormat.yMMMd().format(dateTime);
  }
  
  /// Format album/playlist stats: "12 songs • 45 min"
  static String playlistStats(int songCount, Duration totalDuration) {
    final songs = '$songCount song${songCount != 1 ? 's' : ''}';
    
    if (totalDuration.inHours > 0) {
      final hours = totalDuration.inHours;
      final minutes = totalDuration.inMinutes.remainder(60);
      return '$songs • $hours hr ${minutes > 0 ? '$minutes min' : ''}';
    } else {
      return '$songs • ${totalDuration.inMinutes} min';
    }
  }
}
