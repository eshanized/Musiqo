// ============================================================================
// Sleep Timer Service
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'dart:async';

import '../../core/utils/logger.dart';

/// Service for sleep timer functionality.
class SleepTimerService {
  static final SleepTimerService _instance = SleepTimerService._internal();
  factory SleepTimerService() => _instance;
  SleepTimerService._internal();

  Timer? _timer;
  DateTime? _endTime;
  void Function()? _onComplete;

  /// Check if timer is active
  bool get isActive => _timer != null && _timer!.isActive;

  /// Get remaining time
  Duration get remaining {
    if (_endTime == null) return Duration.zero;
    final diff = _endTime!.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Start sleep timer
  void start(Duration duration, {void Function()? onComplete}) {
    cancel();

    _endTime = DateTime.now().add(duration);
    _onComplete = onComplete;

    _timer = Timer(duration, () {
      Log.info('Sleep timer completed');
      _onComplete?.call();
      cancel();
    });

    Log.info('Sleep timer started for ${duration.inMinutes} minutes');
  }

  /// Cancel the timer
  void cancel() {
    _timer?.cancel();
    _timer = null;
    _endTime = null;
    _onComplete = null;
  }
}
