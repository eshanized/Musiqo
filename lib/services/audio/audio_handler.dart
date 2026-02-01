// ============================================================================
// Audio Handler - Background music playback with just_audio
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
//
// This is the core of audio playback. It uses:
// - just_audio: For actual audio playback
// - audio_service: For background playback and notifications
// ============================================================================

import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';

import '../../data/models/song.dart';
import '../../core/utils/logger.dart';
import '../innertube/youtube_facade.dart';

/// The main audio handler that manages music playback.
///
/// WHAT IS AN AUDIO HANDLER?
/// AudioHandler is from the audio_service package. It lets your app
/// play music in the background (even when the app is closed) and
/// shows media controls in the notification shade.
class MusiqoAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  final YouTubeFacade _youtube = YouTubeFacade();

  // Queue management
  final List<Song> _queue = [];
  int _currentIndex = -1;

  MusiqoAudioHandler() {
    _init();
  }

  void _init() {
    // Listen to player state changes and broadcast them
    _player.playbackEventStream.listen((event) {
      _broadcastState();
    });

    // Listen for when a song ends
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        skipToNext();
      }
    });

    // Listen to position changes
    _player.positionStream.listen((position) {
      // Update playback state with new position
      _broadcastState();
    });
  }

  /// Play a single song
  Future<void> playSong(Song song) async {
    _queue.clear();
    _queue.add(song);
    _currentIndex = 0;
    await _loadAndPlay(song);
  }

  /// Play a queue of songs starting at index
  Future<void> playQueue(List<Song> songs, {int startIndex = 0}) async {
    _queue.clear();
    _queue.addAll(songs);
    _currentIndex = startIndex;

    if (_queue.isNotEmpty) {
      await _loadAndPlay(_queue[_currentIndex]);
    }
  }

  /// Load and play a song
  Future<void> _loadAndPlay(Song song) async {
    Log.audio('Loading: ${song.title}');

    try {
      // Update the current media item for notifications
      mediaItem.add(
        MediaItem(
          id: song.id,
          title: song.title,
          artist: song.artistName,
          artUri:
              song.thumbnailUrl != null ? Uri.parse(song.thumbnailUrl!) : null,
          duration: song.duration,
        ),
      );

      // Get the stream URL from YouTube
      final songDetails = await _youtube.getSongDetails(song.id);

      if (songDetails?.streamUrl != null) {
        Log.audio('Got stream URL, starting playback');
        await _player.setUrl(songDetails!.streamUrl!);
        await _player.play();

        // Update duration if we didn't have it
        if (song.duration == Duration.zero &&
            songDetails.duration != Duration.zero) {
          mediaItem.add(
            MediaItem(
              id: song.id,
              title: song.title,
              artist: song.artistName,
              artUri:
                  song.thumbnailUrl != null
                      ? Uri.parse(song.thumbnailUrl!)
                      : null,
              duration: songDetails.duration,
            ),
          );
        }
      } else {
        Log.error('No stream URL available for ${song.title}');
      }

      _broadcastState();
    } catch (e) {
      Log.error('Failed to play song', error: e);
    }
  }

  /// Broadcast the current playback state
  void _broadcastState() {
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          _player.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: _getProcessingState(),
        playing: _player.playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: _currentIndex,
      ),
    );
  }

  AudioProcessingState _getProcessingState() {
    switch (_player.processingState) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  // ============================================
  // AudioHandler overrides
  // ============================================

  @override
  Future<void> play() async {
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
      await _loadAndPlay(_queue[_currentIndex]);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    // If we're more than 3 seconds in, restart the song
    if (_player.position.inSeconds > 3) {
      await seek(Duration.zero);
    } else if (_currentIndex > 0) {
      _currentIndex--;
      await _loadAndPlay(_queue[_currentIndex]);
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index >= 0 && index < _queue.length) {
      _currentIndex = index;
      await _loadAndPlay(_queue[_currentIndex]);
    }
  }

  // ============================================
  // Getters
  // ============================================

  /// Current playing song
  Song? get currentSong {
    if (_currentIndex >= 0 && _currentIndex < _queue.length) {
      return _queue[_currentIndex];
    }
    return null;
  }

  /// The song queue (renamed to avoid conflict with BaseAudioHandler.queue)
  List<Song> get songQueue => List.unmodifiable(_queue);

  /// Current position stream
  Stream<Duration> get positionStream => _player.positionStream;

  /// Playing state stream
  Stream<bool> get playingStream => _player.playingStream;

  /// Duration stream
  Stream<Duration?> get durationStream => _player.durationStream;
}
