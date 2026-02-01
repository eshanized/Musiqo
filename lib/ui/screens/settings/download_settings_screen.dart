// ============================================================================
// Download Settings Screen
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../core/extensions/formatters.dart';
import '../../../services/cache/cache_service.dart';
import '../../../data/repositories/download_repository.dart';

/// Download settings screen.
class DownloadSettingsScreen extends ConsumerWidget {
  const DownloadSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            value: true,
            onChanged: (value) {
              // TODO: Update setting
            },
            activeColor: EverblushColors.primary,
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
}
