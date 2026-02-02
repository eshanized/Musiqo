// ============================================================================
// Playback Settings Screen
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../data/models/audio_quality.dart';
import '../../../providers/settings/settings_provider.dart';
import '../../navigation/routes.dart';

/// Playback settings screen.
class PlaybackSettingsScreen extends ConsumerWidget {
  const PlaybackSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider);
    final prefsNotifier = ref.read(userPreferencesProvider.notifier);

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
            subtitle: Text(
              prefs.streamingQuality.displayName,
              style: const TextStyle(color: EverblushColors.textMuted),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: EverblushColors.textMuted,
            ),
            onTap: () => _showQualityPicker(
              context,
              ref,
              'Streaming Quality',
              prefs.streamingQuality,
              (quality) => prefsNotifier.setStreamingQuality(quality),
            ),
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
            value: prefs.audioNormalization,
            onChanged: (value) => prefsNotifier.toggleAudioNormalization(),
            activeThumbColor: EverblushColors.primary,
            activeTrackColor: EverblushColors.primary.withValues(alpha: 0.5),
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
            value: prefs.skipSilence,
            onChanged: (value) => prefsNotifier.toggleSkipSilence(),
            activeThumbColor: EverblushColors.primary,
            activeTrackColor: EverblushColors.primary.withValues(alpha: 0.5),
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
            value: prefs.gaplessPlayback,
            onChanged: (value) => prefsNotifier.toggleGaplessPlayback(),
            activeThumbColor: EverblushColors.primary,
            activeTrackColor: EverblushColors.primary.withValues(alpha: 0.5),
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
            onTap: () => context.push(Routes.equalizer),
          ),
        ],
      ),
    );
  }

  void _showQualityPicker(
    BuildContext context,
    WidgetRef ref,
    String title,
    AudioQuality currentQuality,
    void Function(AudioQuality) onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: EverblushColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: EverblushColors.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: EverblushColors.textPrimary,
              ),
            ),
          ),
          ...AudioQuality.values.map(
            (quality) => ListTile(
              leading: Icon(
                quality == currentQuality
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: quality == currentQuality
                    ? EverblushColors.primary
                    : EverblushColors.textMuted,
              ),
              title: Text(
                quality.displayName,
                style: TextStyle(
                  color: quality == currentQuality
                      ? EverblushColors.primary
                      : EverblushColors.textPrimary,
                  fontWeight: quality == currentQuality
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              onTap: () {
                onSelect(quality);
                Navigator.pop(context);
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}
