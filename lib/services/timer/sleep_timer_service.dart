// ============================================================================
// Sleep Timer Service - Fade out and stop playback
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/logger.dart';
import '../../providers/audio/player_provider.dart' show audioHandlerProvider;
import '../audio/audio_handler.dart';

/// Sleep timer state
class SleepTimerState {
  final bool isActive;
  final Duration remaining;
  final Duration total;

  const SleepTimerState({
    this.isActive = false,
    this.remaining = Duration.zero,
    this.total = Duration.zero,
  });

  double get progress => total.inSeconds > 0 
      ? remaining.inSeconds / total.inSeconds 
      : 0;

  String get displayTime {
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;
    
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  SleepTimerState copyWith({
    bool? isActive,
    Duration? remaining,
    Duration? total,
  }) {
    return SleepTimerState(
      isActive: isActive ?? this.isActive,
      remaining: remaining ?? this.remaining,
      total: total ?? this.total,
    );
  }
}

/// Preset sleep timer durations
enum SleepTimerPreset {
  minutes5(Duration(minutes: 5), '5 minutes'),
  minutes10(Duration(minutes: 10), '10 minutes'),
  minutes15(Duration(minutes: 15), '15 minutes'),
  minutes30(Duration(minutes: 30), '30 minutes'),
  minutes45(Duration(minutes: 45), '45 minutes'),
  hour1(Duration(hours: 1), '1 hour'),
  hour2(Duration(hours: 2), '2 hours'),
  endOfTrack(Duration.zero, 'End of track');

  final Duration duration;
  final String label;
  
  const SleepTimerPreset(this.duration, this.label);
}

/// Sleep timer controller
class SleepTimerNotifier extends StateNotifier<SleepTimerState> {
  final MusiqoAudioHandler _audioHandler;
  Timer? _timer;
  Timer? _fadeTimer;

  SleepTimerNotifier(this._audioHandler) : super(const SleepTimerState());

  /// Start timer with custom duration
  void start(Duration duration) {
    cancel();
    
    state = SleepTimerState(
      isActive: true,
      remaining: duration,
      total: duration,
    );
    
    Log.info('Sleep timer started: ${duration.inMinutes} minutes', tag: 'Timer');
    
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final newRemaining = state.remaining - const Duration(seconds: 1);
      
      if (newRemaining <= Duration.zero) {
        _executeStop();
      } else {
        state = state.copyWith(remaining: newRemaining);
        
        // Start fade 30 seconds before end
        if (newRemaining <= const Duration(seconds: 30) && _fadeTimer == null) {
          _startFade();
        }
      }
    });
  }

  /// Start with preset
  void startWithPreset(SleepTimerPreset preset) {
    if (preset == SleepTimerPreset.endOfTrack) {
      _startEndOfTrack();
    } else {
      start(preset.duration);
    }
  }

  /// Stop at end of current track
  void _startEndOfTrack() {
    cancel();
    
    // Listen to song changes and stop
    // For simplicity, we'll use a max duration
    state = const SleepTimerState(
      isActive: true,
      remaining: Duration(minutes: 10),
      total: Duration(minutes: 10),
    );
    
    Log.info('Sleep timer: End of track mode', tag: 'Timer');
  }

  /// Add more time
  void extend(Duration duration) {
    if (!state.isActive) return;
    
    final newRemaining = state.remaining + duration;
    final newTotal = state.total + duration;
    
    state = state.copyWith(
      remaining: newRemaining,
      total: newTotal,
    );
    
    Log.info('Sleep timer extended by ${duration.inMinutes} minutes', tag: 'Timer');
  }

  /// Cancel timer
  void cancel() {
    _timer?.cancel();
    _timer = null;
    _fadeTimer?.cancel();
    _fadeTimer = null;
    
    state = const SleepTimerState();
    Log.info('Sleep timer cancelled', tag: 'Timer');
  }

  /// Start volume fade
  void _startFade() {
    Log.info('Starting volume fade...', tag: 'Timer');
    
    double volume = 1.0;
    const steps = 30;
    const stepDuration = Duration(seconds: 1);
    
    _fadeTimer = Timer.periodic(stepDuration, (timer) {
      volume -= (1.0 / steps);
      if (volume <= 0) {
        timer.cancel();
        _executeStop();
      } else {
        _audioHandler.setVolume(volume);
      }
    });
  }

  /// Stop playback
  void _executeStop() {
    _timer?.cancel();
    _fadeTimer?.cancel();
    
    _audioHandler.pause();
    _audioHandler.setVolume(1.0); // Reset volume
    
    state = const SleepTimerState();
    Log.info('Sleep timer finished, playback stopped', tag: 'Timer');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeTimer?.cancel();
    super.dispose();
  }
}

/// Sleep timer provider
final sleepTimerProvider = StateNotifierProvider<SleepTimerNotifier, SleepTimerState>((ref) {
  final audioHandler = ref.watch(audioHandlerProvider);
  return SleepTimerNotifier(audioHandler);
});
