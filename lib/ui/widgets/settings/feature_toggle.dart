// ============================================================================
// Feature Toggle - Toggle setting item
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';

/// A toggle switch setting item.
class FeatureToggle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final IconData? icon;

  const FeatureToggle({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
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
      secondary: icon != null
          ? Icon(icon, color: EverblushColors.textSecondary)
          : null,
      activeThumbColor: EverblushColors.primary,
    );
  }
}
