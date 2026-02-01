// ============================================================================
// Haptic Feedback Helper
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/services.dart';

/// Helper for haptic feedback.
class Haptics {
  Haptics._();

  /// Light impact
  static void light() {
    HapticFeedback.lightImpact();
  }

  /// Medium impact
  static void medium() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy impact
  static void heavy() {
    HapticFeedback.heavyImpact();
  }

  /// Selection click
  static void selection() {
    HapticFeedback.selectionClick();
  }

  /// Vibrate
  static void vibrate() {
    HapticFeedback.vibrate();
  }
}
