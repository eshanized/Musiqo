// ============================================================================
// Settings Item - Single settings row
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';

/// A single settings row item.
class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: EverblushColors.textSecondary),
      title: Text(
        title,
        style: const TextStyle(color: EverblushColors.textPrimary),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(
                color: EverblushColors.textMuted,
                fontSize: 12,
              ),
            )
          : null,
      trailing:
          trailing ??
          const Icon(
            Icons.chevron_right_rounded,
            color: EverblushColors.textMuted,
          ),
    );
  }
}
