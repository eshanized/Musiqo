// ============================================================================
// Logger - A simple logging utility
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
//
// Logs are your best friend when debugging. This logger adds
// nice formatting and emojis to make logs easier to read.
// ============================================================================

import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

/// Simple logger with different log levels and pretty formatting.
/// 
/// DEBUG MODE ONLY:
/// In release builds, logs are disabled for performance and security.
/// You don't want users seeing your debug messages!
class Log {
  Log._();
  
  /// Log an info message (blue)
  static void info(String message, {String? tag}) {
    _log('ℹ️', message, tag: tag);
  }

  /// Log a debug message (gray) - for detailed dev logging
  static void debug(String message, {String? tag}) {
    _log('🔍', message, tag: tag);
  }
  
  /// Log a success message (green)
  static void success(String message, {String? tag}) {
    _log('✅', message, tag: tag);
  }
  
  /// Log a warning (yellow)
  static void warning(String message, {String? tag}) {
    _log('⚠️', message, tag: tag);
  }
  
  /// Log an error (red)
  static void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    _log('❌', message, tag: tag);
    if (error != null) {
      _log('💥', error.toString(), tag: tag);
    }
    if (stackTrace != null && kDebugMode) {
      dev.log(stackTrace.toString());
    }
  }
  
  /// Log network request
  static void network(String method, String url, {int? statusCode}) {
    final status = statusCode != null ? '[$statusCode]' : '';
    _log('🌐', '$method $url $status', tag: 'Network');
  }
  
  /// Log database operation
  static void database(String operation, {String? tag}) {
    _log('💾', operation, tag: tag ?? 'Database');
  }
  
  /// Log audio player event
  static void audio(String event) {
    _log('🎵', event, tag: 'Audio');
  }
  
  // Internal logging method
  static void _log(String emoji, String message, {String? tag}) {
    if (!kDebugMode) return;  // Silent in release mode
    
    final prefix = tag != null ? '[$tag]' : '';
    final fullMessage = '$emoji $prefix $message';
    
    // ignore: avoid_print
    print(fullMessage);  // Show in terminal
    dev.log(fullMessage);
  }
}
