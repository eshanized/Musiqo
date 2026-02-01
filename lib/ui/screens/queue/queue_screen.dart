// ============================================================================
// Queue Screen - View and manage the playback queue
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../data/models/song.dart';
import '../../../providers/audio/player_provider.dart';
import '../../../services/audio/audio_handler.dart';
import '../../widgets/images/cached_artwork.dart';

class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(playerQueueProvider);
    final currentIndexAsync = ref.watch(currentIndexProvider);
    final shuffleAsync = ref.watch(shuffleEnabledProvider);
    final repeatModeAsync = ref.watch(repeatModeProvider);

    return Scaffold(
      backgroundColor: EverblushColors.background,
      appBar: AppBar(
        backgroundColor: EverblushColors.background,
        title: const Text(
          'Queue',
          style: TextStyle(color: EverblushColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: EverblushColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Shuffle button
          shuffleAsync.when(
            data: (shuffleEnabled) => IconButton(
              icon: Icon(
                Icons.shuffle_rounded,
                color: shuffleEnabled ? EverblushColors.primary : EverblushColors.textMuted,
              ),
              onPressed: () => toggleShuffle(ref),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          // Repeat button
          repeatModeAsync.when(
            data: (repeatMode) => IconButton(
              icon: Icon(
                _getRepeatIcon(repeatMode),
                color: repeatMode != RepeatMode.off 
                    ? EverblushColors.primary 
                    : EverblushColors.textMuted,
              ),
              onPressed: () => cycleRepeatMode(ref),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          // Clear queue
          IconButton(
            icon: const Icon(Icons.clear_all_rounded, color: EverblushColors.textMuted),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: EverblushColors.surface,
                  title: const Text('Clear Queue?', 
                    style: TextStyle(color: EverblushColors.textPrimary)),
                  content: const Text('This will stop playback.',
                    style: TextStyle(color: EverblushColors.textSecondary)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(audioHandlerProvider).clearQueue();
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('Clear', style: TextStyle(color: EverblushColors.error)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: queueAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (queue) {
          if (queue.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.queue_music_rounded, size: 64, color: EverblushColors.textMuted),
                  SizedBox(height: 16),
                  Text('Queue is empty', 
                    style: TextStyle(color: EverblushColors.textMuted, fontSize: 16)),
                ],
              ),
            );
          }

          final currentIndex = currentIndexAsync.value ?? -1;

          return Column(
            children: [
              // Now playing header
              if (currentIndex >= 0 && currentIndex < queue.length)
                _buildNowPlayingHeader(context, queue[currentIndex]),
              
              // Up next label
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Up Next',
                    style: TextStyle(
                      color: EverblushColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              // Queue list
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: queue.length,
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex--;
                    reorderQueue(ref, oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final song = queue[index];
                    final isPlaying = index == currentIndex;
                    
                    return Dismissible(
                      key: ValueKey('${song.id}_$index'),
                      direction: index == currentIndex 
                          ? DismissDirection.none 
                          : DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: EverblushColors.error,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => removeFromQueue(ref, index),
                      child: _buildQueueItem(
                        context, 
                        ref, 
                        song, 
                        index, 
                        isPlaying,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNowPlayingHeader(BuildContext context, Song song) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            EverblushColors.primary.withOpacity(0.2),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedArtwork(
              url: song.thumbnailUrl,
              size: 60,
              borderRadius: 8,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NOW PLAYING',
                  style: TextStyle(
                    color: EverblushColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  song.title,
                  style: const TextStyle(
                    color: EverblushColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  song.artistName,
                  style: const TextStyle(
                    color: EverblushColors.textSecondary,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueItem(
    BuildContext context, 
    WidgetRef ref, 
    Song song, 
    int index, 
    bool isPlaying,
  ) {
    return ListTile(
      key: ValueKey('tile_${song.id}_$index'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedArtwork(
              url: song.thumbnailUrl,
              size: 50,
              borderRadius: 8,
            ),
          ),
          if (isPlaying)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.equalizer_rounded,
                    color: EverblushColors.primary,
                    size: 24,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        song.title,
        style: TextStyle(
          color: isPlaying ? EverblushColors.primary : EverblushColors.textPrimary,
          fontWeight: isPlaying ? FontWeight.w600 : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artistName,
        style: const TextStyle(color: EverblushColors.textMuted),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: ReorderableDragStartListener(
        index: index,
        child: const Icon(Icons.drag_handle, color: EverblushColors.textMuted),
      ),
      onTap: () {
        ref.read(audioHandlerProvider).skipToQueueItem(index);
      },
    );
  }

  IconData _getRepeatIcon(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.off:
        return Icons.repeat_rounded;
      case RepeatMode.all:
        return Icons.repeat_rounded;
      case RepeatMode.one:
        return Icons.repeat_one_rounded;
    }
  }
}
