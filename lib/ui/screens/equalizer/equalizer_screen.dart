// ============================================================================
// Equalizer Screen
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../data/models/equalizer.dart';

/// Equalizer settings screen.
class EqualizerScreen extends StatefulWidget {
  const EqualizerScreen({super.key});

  @override
  State<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends State<EqualizerScreen> {
  EqualizerPreset _selectedPreset = EqualizerPreset.presets.first;
  List<double> _bands = List.from(EqualizerPreset.presets.first.bands);
  bool _enabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EverblushColors.background,
      appBar: AppBar(
        backgroundColor: EverblushColors.background,
        title: const Text(
          'Equalizer',
          style: TextStyle(color: EverblushColors.textPrimary),
        ),
        actions: [
          Switch(
            value: _enabled,
            onChanged: (value) => setState(() => _enabled = value),
            activeThumbColor: EverblushColors.primary,
          ),
        ],
      ),
      body: Column(
        children: [
          // Preset chips
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: EqualizerPreset.presets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final preset = EqualizerPreset.presets[index];
                return ChoiceChip(
                  label: Text(preset.name),
                  selected: _selectedPreset.name == preset.name,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedPreset = preset;
                        _bands = List.from(preset.bands);
                      });
                    }
                  },
                  selectedColor: EverblushColors.primary,
                  labelStyle: TextStyle(
                    color: _selectedPreset.name == preset.name
                        ? EverblushColors.background
                        : EverblushColors.textPrimary,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Frequency sliders
          Expanded(
            child: Opacity(
              opacity: _enabled ? 1.0 : 0.5,
              child: IgnorePointer(
                ignoring: !_enabled,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBand(0, '60Hz'),
                    _buildBand(1, '230Hz'),
                    _buildBand(2, '910Hz'),
                    _buildBand(3, '3.6kHz'),
                    _buildBand(4, '14kHz'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBand(int index, String label) {
    return Column(
      children: [
        Text(
          '+${_bands[index].toStringAsFixed(0)}',
          style: const TextStyle(
            color: EverblushColors.textMuted,
            fontSize: 12,
          ),
        ),
        Expanded(
          child: RotatedBox(
            quarterTurns: -1,
            child: Slider(
              value: _bands[index],
              min: -6,
              max: 6,
              onChanged: (value) {
                setState(() {
                  _bands[index] = value;
                });
              },
              activeColor: EverblushColors.primary,
            ),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: EverblushColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
