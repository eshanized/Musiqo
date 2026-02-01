// ============================================================================
// Audio Handler - Full-featured music playback engine
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
//
// This is the core of audio playback with:
// - Shuffle & Repeat modes
// - Queue management (add, remove, reorder)
// - Background playback with notifications
// ============================================================================

import 'dart:async';
import 'dart:math';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/models/song.dart';
import '../../core/utils/logger.dart';
import '../innertube/youtube_facade.dart';

/// Repeat mode for playback
enum RepeatMode {
  off,    // No repeat
  one,    // Repeat current song
  all,    // Repeat entire queue
}

/// The main audio handler that manages music playback.
class MusiqoAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  final YouTubeFacade _youtube = YouTubeFacade();

  // Queue management
  final List<Song> _queue = [];
  final List<Song> _originalQueue = []; // For shuffle restore
  int _currentIndex = -1;

  // Playback modes
  bool _shuffleEnabled = false;
  RepeatMode _repeatMode = RepeatMode.off;

  // State streams
  final _shuffleSubject = BehaviorSubject<bool>.seeded(false);
  final _repeatModeSubject = BehaviorSubject<RepeatMode>.seeded(RepeatMode.off);
  final _queueSubject = BehaviorSubject<List<Song>>.seeded([]);
  final _currentSongSubject = BehaviorSubject<Song?>.seeded(null);
  final _currentIndexSubject = BehaviorSubject<int>.seeded(-1);

  // Public streams
  Stream<bool> get shuffleStream => _shuffleSubject.stream;
  Stream<RepeatMode> get repeatModeStream => _repeatModeSubject.stream;
  Stream<List<Song>> get queueStream => _queueSubject.stream;
  Stream<Song?> get currentSongStream => _currentSongSubject.stream;
  Stream<int> get currentIndexStream => _currentIndexSubject.stream;

  MusiqoAudioHandler() {
    _init();
  }

  void _init() {
    // Listen to player state changes
    _player.playbackEventStream.listen((event) {
      _broadcastState();
    });

    // Listen for song completion
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _onSongComplete();
      }
    });

    // Listen to position changes (throttled for performance)
    _player.positionStream
        .throttleTime(const Duration(milliseconds: 200))
        .listen((_) => _broadcastState());
  }

  /// Handle song completion based on repeat mode
  Future<void> _onSongComplete() async {
    switch (_repeatMode) {
      case RepeatMode.one:
        // Repeat the same song
        await seek(Duration.zero);
        await play();
        break;
      case RepeatMode.all:
        // Go to next, loop back if at end
        if (_currentIndex >= _queue.length - 1) {
          _currentIndex = 0;
          await _loadAndPlay(_queue[_currentIndex]);
        } else {
          await skipToNext();
        }
        break;
      case RepeatMode.off:
        // Just go to next if available
        if (_currentIndex < _queue.length - 1) {
          await skipToNext();
        } else {
          // Stop at end of queue
          await stop();
        }
        break;
    }
  }

  // ============================================
  // Playback Control
  // ============================================

  /// Play a single song (clears queue)
  Future<void> playSong(Song song) async {
    _originalQueue.clear();
    _queue.clear();
    _queue.add(song);
    _originalQueue.add(song);
    _currentIndex = 0;
    _updateQueueState();
    await _loadAndPlay(song);
  }

  /// Play a queue of songs starting at index
  Future<void> playQueue(List<Song> songs, {int startIndex = 0}) async {
    if (songs.isEmpty) return;

    _originalQueue.clear();
    _originalQueue.addAll(songs);
    _queue.clear();
    
    if (_shuffleEnabled) {
      _queue.addAll(_shuffleList(songs, startIndex));
      _currentIndex = 0;
    } else {
      _queue.addAll(songs);
      _currentIndex = startIndex.clamp(0, songs.length - 1);
    }

    _updateQueueState();
    await _loadAndPlay(_queue[_currentIndex]);
  }

  /// Add song to end of queue
  void addToQueue(Song song) {
    _queue.add(song);
    _originalQueue.add(song);
    _updateQueueState();
    Log.audio('Added to queue: ${song.title}');
  }

  /// Add song to play next
  void playNext(Song song) {
    final insertIndex = _currentIndex + 1;
    _queue.insert(insertIndex, song);
    _originalQueue.add(song);
    _updateQueueState();
    Log.audio('Playing next: ${song.title}');
  }

  /// Remove song from queue by index
  void removeFromQueue(int index) {
    if (index < 0 || index >= _queue.length) return;
    
    final removed = _queue.removeAt(index);
    _originalQueue.remove(removed);
    
    // Adjust current index if needed
    if (index < _currentIndex) {
      _currentIndex--;
    } else if (index == _currentIndex && _queue.isNotEmpty) {
      // If we removed current song, play next one
      if (_currentIndex >= _queue.length) {
        _currentIndex = _queue.length - 1;
      }
      _loadAndPlay(_queue[_currentIndex]);
    }
    
    _updateQueueState();
  }

  /// Reorder queue (move song from oldIndex to newIndex)
  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _queue.length) return;
    if (newIndex < 0 || newIndex >= _queue.length) return;
    
    final song = _queue.removeAt(oldIndex);
    _queue.insert(newIndex, song);
    
    // Adjust current index
    if (oldIndex == _currentIndex) {
      _currentIndex = newIndex;
    } else if (oldIndex < _currentIndex && newIndex >= _currentIndex) {
      _currentIndex--;
    } else if (oldIndex > _currentIndex && newIndex <= _currentIndex) {
      _currentIndex++;
    }
    
    _updateQueueState();
  }

  /// Clear the queue (stops playback)
  Future<void> clearQueue() async {
    await stop();
    _queue.clear();
    _originalQueue.clear();
    _currentIndex = -1;
    _updateQueueState();
  }

  /// Set volume (0.0 to 1.0)
  void setVolume(double volume) {
    _player.setVolume(volume.clamp(0.0, 1.0));
  }

  // ============================================
  // Shuffle & Repeat
  // ============================================

  /// Toggle shuffle mode
  void toggleShuffle() {
    _shuffleEnabled = !_shuffleEnabled;
    _shuffleSubject.add(_shuffleEnabled);

    if (_shuffleEnabled && _queue.isNotEmpty) {
      // Shuffle queue, keeping current song at index 0
      final currentSong = _queue[_currentIndex];
      _queue.clear();
      _queue.add(currentSong);
      
      final others = _originalQueue.where((s) => s.id != currentSong.id).toList();
      others.shuffle(Random());
      _queue.addAll(others);
      
      _currentIndex = 0;
    } else if (!_shuffleEnabled && _originalQueue.isNotEmpty) {
      // Restore original order
      final currentSongId = _queue.isNotEmpty && _currentIndex >= 0 
          ? _queue[_currentIndex].id 
          : null;
      _queue.clear();
      _queue.addAll(_originalQueue);
      
      // Find current song in restored queue
      if (currentSongId != null) {
        _currentIndex = _queue.indexWhere((s) => s.id == currentSongId);
        if (_currentIndex < 0) _currentIndex = 0;
      }
    }

    _updateQueueState();
    Log.audio('Shuffle ${_shuffleEnabled ? "enabled" : "disabled"}');
  }

  /// Cycle through repeat modes
  void cycleRepeatMode() {
    switch (_repeatMode) {
      case RepeatMode.off:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.off;
        break;
    }
    _repeatModeSubject.add(_repeatMode);
    Log.audio('Repeat mode: $_repeatMode');
  }

  /// Set specific repeat mode (internal use)
  void setRepeat(RepeatMode mode) {
    _repeatMode = mode;
    _repeatModeSubject.add(_repeatMode);
  }

  // ============================================
  // Internal Helpers
  // ============================================

  /// Load and play a song
  Future<void> _loadAndPlay(Song song) async {
    Log.audio('Loading: ${song.title}');
    _currentSongSubject.add(song);
    _currentIndexSubject.add(_currentIndex);

    try {
      // Update media item for notifications
      final mediaItemValue = MediaItem(
        id: song.id,
        title: song.title,
        artist: song.artistName,
        artUri: song.thumbnailUrl != null ? Uri.parse(song.thumbnailUrl!) : null,
        duration: song.duration,
      );
      mediaItem.add(mediaItemValue);

      // Get stream URL
      final songDetails = await _youtube.getSongDetails(song.id);

      if (songDetails?.streamUrl != null) {
        Log.audio('Got stream URL, starting playback');
        await _player.setUrl(songDetails!.streamUrl!);
        await _player.play();

        // Update duration if needed
        if (song.duration == Duration.zero && songDetails.duration != Duration.zero) {
          mediaItem.add(mediaItemValue.copyWith(duration: songDetails.duration));
        }
      } else {
        Log.error('No stream URL available for ${song.title}');
        // Try next song if available
        if (_currentIndex < _queue.length - 1) {
          await skipToNext();
        }
      }

      _broadcastState();
    } catch (e) {
      Log.error('Failed to play song', error: e);
    }
  }

  /// Shuffle a list keeping the song at startIndex at position 0
  List<Song> _shuffleList(List<Song> songs, int startIndex) {
    final current = songs[startIndex];
    final others = [...songs];
    others.removeAt(startIndex);
    others.shuffle(Random());
    return [current, ...others];
  }

  /// Update queue state streams
  void _updateQueueState() {
    _queueSubject.add(List.unmodifiable(_queue));
    _currentIndexSubject.add(_currentIndex);
    if (_currentIndex >= 0 && _currentIndex < _queue.length) {
      _currentSongSubject.add(_queue[_currentIndex]);
    } else {
      _currentSongSubject.add(null);
    }
  }

  /// Broadcast playback state to system
  void _broadcastState() {
    playbackState.add(PlaybackState(
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
      shuffleMode: _shuffleEnabled ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
      repeatMode: _getRepeatMode(),
    ));
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

  AudioServiceRepeatMode _getRepeatMode() {
    switch (_repeatMode) {
      case RepeatMode.off:
        return AudioServiceRepeatMode.none;
      case RepeatMode.one:
        return AudioServiceRepeatMode.one;
      case RepeatMode.all:
        return AudioServiceRepeatMode.all;
    }
  }

  // ============================================
  // AudioHandler Overrides
  // ============================================

  @override
  Future<void> play() async => await _player.play();

  @override
  Future<void> pause() async => await _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    _currentSongSubject.add(null);
  }

  @override
  Future<void> seek(Duration position) async => await _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
      await _loadAndPlay(_queue[_currentIndex]);
    } else if (_repeatMode == RepeatMode.all && _queue.isNotEmpty) {
      _currentIndex = 0;
      await _loadAndPlay(_queue[_currentIndex]);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_player.position.inSeconds > 3) {
      await seek(Duration.zero);
    } else if (_currentIndex > 0) {
      _currentIndex--;
      await _loadAndPlay(_queue[_currentIndex]);
    } else if (_repeatMode == RepeatMode.all && _queue.isNotEmpty) {
      _currentIndex = _queue.length - 1;
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

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    if ((_shuffleEnabled && shuffleMode == AudioServiceShuffleMode.none) ||
        (!_shuffleEnabled && shuffleMode == AudioServiceShuffleMode.all)) {
      toggleShuffle();
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        _repeatMode = RepeatMode.off;
        break;
      case AudioServiceRepeatMode.one:
        _repeatMode = RepeatMode.one;
        break;
      case AudioServiceRepeatMode.all:
      case AudioServiceRepeatMode.group:
        _repeatMode = RepeatMode.all;
        break;
    }
    _repeatModeSubject.add(_repeatMode);
  }

  // ============================================
  // Getters
  // ============================================

  Song? get currentSong => _currentSongSubject.value;
  List<Song> get songQueue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  bool get isShuffleEnabled => _shuffleEnabled;
  RepeatMode get repeatMode => _repeatMode;
  bool get isPlaying => _player.playing;
  Duration get position => _player.position;
  Duration? get duration => _player.duration;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<bool> get playingStream => _player.playingStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  /// Dispose resources
  Future<void> dispose() async {
    await _player.dispose();
    await _shuffleSubject.close();
    await _repeatModeSubject.close();
    await _queueSubject.close();
    await _currentSongSubject.close();
    await _currentIndexSubject.close();
  }
}
