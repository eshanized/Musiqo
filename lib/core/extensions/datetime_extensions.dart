// ============================================================================
// Date/Time Extensions
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:intl/intl.dart';

/// Extensions for DateTime class.
extension DateTimeExtensions on DateTime {
  /// Format as short date (e.g., "Jan 15")
  String get shortDate => DateFormat('MMM d').format(this);

  /// Format as long date (e.g., "January 15, 2024")
  String get longDate => DateFormat('MMMM d, y').format(this);

  /// Format as time (e.g., "3:45 PM")
  String get time => DateFormat('h:mm a').format(this);

  /// Format as relative time (e.g., "2 hours ago", "Yesterday")
  String get relative {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';

    return shortDate;
  }

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }
}
