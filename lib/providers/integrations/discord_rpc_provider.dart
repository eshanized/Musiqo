// ============================================================================
// Discord RPC Controller - Listens to player and updates RPC
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/audio/player_provider.dart';
import '../../services/integrations/discord_rpc_service.dart';

final discordRpcControllerProvider = Provider((ref) {
  final rpcService = ref.watch(discordRpcServiceProvider);
  final currentSong = ref.watch(currentSongProvider);
  final isPlaying = ref.watch(isPlayingProvider);
  final position = ref.watch(positionProvider);
  final duration = ref.watch(durationProvider);
  
  // TODO: Add setting to enable/disable RPC
  
  if (currentSong != null) {
      rpcService.updatePresence(
        title: currentSong.title,
        artist: currentSong.artist,
        album: currentSong.album,
        position: position,
        duration: duration,
        isPlaying: isPlaying,
        imageUrl: currentSong.thumbnailUrl,
      );
  }
  
  ref.onDispose(() {
    rpcService.dispose();
  });
});
