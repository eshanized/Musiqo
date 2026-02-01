// ============================================================================
// Connectivity Service - Check network state
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/utils/logger.dart';

/// Service for monitoring network connectivity.
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Stream of connectivity changes
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((results) {
      return results.any((r) => r != ConnectivityResult.none);
    });
  }

  /// Check current connectivity
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result.any((r) => r != ConnectivityResult.none);
  }

  /// Check if on WiFi
  Future<bool> get isOnWifi async {
    final result = await _connectivity.checkConnectivity();
    return result.contains(ConnectivityResult.wifi);
  }

  /// Start listening for changes
  void startListening(void Function(bool isConnected) onChanged) {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final connected = results.any((r) => r != ConnectivityResult.none);
      Log.info('Connectivity changed: $connected');
      onChanged(connected);
    });
  }

  /// Stop listening
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }
}
