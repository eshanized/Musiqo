// ============================================================================
// Discord RPC Service - Rich Presence
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'dart:io';
import 'package:dart_discord_rpc/dart_discord_rpc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/logger.dart';
import '../../providers/audio/player_provider.dart';

class DiscordRpcService {
  DiscordRPC? _rpc;
  bool _isInitialized = false;
  
  // Musiqo Application ID (Placeholder - should use real one)
  static const String _applicationId = '123456789012345678'; 
  
  void init() {
    if (!Platform.isLinux && !Platform.isWindows && !Platform.isMacOS) return;
    
    try {
      _rpc = DiscordRPC(applicationId: _applicationId);
      _rpc?.start(autoRegister: true);
      _isInitialized = true;
      Log.info('Discord RPC started');
    } catch (e) {
      Log.error('Failed to start Discord RPC: $e');
    }
  }

  void updatePresence({
    required String title,
    required String artist,
    required String album,
    required Duration position,
    required Duration duration,
    required bool isPlaying,
    String? imageUrl,
  }) {
    if (!_isInitialized) return;

    try {
      _rpc?.updatePresence(
        DiscordPresence(
          state: artist,
          details: title,
          largeImageKey: 'logo', // Need to upload assets to Discord Dev Portal
          largeImageText: album,
          smallImageKey: isPlaying ? 'play' : 'pause',
          smallImageText: isPlaying ? 'Playing' : 'Paused',
          startTimeStamp: isPlaying 
              ? DateTime.now().millisecondsSinceEpoch - position.inMilliseconds 
              : null,
          endTimeStamp: isPlaying 
              ? DateTime.now().millisecondsSinceEpoch + (duration.inMilliseconds - position.inMilliseconds)
              : null,
        ),
      );
    } catch (e) {
      Log.error('Failed to update Discord presence: $e');
    }
  }

  void dispose() {
    _rpc?.clearPresence();
    _rpc?.shutDown();
    _isInitialized = false;
  }
}

final discordRpcServiceProvider = Provider((ref) => DiscordRpcService());
