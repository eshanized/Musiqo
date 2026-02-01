// ============================================================================
// Gradient Card - Card with gradient background
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';

/// A card with a gradient background and text overlay.
class GradientCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color? startColor;
  final Color? endColor;
  final IconData? icon;
  final VoidCallback? onTap;
  final double height;

  const GradientCard({
    super.key,
    required this.title,
    this.subtitle,
    this.startColor,
    this.endColor,
    this.icon,
    this.onTap,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              startColor ?? EverblushColors.primary,
              endColor ?? EverblushColors.tertiary,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Icon(
                  icon,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 28,
                ),
              ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
