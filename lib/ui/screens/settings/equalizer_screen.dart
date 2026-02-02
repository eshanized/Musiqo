// ============================================================================
// Equalizer Screen - Audio effects UI
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../core/theme/everblush_colors.dart';
import '../../../services/audio/equalizer_service.dart';

class EqualizerScreen extends ConsumerWidget {
  const EqualizerScreen({super.key});

  static const _presets = {
    'Flat': [0.0, 0.0, 0.0, 0.0, 0.0],
    'Bass Boost': [5.0, 3.0, 0.0, 0.0, 0.0],
    'Treble Boost': [0.0, 0.0, 0.0, 3.0, 5.0],
    'Rock': [4.0, 2.0, -2.0, 3.0, 5.0],
    'Pop': [-1.0, 2.0, 4.0, 2.0, -1.0],
    'Jazz': [3.0, 1.0, 2.0, 1.0, 3.0],
    'Classical': [4.0, 3.0, 0.0, 3.0, 4.0],
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(equalizerProvider);
    final notifier = ref.read(equalizerProvider.notifier);

    return Scaffold(
      backgroundColor: EverblushColors.background,
      appBar: AppBar(
        title: const Text('Equalizer'),
        backgroundColor: EverblushColors.background,
        elevation: 0,
        actions: [
          Switch(
            value: state.enabled,
            onChanged: (value) => notifier.toggleEnabled(value),
            activeThumbColor: EverblushColors.primary,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Presets
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _presets.length,
              itemBuilder: (context, index) {
                final name = _presets.keys.elementAt(index);
                final isSelected = state.preset == name;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(name),
                    selected: isSelected,
                    onSelected: state.enabled
                        ? (_) => notifier.applyPreset(name, _presets[name]!)
                        : null,
                    backgroundColor: EverblushColors.surfaceVariant,
                    selectedColor: EverblushColors.primary.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? EverblushColors.primary : EverblushColors.textPrimary,
                    ),
                  ),
                );
              },
            ),
          ),
          
          const Spacer(),
          
          // Bands
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSlider(context, 0, '60Hz', state, notifier),
                _buildSlider(context, 1, '230Hz', state, notifier),
                _buildSlider(context, 2, '910Hz', state, notifier),
                _buildSlider(context, 3, '4kHz', state, notifier),
                _buildSlider(context, 4, '14kHz', state, notifier),
              ],
            ),
          ),
          
          const Spacer(),
          
          if (!state.enabled)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Equalizer is disabled',
                style: TextStyle(color: EverblushColors.textMuted),
              ),
            ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSlider(
    BuildContext context, 
    int index, 
    String label, 
    EqualizerState state, 
    EqualizerNotifier notifier
  ) {
    // Normalize value from -10..10 range to 0..1 for Slider
    // Actually Slider supports min/max
    final value = state.bands[index];
    
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              ),
              child: Slider(
                value: value,
                min: -10,
                max: 10,
                divisions: 20,
                activeColor: state.enabled ? EverblushColors.primary : EverblushColors.textMuted,
                inactiveColor: EverblushColors.surfaceVariant,
                onChanged: state.enabled
                    ? (v) => notifier.updateBand(index, v)
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          label,
          style: TextStyle(
            color: state.enabled ? EverblushColors.textPrimary : EverblushColors.textMuted,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${value > 0 ? '+' : ''}${value.toStringAsFixed(1)} dB',
          style: TextStyle(
            color: state.enabled ? EverblushColors.primary : EverblushColors.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
