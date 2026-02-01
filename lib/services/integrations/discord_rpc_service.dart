// ============================================================================
// Discord RPC Service - Stub implementation
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
//
// Note: Discord RPC requires the dart_discord_rpc package which is not 
// currently installed. This is a stub that provides the interface without
// actual Discord integration.
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/logger.dart';

final discordRpcServiceProvider = Provider((ref) => DiscordRpcService());

/// Stub service for Discord RPC integration.
/// 
/// To enable Discord RPC:
/// 1. Add dart_discord_rpc to pubspec.yaml
/// 2. Implement actual DiscordRPC calls
class DiscordRpcService {
  bool _initialized = false;

  /// Initialize Discord RPC (stub)
  Future<void> initialize() async {
    // Discord RPC not implemented - would require dart_discord_rpc package
    Log.info('Discord RPC: Stub implementation (not connected)', tag: 'Discord');
    _initialized = false;
  }

  /// Update Discord presence (stub)
  void updatePresence({
    required String title,
    required String? artist,
    String? album,
    Duration? position,
    Duration? duration,
    bool isPlaying = false,
    String? imageUrl,
  }) {
    if (!_initialized) return;
    // Would send presence update to Discord
    Log.info('Discord RPC: Would update presence - $title by $artist', tag: 'Discord');
  }

  /// Clear Discord presence (stub)
  void clearPresence() {
    if (!_initialized) return;
    Log.info('Discord RPC: Would clear presence', tag: 'Discord');
  }

  /// Dispose Discord RPC connection (stub)
  void dispose() {
    _initialized = false;
  }
}
