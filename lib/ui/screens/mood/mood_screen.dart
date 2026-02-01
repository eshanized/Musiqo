// ============================================================================
// Mood/Genre Screen - Browse by mood or genre
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';

/// Screen for browsing songs by mood.
class MoodScreen extends StatelessWidget {
  final String moodId;
  final String moodName;

  const MoodScreen({super.key, required this.moodId, required this.moodName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EverblushColors.background,
      appBar: AppBar(
        backgroundColor: EverblushColors.background,
        title: Text(
          moodName,
          style: const TextStyle(color: EverblushColors.textPrimary),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 20,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: EverblushColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.music_note_rounded,
                color: EverblushColors.textMuted,
              ),
            ),
            title: Text(
              '$moodName Song ${index + 1}',
              style: const TextStyle(color: EverblushColors.textPrimary),
            ),
            subtitle: const Text(
              'Artist Name',
              style: TextStyle(color: EverblushColors.textMuted),
            ),
            trailing: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.play_arrow_rounded,
                color: EverblushColors.primary,
              ),
            ),
          );
        },
      ),
    );
  }
}
