// ============================================================================
// Number Extensions
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

/// Extensions for num (int/double).
extension NumExtensions on num {
  /// Create a SizedBox with this height
  SizedBox get height => SizedBox(height: toDouble());

  /// Create a SizedBox with this width
  SizedBox get width => SizedBox(width: toDouble());

  /// Create a Duration of this many milliseconds
  Duration get ms => Duration(milliseconds: round());

  /// Create a Duration of this many seconds
  Duration get seconds => Duration(seconds: round());

  /// Create a Duration of this many minutes
  Duration get minutes => Duration(minutes: round());
}

/// Extensions for int specifically.
extension IntExtensions on int {
  /// Format with commas (e.g., 1,234,567)
  String get formatted {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  /// Format as compact (e.g., 1.2K, 3.4M)
  String get compact {
    if (this >= 1000000000) {
      return '${(this / 1000000000).toStringAsFixed(1)}B';
    }
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    }
    if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }
}
