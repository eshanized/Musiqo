// ============================================================================
// Lyrics Screen - Synced lyrics display with auto-scroll
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../providers/audio/player_provider.dart';
import '../../../providers/lyrics/lyrics_provider.dart';
import '../../../services/lyrics/lyrics_service.dart';
import '../../widgets/images/cached_artwork.dart';

class LyricsScreen extends ConsumerStatefulWidget {
  const LyricsScreen({super.key});

  @override
  ConsumerState<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends ConsumerState<LyricsScreen> {
  final ItemScrollController _scrollController = ItemScrollController();
  int? _lastActiveIndex;

  @override
  Widget build(BuildContext context) {
    final currentSongAsync = ref.watch(currentSongProvider);
    final lyricsAsync = ref.watch(currentLyricsProvider);
    final isPlayingAsync = ref.watch(isPlayingProvider);
    final activeIndex = ref.watch(activeLyricIndexProvider);

    // Auto-scroll to active lyric
    if (activeIndex != null && activeIndex != _lastActiveIndex) {
      _lastActiveIndex = activeIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.isAttached) {
          _scrollController.scrollTo(
            index: activeIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: 0.4, // Scroll so active line is ~40% from top
          );
        }
      });
    }

    return Scaffold(
      backgroundColor: EverblushColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, currentSongAsync.value),
            
            // Lyrics content
            Expanded(
              child: lyricsAsync.when(
                loading: () => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: EverblushColors.primary),
                      SizedBox(height: 16),
                      Text(
                        'Fetching lyrics...',
                        style: TextStyle(color: EverblushColors.textMuted),
                      ),
                    ],
                  ),
                ),
                error: (e, _) => _buildNoLyrics('Failed to load lyrics'),
                data: (lyrics) {
                  if (lyrics == null || lyrics.isEmpty) {
                    return _buildNoLyrics('No lyrics available');
                  }
                  return _buildLyricsList(
                    lyrics, 
                    activeIndex, 
                    isPlayingAsync.value ?? false,
                  );
                },
              ),
            ),
            
            // Mini player bar
            _buildMiniPlayer(
              currentSongAsync.value,
              isPlayingAsync.value ?? false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic song) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 32,
              color: EverblushColors.textPrimary,
            ),
          ),
          const Expanded(
            child: Text(
              'Lyrics',
              style: TextStyle(
                color: EverblushColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Share lyrics
            },
            icon: const Icon(
              Icons.share_rounded,
              color: EverblushColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLyricsList(SongLyrics lyrics, int? activeIndex, bool isPlaying) {
    return Column(
      children: [
        // Source indicator
        if (lyrics.source != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  lyrics.isSynced ? Icons.sync : Icons.text_fields,
                  size: 14,
                  color: EverblushColors.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  lyrics.isSynced ? 'Synced lyrics' : 'Plain lyrics',
                  style: const TextStyle(
                    color: EverblushColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '• ${lyrics.source}',
                  style: const TextStyle(
                    color: EverblushColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        
        // Lyrics list
        Expanded(
          child: ScrollablePositionedList.builder(
            itemScrollController: _scrollController,
            itemCount: lyrics.lines.length,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            itemBuilder: (context, index) {
              final line = lyrics.lines[index];
              final isActive = index == activeIndex;
              
              return GestureDetector(
                onTap: () {
                  // Seek to this line if synced
                  if (lyrics.isSynced) {
                    ref.read(audioHandlerProvider).seek(line.startTime);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: isActive ? 24 : 18,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w400,
                      color: isActive 
                          ? EverblushColors.primary 
                          : EverblushColors.textSecondary,
                      height: 1.4,
                    ),
                    child: Text(
                      line.text,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNoLyrics(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lyrics_outlined,
            size: 64,
            color: EverblushColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: EverblushColors.textMuted,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try searching for a different song',
            style: TextStyle(
              color: EverblushColors.textMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPlayer(dynamic song, bool isPlaying) {
    if (song == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: EverblushColors.surface,
        border: Border(
          top: BorderSide(
            color: EverblushColors.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedArtwork(
              url: song.thumbnailUrl,
              size: 48,
              borderRadius: 8,
            ),
          ),
          const SizedBox(width: 12),
          
          // Title & Artist
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  song.title,
                  style: const TextStyle(
                    color: EverblushColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  song.artistName,
                  style: const TextStyle(
                    color: EverblushColors.textMuted,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Play/Pause
          IconButton(
            onPressed: () {
              final handler = ref.read(audioHandlerProvider);
              if (isPlaying) {
                handler.pause();
              } else {
                handler.play();
              }
            },
            icon: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: EverblushColors.textPrimary,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}
