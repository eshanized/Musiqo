// ============================================================================
// Player Provider - Riverpod state for audio playback
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';

import '../../data/models/song.dart';
import '../../services/audio/audio_handler.dart';

/// Singleton audio handler instance
/// We initialize this once and reuse it
MusiqoAudioHandler? _audioHandlerInstance;

/// The audio handler provider
///
/// This provider manages the singleton audio handler instance.
/// It initializes the handler lazily on first access.
final audioHandlerProvider = Provider<MusiqoAudioHandler>((ref) {
  if (_audioHandlerInstance == null) {
    throw Exception(
      'AudioHandler not initialized. Call initAudioService() first.',
    );
  }
  return _audioHandlerInstance!;
});

/// Initialize the audio service
/// This should be called in main() before runApp()
Future<MusiqoAudioHandler> initAudioService() async {
  if (_audioHandlerInstance != null) {
    return _audioHandlerInstance!;
  }

  _audioHandlerInstance = await AudioService.init(
    builder: () => MusiqoAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'io.eshanized.musiqo.audio',
      androidNotificationChannelName: 'Musiqo',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

  return _audioHandlerInstance!;
}

/// Current song provider - reactive to media item changes
final currentSongProvider = StreamProvider<Song?>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.mediaItem.map((mediaItem) {
    if (mediaItem == null) return null;
    return Song(
      id: mediaItem.id,
      title: mediaItem.title,
      artists:
          mediaItem.artist != null
              ? [Artist(id: '', name: mediaItem.artist!)]
              : [],
      duration: mediaItem.duration ?? Duration.zero,
      thumbnailUrl: mediaItem.artUri?.toString(),
    );
  });
});

/// Is playing provider
final isPlayingProvider = StreamProvider<bool>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.playingStream;
});

/// Position provider
final positionProvider = StreamProvider<Duration>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.positionStream;
});

/// Duration provider
final durationProvider = StreamProvider<Duration?>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.durationStream;
});

/// Player queue provider (read-only list of current queue from audio handler)
final playerQueueProvider = Provider<List<Song>>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.songQueue;
});
