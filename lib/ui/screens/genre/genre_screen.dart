// ============================================================================
// Genre Screen - Browse by genre
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';

/// Browse songs by genre.
class GenreScreen extends StatelessWidget {
  final String genreId;
  final String genreName;

  const GenreScreen({
    super.key,
    required this.genreId,
    required this.genreName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EverblushColors.background,
      appBar: AppBar(
        backgroundColor: EverblushColors.background,
        title: Text(
          genreName,
          style: const TextStyle(color: EverblushColors.textPrimary),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 25,
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
              '$genreName Song ${index + 1}',
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
