// ============================================================================
// Radio Screen - Radio station playback
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';

/// Radio station screen with endless playback.
class RadioScreen extends StatelessWidget {
  final String radioId;
  final String radioName;

  const RadioScreen({
    super.key,
    required this.radioId,
    required this.radioName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EverblushColors.background,
      appBar: AppBar(
        backgroundColor: EverblushColors.background,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Radio',
              style: TextStyle(fontSize: 12, color: EverblushColors.textMuted),
            ),
            Text(
              radioName,
              style: const TextStyle(
                fontSize: 16,
                color: EverblushColors.textPrimary,
              ),
            ),
          ],
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
              'Radio Track ${index + 1}',
              style: const TextStyle(color: EverblushColors.textPrimary),
            ),
            subtitle: const Text(
              'Artist Name',
              style: TextStyle(color: EverblushColors.textMuted),
            ),
          );
        },
      ),
    );
  }
}
