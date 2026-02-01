// ============================================================================
// Lyrics View - Display synced lyrics
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../data/models/lyrics.dart';

/// A widget that displays synced lyrics and scrolls to the current line.
class LyricsView extends StatefulWidget {
  final Lyrics lyrics;
  final Duration currentPosition;
  final ValueChanged<Duration>? onLineTap;

  const LyricsView({
    super.key,
    required this.lyrics,
    required this.currentPosition,
    this.onLineTap,
  });

  @override
  State<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends State<LyricsView> {
  final ItemScrollController _scrollController = ItemScrollController();
  int _previousIndex = -1;

  @override
  void didUpdateWidget(LyricsView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.lyrics.isSynced) return;

    final currentIndex = widget.lyrics.getCurrentLineIndex(
      widget.currentPosition,
    );

    // Only scroll when the line changes
    if (currentIndex != _previousIndex && currentIndex >= 0) {
      _previousIndex = currentIndex;
      _scrollToLine(currentIndex);
    }
  }

  void _scrollToLine(int index) {
    // Smooth scroll to the current line
    _scrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      alignment: 0.3, // Keep current line at 30% from top
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.lyrics.isSynced) {
      // Plain text lyrics
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Text(
          widget.lyrics.plainText ?? 'No lyrics available',
          style: const TextStyle(
            fontSize: 18,
            color: EverblushColors.textSecondary,
            height: 1.8,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    final lines = widget.lyrics.syncedLines!;
    final currentIndex = widget.lyrics.getCurrentLineIndex(
      widget.currentPosition,
    );

    return ScrollablePositionedList.builder(
      itemScrollController: _scrollController,
      itemCount: lines.length,
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
      itemBuilder: (context, index) {
        final line = lines[index];
        final isCurrent = index == currentIndex;
        final isPast = index < currentIndex;

        return GestureDetector(
          onTap: () => widget.onLineTap?.call(line.startTime),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isCurrent ? 24 : 18,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                color: isCurrent
                    ? EverblushColors.textPrimary
                    : isPast
                    ? EverblushColors.textMuted
                    : EverblushColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              child: Text(line.text),
            ),
          ),
        );
      },
    );
  }
}
