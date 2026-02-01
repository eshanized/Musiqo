// ============================================================================
// Debouncer - Rate limiting for search and other inputs
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
//
// Ever noticed how Google doesn't search after every keystroke?
// That's debouncing - waiting for the user to stop typing.
// ============================================================================

import 'dart:async';

/// A simple debouncer that delays execution.
/// 
/// HOW IT WORKS:
/// When you call debouncer.run(myFunction), it doesn't run immediately.
/// Instead, it waits for the delay. If you call run() again before
/// the delay is over, it cancels the previous one and starts fresh.
/// 
/// EXAMPLE:
/// ```dart
/// final debouncer = Debouncer(milliseconds: 400);
/// 
/// void onSearchChanged(String query) {
///   debouncer.run(() {
///     // This only runs 400ms after the user stops typing
///     searchApi(query);
///   });
/// }
/// ```
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({this.milliseconds = 300});

  /// Run the action after the delay
  void run(void Function() action) {
    // Cancel any existing timer
    _timer?.cancel();
    
    // Start a new timer
    _timer = Timer(
      Duration(milliseconds: milliseconds),
      action,
    );
  }

  /// Cancel any pending action
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Clean up when done
  void dispose() {
    cancel();
  }
}
