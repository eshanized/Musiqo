// ============================================================================
// Settings Screen - App configuration with optional Google account
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../services/auth/google_auth_service.dart';
import '../../navigation/routes.dart';

/// Settings screen with app configuration options.
/// 
/// Includes an optional Google account section - signing in is not required
/// but enables personalized recommendations and library sync.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedInAsync = ref.watch(isLoggedInProvider);
    final accountInfoAsync = ref.watch(accountInfoProvider);

    return Scaffold(
      backgroundColor: EverblushColors.background,
      appBar: AppBar(
        backgroundColor: EverblushColors.background,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: EverblushColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        children: [
          // Account section with login/logout
          _sectionHeader('Account'),
          _buildAccountSection(context, ref, isLoggedInAsync, accountInfoAsync),
          
          const Divider(color: EverblushColors.outline, height: 32),
          
          // Playback section
          _sectionHeader('Playback'),
          _settingsTile(
            icon: Icons.high_quality_outlined,
            title: 'Audio Quality',
            subtitle: 'High (320 kbps)',
            onTap: () {},
          ),
          _switchTile(
            icon: Icons.skip_next_outlined,
            title: 'Gapless Playback',
            subtitle: 'No pause between songs',
            value: true,
            onChanged: (value) {},
          ),
          _switchTile(
            icon: Icons.volume_down_outlined,
            title: 'Audio Normalization',
            subtitle: 'Maintain consistent volume',
            value: false,
            onChanged: (value) {},
          ),
          _switchTile(
            icon: Icons.fast_forward_outlined,
            title: 'Skip Silence',
            subtitle: 'Skip silent parts in tracks',
            value: false,
            onChanged: (value) {},
          ),
          
          const Divider(color: EverblushColors.outline, height: 32),
          
          // Downloads section
          _sectionHeader('Downloads'),
          _settingsTile(
            icon: Icons.download_outlined,
            title: 'Download Quality',
            subtitle: 'High (320 kbps)',
            onTap: () {},
          ),
          _settingsTile(
            icon: Icons.folder_outlined,
            title: 'Download Location',
            subtitle: 'Internal storage',
            onTap: () {},
          ),
          _switchTile(
            icon: Icons.wifi_outlined,
            title: 'Download over WiFi only',
            subtitle: 'Save mobile data',
            value: true,
            onChanged: (value) {},
          ),
          
          const Divider(color: EverblushColors.outline, height: 32),
          
          // Storage section
          _sectionHeader('Storage'),
          _settingsTile(
            icon: Icons.storage_outlined,
            title: 'Clear Cache',
            subtitle: 'Free up space',
            onTap: () {},
          ),
          _settingsTile(
            icon: Icons.delete_outline,
            title: 'Clear Search History',
            subtitle: 'Remove all recent searches',
            onTap: () {},
          ),
          
          const Divider(color: EverblushColors.outline, height: 32),
          
          // About section
          _sectionHeader('About'),
          _settingsTile(
            icon: Icons.info_outlined,
            title: 'Version',
            subtitle: AppConstants.appVersion,
            onTap: () {},
          ),
          _settingsTile(
            icon: Icons.code_outlined,
            title: 'Open Source Licenses',
            onTap: () {},
          ),
          _settingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {},
          ),
          
          const SizedBox(height: 24),
          
          // App credit
          Center(
            child: Column(
              children: [
                const Text(
                  'Made with ❤️ by Eshan Roy',
                  style: TextStyle(
                    color: EverblushColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppConstants.appName,
                  style: const TextStyle(
                    color: EverblushColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  /// Build the account section based on login state
  Widget _buildAccountSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<bool> isLoggedInAsync,
    AsyncValue<AccountInfo?> accountInfoAsync,
  ) {
    return isLoggedInAsync.when(
      loading: () => const ListTile(
        leading: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        title: Text('Loading...', style: TextStyle(color: EverblushColors.textPrimary)),
      ),
      error: (_, __) => _settingsTile(
        icon: Icons.person_outlined,
        title: 'Sign in with Google',
        subtitle: 'Sync your library and get personalized recommendations',
        onTap: () => context.push(Routes.login),
      ),
      data: (isLoggedIn) {
        if (!isLoggedIn) {
          return Column(
            children: [
              _settingsTile(
                icon: Icons.person_outlined,
                title: 'Sign in with Google',
                subtitle: 'Sync your library and get personalized recommendations',
                onTap: () => context.push(Routes.login),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Sign-in is optional. Musiqo works great without it!',
                  style: TextStyle(
                    color: EverblushColors.textMuted,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          );
        }

        // User is logged in - show account info
        return accountInfoAsync.when(
          loading: () => const ListTile(
            leading: CircleAvatar(
              backgroundColor: EverblushColors.surfaceVariant,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            title: Text('Loading...', style: TextStyle(color: EverblushColors.textPrimary)),
          ),
          error: (_, __) => _loggedInTile(
            context,
            ref,
            name: 'YouTube User',
            email: null,
            thumbnailUrl: null,
          ),
          data: (info) => _loggedInTile(
            context,
            ref,
            name: info?.name ?? 'YouTube User',
            email: info?.email,
            thumbnailUrl: info?.thumbnailUrl,
          ),
        );
      },
    );
  }

  /// Build tile for logged in user
  Widget _loggedInTile(
    BuildContext context,
    WidgetRef ref, {
    required String name,
    String? email,
    String? thumbnailUrl,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: EverblushColors.primary,
        backgroundImage: thumbnailUrl != null ? NetworkImage(thumbnailUrl) : null,
        child: thumbnailUrl == null
            ? Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: const TextStyle(color: Colors.white),
              )
            : null,
      ),
      title: Text(
        name,
        style: const TextStyle(color: EverblushColors.textPrimary),
      ),
      subtitle: email != null && email.isNotEmpty
          ? Text(
              email,
              style: const TextStyle(
                fontSize: 12,
                color: EverblushColors.textMuted,
              ),
            )
          : const Text(
              'Signed in with Google',
              style: TextStyle(
                fontSize: 12,
                color: EverblushColors.success,
              ),
            ),
      trailing: TextButton(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: EverblushColors.surface,
              title: const Text(
                'Sign out?',
                style: TextStyle(color: EverblushColors.textPrimary),
              ),
              content: const Text(
                'You can sign in again anytime.',
                style: TextStyle(color: EverblushColors.textSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Sign out',
                    style: TextStyle(color: EverblushColors.error),
                  ),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            await ref.read(authNotifierProvider.notifier).logout();
          }
        },
        child: const Text(
          'Sign out',
          style: TextStyle(color: EverblushColors.error),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: EverblushColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: EverblushColors.textSecondary),
      title: Text(
        title,
        style: const TextStyle(color: EverblushColors.textPrimary),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: EverblushColors.textMuted,
              ),
            )
          : null,
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: EverblushColors.textMuted,
      ),
      onTap: onTap,
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: EverblushColors.textSecondary),
      title: Text(
        title,
        style: const TextStyle(color: EverblushColors.textPrimary),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: EverblushColors.textMuted,
              ),
            )
          : null,
      value: value,
      onChanged: onChanged,
      activeColor: EverblushColors.primary,
    );
  }
}
