// ============================================================================
// About Screen
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../core/constants/app_constants.dart';

/// About screen with app info and credits.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EverblushColors.background,
      appBar: AppBar(
        backgroundColor: EverblushColors.background,
        title: const Text(
          'About',
          style: TextStyle(color: EverblushColors.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // App icon and name
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        EverblushColors.primary,
                        EverblushColors.tertiary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.music_note_rounded,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: EverblushColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Version ${AppConstants.appVersion}',
                  style: TextStyle(color: EverblushColors.textMuted),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Description
          const Text(
            'A premium music streaming app built with Flutter and love.',
            style: TextStyle(color: EverblushColors.textSecondary),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),
          const Divider(color: EverblushColors.outline),

          // Links
          ListTile(
            leading: const Icon(
              Icons.code_rounded,
              color: EverblushColors.textSecondary,
            ),
            title: const Text(
              'Source Code',
              style: TextStyle(color: EverblushColors.textPrimary),
            ),
            subtitle: const Text(
              'View on GitHub',
              style: TextStyle(color: EverblushColors.textMuted),
            ),
            onTap: () => _launchUrl('https://github.com/eshanized/musiqo'),
          ),

          ListTile(
            leading: const Icon(
              Icons.bug_report_rounded,
              color: EverblushColors.textSecondary,
            ),
            title: const Text(
              'Report a Bug',
              style: TextStyle(color: EverblushColors.textPrimary),
            ),
            onTap: () =>
                _launchUrl('https://github.com/eshanized/musiqo/issues'),
          ),

          ListTile(
            leading: const Icon(
              Icons.person_rounded,
              color: EverblushColors.textSecondary,
            ),
            title: const Text('Developer'),
            subtitle: const Text(
              'Eshan Roy <eshanized@proton.me>',
              style: TextStyle(color: EverblushColors.textMuted),
            ),
          ),

          const Divider(color: EverblushColors.outline),

          ListTile(
            leading: const Icon(
              Icons.gavel_rounded,
              color: EverblushColors.textSecondary,
            ),
            title: const Text(
              'Licenses',
              style: TextStyle(color: EverblushColors.textPrimary),
            ),
            onTap: () => showLicensePage(
              context: context,
              applicationName: AppConstants.appName,
              applicationVersion: AppConstants.appVersion,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
