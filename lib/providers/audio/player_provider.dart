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
MusiqoAudioHandler? _audioHandlerInstance;

/// The audio handler provider
final audioHandlerProvider = Provider<MusiqoAudioHandler>((ref) {
  if (_audioHandlerInstance == null) {
    throw Exception(
      'AudioHandler not initialized. Call initAudioService() first.',
    );
  }
  return _audioHandlerInstance!;
});

/// Initialize the audio service
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

// ============================================================================
// Playback State Providers
// ============================================================================

/// Current song provider - reactive to current song changes
final currentSongProvider = StreamProvider<Song?>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.currentSongStream;
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

// ============================================================================
// Queue & Mode Providers
// ============================================================================

/// Player queue provider - reactive to queue changes
final playerQueueProvider = StreamProvider<List<Song>>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.queueStream;
});

/// Current queue index
final currentIndexProvider = StreamProvider<int>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.currentIndexStream;
});

/// Shuffle mode provider
final shuffleEnabledProvider = StreamProvider<bool>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.shuffleStream;
});

/// Repeat mode provider
final repeatModeProvider = StreamProvider<RepeatMode>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.repeatModeStream;
});

// ============================================================================
// Actions
// ============================================================================

/// Play a song action
void playSong(WidgetRef ref, Song song) {
  final handler = ref.read(audioHandlerProvider);
  handler.playSong(song);
}

/// Play a queue of songs
void playQueue(WidgetRef ref, List<Song> songs, {int startIndex = 0}) {
  final handler = ref.read(audioHandlerProvider);
  handler.playQueue(songs, startIndex: startIndex);
}

/// Add song to queue
void addToQueue(WidgetRef ref, Song song) {
  final handler = ref.read(audioHandlerProvider);
  handler.addToQueue(song);
}

/// Play song next
void playNext(WidgetRef ref, Song song) {
  final handler = ref.read(audioHandlerProvider);
  handler.playNext(song);
}

/// Remove from queue
void removeFromQueue(WidgetRef ref, int index) {
  final handler = ref.read(audioHandlerProvider);
  handler.removeFromQueue(index);
}

/// Reorder queue
void reorderQueue(WidgetRef ref, int oldIndex, int newIndex) {
  final handler = ref.read(audioHandlerProvider);
  handler.reorderQueue(oldIndex, newIndex);
}

/// Toggle shuffle
void toggleShuffle(WidgetRef ref) {
  final handler = ref.read(audioHandlerProvider);
  handler.toggleShuffle();
}

/// Cycle repeat mode
void cycleRepeatMode(WidgetRef ref) {
  final handler = ref.read(audioHandlerProvider);
  handler.cycleRepeatMode();
}
