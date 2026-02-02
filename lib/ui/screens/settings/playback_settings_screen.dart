// ============================================================================
// Playback Settings Screen
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/everblush_colors.dart';

/// Playback settings screen.
class PlaybackSettingsScreen extends ConsumerWidget {
  const PlaybackSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: EverblushColors.background,
      appBar: AppBar(
        backgroundColor: EverblushColors.background,
        title: const Text(
          'Playback Settings',
          style: TextStyle(color: EverblushColors.textPrimary),
        ),
      ),
      body: ListView(
        children: [
          // Streaming quality
          ListTile(
            leading: const Icon(
              Icons.wifi_rounded,
              color: EverblushColors.textSecondary,
            ),
            title: const Text(
              'Streaming Quality',
              style: TextStyle(color: EverblushColors.textPrimary),
            ),
            subtitle: const Text(
              'High (320 kbps)',
              style: TextStyle(color: EverblushColors.textMuted),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: EverblushColors.textMuted,
            ),
            onTap: () {
              // TODO: Show quality picker
            },
          ),

          const Divider(color: EverblushColors.outline),

          // Audio normalization
          SwitchListTile(
            secondary: const Icon(
              Icons.graphic_eq_rounded,
              color: EverblushColors.textSecondary,
            ),
            title: const Text(
              'Audio Normalization',
              style: TextStyle(color: EverblushColors.textPrimary),
            ),
            subtitle: const Text(
              'Balance volume across songs',
              style: TextStyle(color: EverblushColors.textMuted),
            ),
            value: false,
            onChanged: (value) {
              // TODO: Update setting
            },
            activeThumbColor: EverblushColors.primary,
          ),

          // Skip silence
          SwitchListTile(
            secondary: const Icon(
              Icons.skip_next_rounded,
              color: EverblushColors.textSecondary,
            ),
            title: const Text(
              'Skip Silence',
              style: TextStyle(color: EverblushColors.textPrimary),
            ),
            subtitle: const Text(
              'Skip silent parts in songs',
              style: TextStyle(color: EverblushColors.textMuted),
            ),
            value: false,
            onChanged: (value) {
              // TODO: Update setting
            },
            activeThumbColor: EverblushColors.primary,
          ),

          // Gapless playback
          SwitchListTile(
            secondary: const Icon(
              Icons.playlist_play_rounded,
              color: EverblushColors.textSecondary,
            ),
            title: const Text(
              'Gapless Playback',
              style: TextStyle(color: EverblushColors.textPrimary),
            ),
            subtitle: const Text(
              'No gaps between songs',
              style: TextStyle(color: EverblushColors.textMuted),
            ),
            value: true,
            onChanged: (value) {
              // TODO: Update setting
            },
            activeThumbColor: EverblushColors.primary,
          ),

          const Divider(color: EverblushColors.outline),

          // Equalizer
          ListTile(
            leading: const Icon(
              Icons.equalizer_rounded,
              color: EverblushColors.textSecondary,
            ),
            title: const Text(
              'Equalizer',
              style: TextStyle(color: EverblushColors.textPrimary),
            ),
            subtitle: const Text(
              'Adjust audio frequencies',
              style: TextStyle(color: EverblushColors.textMuted),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: EverblushColors.textMuted,
            ),
            onTap: () {
              // TODO: Navigate to equalizer
            },
          ),
        ],
      ),
    );
  }
}
