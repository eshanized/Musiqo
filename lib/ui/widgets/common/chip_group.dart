// ============================================================================
// Chip Group Widget
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';

/// A horizontal scrollable group of filter chips.
class ChipGroup extends StatelessWidget {
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const ChipGroup({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return ChoiceChip(
            label: Text(items[index]),
            selected: isSelected,
            onSelected: (_) => onSelected(index),
            selectedColor: EverblushColors.primary,
            backgroundColor: EverblushColors.surface,
            labelStyle: TextStyle(
              color: isSelected
                  ? EverblushColors.background
                  : EverblushColors.textPrimary,
            ),
            side: BorderSide(
              color: isSelected
                  ? EverblushColors.primary
                  : EverblushColors.outline,
            ),
          );
        },
      ),
    );
  }
}
