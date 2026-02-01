// ============================================================================
// Equalizer Model - Audio equalizer presets
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

/// Equalizer preset
class EqualizerPreset {
  final String name;
  final List<double> bands;

  const EqualizerPreset({required this.name, required this.bands});

  static const List<EqualizerPreset> presets = [
    EqualizerPreset(name: 'Flat', bands: [0, 0, 0, 0, 0]),
    EqualizerPreset(name: 'Bass Boost', bands: [6, 4, 0, 0, 0]),
    EqualizerPreset(name: 'Treble Boost', bands: [0, 0, 0, 4, 6]),
    EqualizerPreset(name: 'Rock', bands: [4, 2, -1, 3, 4]),
    EqualizerPreset(name: 'Pop', bands: [-1, 2, 4, 2, -1]),
    EqualizerPreset(name: 'Jazz', bands: [3, 1, -1, 1, 3]),
    EqualizerPreset(name: 'Classical', bands: [4, 2, -1, 2, 4]),
    EqualizerPreset(name: 'Electronic', bands: [4, 3, 0, 3, 4]),
  ];
}

/// Equalizer state
class EqualizerState {
  final bool enabled;
  final EqualizerPreset preset;
  final List<double> customBands;

  const EqualizerState({
    this.enabled = false,
    this.preset = const EqualizerPreset(name: 'Flat', bands: [0, 0, 0, 0, 0]),
    this.customBands = const [0, 0, 0, 0, 0],
  });

  EqualizerState copyWith({
    bool? enabled,
    EqualizerPreset? preset,
    List<double>? customBands,
  }) {
    return EqualizerState(
      enabled: enabled ?? this.enabled,
      preset: preset ?? this.preset,
      customBands: customBands ?? this.customBands,
    );
  }
}
