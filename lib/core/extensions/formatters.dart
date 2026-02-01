// ============================================================================
// Formatters - String and number formatting utilities
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:intl/intl.dart';

/// Duration formatting extensions.
extension DurationFormatters on Duration {
  /// Format as "3:45" or "1:23:45"
  String get formatted {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);
    
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Number formatting extensions.
extension NumberFormatters on int {
  /// Format as "1.2K" or "3.4M"
  String get compact => NumberFormat.compact().format(this);
}

/// Date formatting extensions.
extension DateFormatters on DateTime {
  /// Format as "Jan 15, 2024"
  String get formatted => DateFormat.yMMMd().format(this);
  
  /// Format as relative time "2 hours ago"
  String get relative {
    final now = DateTime.now();
    final diff = now.difference(this);
    
    if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()} years ago';
    } else if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()} months ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} days ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hours ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minutes ago';
    }
    return 'Just now';
  }
}

/// Static helper for formatting (backward compatibility)
class Formatters {
  Formatters._();

  /// Format bytes as human readable file size
  static String fileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
