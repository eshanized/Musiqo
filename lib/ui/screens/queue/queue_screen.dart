// ============================================================================
// Queue Screen - Current playback queue
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/everblush_colors.dart';

/// Queue screen showing current and upcoming songs.
class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Get from player provider
    final currentSong = 'Now Playing Song';

    return Scaffold(
      backgroundColor: EverblushColors.background,
      appBar: AppBar(
        backgroundColor: EverblushColors.background,
        title: const Text(
          'Queue',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: EverblushColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Clear queue
            },
            icon: const Icon(Icons.clear_all_rounded),
          ),
        ],
      ),
      body: ReorderableListView.builder(
        itemCount: 20,
        onReorder: (oldIndex, newIndex) {
          // TODO: Reorder queue
        },
        itemBuilder: (context, index) {
          final isPlaying = index == 0;

          return ListTile(
            key: ValueKey('queue_$index'),
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                const Icon(
                  Icons.drag_handle_rounded,
                  color: EverblushColors.textMuted,
                ),
                const SizedBox(width: 8),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: EverblushColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isPlaying
                        ? Icons.equalizer_rounded
                        : Icons.music_note_rounded,
                    color: isPlaying
                        ? EverblushColors.primary
                        : EverblushColors.textMuted,
                  ),
                ),
              ],
            ),
            title: Text(
              index == 0 ? currentSong : 'Queue Song ${index}',
              style: TextStyle(
                color: isPlaying
                    ? EverblushColors.primary
                    : EverblushColors.textPrimary,
              ),
            ),
            subtitle: Text(
              'Artist Name',
              style: const TextStyle(
                fontSize: 12,
                color: EverblushColors.textMuted,
              ),
            ),
            trailing: IconButton(
              onPressed: () {
                // TODO: Remove from queue
              },
              icon: const Icon(
                Icons.close_rounded,
                color: EverblushColors.textMuted,
              ),
            ),
          );
        },
      ),
    );
  }
}
