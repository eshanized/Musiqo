// ============================================================================
// Download Settings Screen
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../core/extensions/formatters.dart';
import '../../../data/models/audio_quality.dart';
import '../../../services/cache/cache_service.dart';
import '../../../data/repositories/download_repository.dart';
import '../../../providers/settings/settings_provider.dart';

/// Download settings screen.
class DownloadSettingsScreen extends ConsumerWidget {
  const DownloadSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider);
    final prefsNotifier = ref.read(userPreferencesProvider.notifier);

    return Scaffold(
      backgroundColor: EverblushColors.background,
      appBar: AppBar(
        backgroundColor: EverblushColors.background,
        title: const Text(
          'Download Settings',
          style: TextStyle(color: EverblushColors.textPrimary),
        ),
      ),
      body: ListView(
        children: [
          // Download quality
          ListTile(
            leading: const Icon(
              Icons.high_quality_rounded,
              color: EverblushColors.textSecondary,
            ),
            title: const Text(
              'Download Quality',
              style: TextStyle(color: EverblushColors.textPrimary),
            ),
            subtitle: Text(
              prefs.downloadQuality.displayName,
              style: const TextStyle(color: EverblushColors.textMuted),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: EverblushColors.textMuted,
            ),
            onTap: () => _showQualityPicker(context, ref, prefs.downloadQuality),
          ),

          // WiFi only
          SwitchListTile(
            secondary: const Icon(
              Icons.wifi_rounded,
              color: EverblushColors.textSecondary,
            ),
            title: const Text(
              'Download over WiFi only',
              style: TextStyle(color: EverblushColors.textPrimary),
            ),
            subtitle: const Text(
              'Prevent downloads on mobile data',
              style: TextStyle(color: EverblushColors.textMuted),
            ),
            value: prefs.downloadOverWifiOnly,
            onChanged: (value) => prefsNotifier.toggleWifiOnlyDownload(),
            activeThumbColor: EverblushColors.primary,
            activeTrackColor: EverblushColors.primary.withValues(alpha: 0.5),
          ),

          const Divider(color: EverblushColors.outline),

          // Storage info
          FutureBuilder<int>(
            future: DownloadRepository().getTotalSize(),
            builder: (context, snapshot) {
              final size = snapshot.data ?? 0;
              return ListTile(
                leading: const Icon(
                  Icons.storage_rounded,
                  color: EverblushColors.textSecondary,
                ),
                title: const Text(
                  'Downloads Storage',
                  style: TextStyle(color: EverblushColors.textPrimary),
                ),
                subtitle: Text(
                  Formatters.fileSize(size),
                  style: const TextStyle(color: EverblushColors.textMuted),
                ),
              );
            },
          ),

          // Cache info
          FutureBuilder<int>(
            future: CacheService.getCacheSize(),
            builder: (context, snapshot) {
              final size = snapshot.data ?? 0;
              return ListTile(
                leading: const Icon(
                  Icons.cached_rounded,
                  color: EverblushColors.textSecondary,
                ),
                title: const Text(
                  'Cache Size',
                  style: TextStyle(color: EverblushColors.textPrimary),
                ),
                subtitle: Text(
                  Formatters.fileSize(size),
                  style: const TextStyle(color: EverblushColors.textMuted),
                ),
                trailing: TextButton(
                  onPressed: () async {
                    await CacheService.clearAllCache();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cache cleared')),
                      );
                    }
                  },
                  child: const Text('Clear'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showQualityPicker(BuildContext context, WidgetRef ref, AudioQuality currentQuality) {
    final prefsNotifier = ref.read(userPreferencesProvider.notifier);
    
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
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Download Quality',
              style: TextStyle(
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
                prefsNotifier.setDownloadQuality(quality);
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
