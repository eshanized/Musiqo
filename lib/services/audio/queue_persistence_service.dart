// ============================================================================
// Queue Persistence Service - Save/restore queue across app restarts
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
//
// This service handles saving the current playback queue to disk
// and restoring it when the app starts.
// ============================================================================

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../data/models/song.dart';
import '../../core/utils/logger.dart';
import 'audio_handler.dart';

/// Data structure for persisted queue state
class QueueState {
  final List<Song> queue;
  final int currentIndex;
  final bool shuffleEnabled;
  final RepeatMode repeatMode;
  final Duration? position;

  QueueState({
    required this.queue,
    required this.currentIndex,
    required this.shuffleEnabled,
    required this.repeatMode,
    this.position,
  });

  Map<String, dynamic> toJson() => {
    'queue': queue.map((s) => s.toJson()).toList(),
    'currentIndex': currentIndex,
    'shuffleEnabled': shuffleEnabled,
    'repeatMode': repeatMode.index,
    'positionMs': position?.inMilliseconds,
  };

  factory QueueState.fromJson(Map<String, dynamic> json) {
    final queueList = (json['queue'] as List?)
        ?.map((e) => Song.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
    
    return QueueState(
      queue: queueList,
      currentIndex: json['currentIndex'] as int? ?? -1,
      shuffleEnabled: json['shuffleEnabled'] as bool? ?? false,
      repeatMode: RepeatMode.values[json['repeatMode'] as int? ?? 0],
      position: json['positionMs'] != null 
          ? Duration(milliseconds: json['positionMs'] as int)
          : null,
    );
  }
}

/// Service for persisting and restoring queue state
class QueuePersistenceService {
  static const String _fileName = 'queue_state.json';
  
  /// Get the file path for queue state
  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  /// Save queue state to disk
  Future<void> saveQueueState(QueueState state) async {
    try {
      final file = await _getFile();
      final json = jsonEncode(state.toJson());
      await file.writeAsString(json);
      Log.info('Queue state saved (${state.queue.length} songs)', tag: 'QueuePersistence');
    } catch (e) {
      Log.error('Failed to save queue state', error: e, tag: 'QueuePersistence');
    }
  }

  /// Load queue state from disk
  Future<QueueState?> loadQueueState() async {
    try {
      final file = await _getFile();
      
      if (!await file.exists()) {
        Log.info('No saved queue state found', tag: 'QueuePersistence');
        return null;
      }

      final json = await file.readAsString();
      final data = jsonDecode(json) as Map<String, dynamic>;
      final state = QueueState.fromJson(data);
      
      Log.info('Queue state loaded (${state.queue.length} songs)', tag: 'QueuePersistence');
      return state;
    } catch (e) {
      Log.error('Failed to load queue state', error: e, tag: 'QueuePersistence');
      return null;
    }
  }

  /// Clear saved queue state
  Future<void> clearQueueState() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        await file.delete();
        Log.info('Queue state cleared', tag: 'QueuePersistence');
      }
    } catch (e) {
      Log.error('Failed to clear queue state', error: e, tag: 'QueuePersistence');
    }
  }
}
