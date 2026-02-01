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
  final currentSongAsync = ref.watch(currentSongProvider);
  final isPlayingAsync = ref.watch(isPlayingProvider);
  final positionAsync = ref.watch(positionProvider);
  final durationAsync = ref.watch(durationProvider);
  
  // Extract values from async states
  final currentSong = currentSongAsync.valueOrNull;
  final isPlaying = isPlayingAsync.valueOrNull ?? false;
  final position = positionAsync.valueOrNull ?? Duration.zero;
  final duration = durationAsync.valueOrNull ?? Duration.zero;
  
  if (currentSong != null) {
    rpcService.updatePresence(
      title: currentSong.title,
      artist: currentSong.artistName,
      album: currentSong.album?.name,
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
