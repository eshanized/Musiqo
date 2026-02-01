// ============================================================================
// Backup Service - Import/Export data
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:isar/isar.dart';

import '../../core/utils/logger.dart';
import '../../data/database/database_service.dart';
import '../../data/database/collections/song_entity.dart';
import '../../data/database/collections/history_entity.dart';
import '../../data/database/collections/playlist_entity.dart';

class BackupService {
  BackupService();

  Future<void> exportData() async {
    try {
      final isar = DatabaseService.instance;
      final history = await isar.historyEntitys.where().findAll();
      final songs = await isar.songEntitys.where().findAll();
      // Export playlists from SharedPreferences (as currently implemented there)
      final prefs = await SharedPreferences.getInstance();
      final playlists = prefs.getString('playlists') ?? '{}';

      final data = {
        'version': 1,
        'timestamp': DateTime.now().toIso8601String(),
        'history': history.map((e) => {
          'title': e.title,
          'artist': e.artistName,
          'playedAt': e.playedAt.toIso8601String(),
        }).toList(),
        'favorites': songs.where((s) => s.isLiked).map((s) => s.videoId).toList(),
        'playlists': jsonDecode(playlists),
      };

      final jsonString = jsonEncode(data);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/musiqo_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonString);

      await Share.shareXFiles([XFile(file.path)], text: 'Musiqo Backup');
    } catch (e) {
      Log.error('Export failed: $e');
      rethrow;
    }
  }

  Future<void> importData() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final data = jsonDecode(jsonString);

        // Restore logic here...
        // For now just logging
        Log.info('Backup loaded with ${data['history'].length} history items');
        
        // TODO: Proper restoration logic
      }
    } catch (e) {
      Log.error('Import failed: $e');
      rethrow;
    }
  }
}
