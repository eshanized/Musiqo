// ============================================================================
// Equalizer Service - Audio effects control
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/logger.dart';

/// Service to handle equalizer settings
/// 
/// Note: Real equalizer requires platform channel integration
/// or usage of just_audio's pipeline.
/// This is a mock/UI-state implementation for now as cross-platform EQ
/// is complex without specific native plugins.
class EqualizerService {
  static const String _enabledKey = 'eq_enabled';
  static const String _bandsKey = 'eq_bands';
  static const String _presetKey = 'eq_preset';

  bool _enabled = false;
  List<double> _bands = [0, 0, 0, 0, 0]; // 5 bands (60, 230, 910, 4k, 14k)
  String _currentPreset = 'Custom';

  bool get enabled => _enabled;
  List<double> get bands => _bands;
  String get currentPreset => _currentPreset;

  EqualizerService() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_enabledKey) ?? false;
    
    final savedBands = prefs.getStringList(_bandsKey);
    if (savedBands != null) {
      _bands = savedBands.map((e) => double.tryParse(e) ?? 0.0).toList();
    }
    
    _currentPreset = prefs.getString(_presetKey) ?? 'Custom';
  }

  Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
    Log.audio('Equalizer ${enabled ? 'enabled' : 'disabled'}');
    // Apply to audio engine here
  }

  Future<void> setBand(int index, double value) async {
    if (index >= 0 && index < _bands.length) {
      _bands[index] = value;
      _currentPreset = 'Custom';
      await _saveBands();
      // Apply to audio engine here
    }
  }

  Future<void> setPreset(String name, List<double> values) async {
    _currentPreset = name;
    _bands = List.from(values);
    await _saveBands();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_presetKey, name);
    
    Log.audio('Equalizer preset: $name');
  }

  Future<void> _saveBands() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_bandsKey, _bands.map((e) => e.toString()).toList());
  }
}

final equalizerServiceProvider = Provider((ref) => EqualizerService());

final equalizerProvider = StateNotifierProvider<EqualizerNotifier, EqualizerState>((ref) {
  final service = ref.watch(equalizerServiceProvider);
  return EqualizerNotifier(service);
});

class EqualizerState {
  final bool enabled;
  final List<double> bands;
  final String preset;

  EqualizerState({
    required this.enabled,
    required this.bands,
    required this.preset,
  });
}

class EqualizerNotifier extends StateNotifier<EqualizerState> {
  final EqualizerService _service;

  EqualizerNotifier(this._service) : super(EqualizerState(
    enabled: _service.enabled,
    bands: _service.bands,
    preset: _service.currentPreset,
  )) {
    // Refresh state after async load
    Future.delayed(const Duration(milliseconds: 100), () {
      state = EqualizerState(
        enabled: _service.enabled,
        bands: _service.bands,
        preset: _service.currentPreset,
      );
    });
  }

  Future<void> toggleEnabled(bool value) async {
    await _service.setEnabled(value);
    state = EqualizerState(
      enabled: value,
      bands: state.bands,
      preset: state.preset,
    );
  }

  Future<void> updateBand(int index, double value) async {
    await _service.setBand(index, value);
    state = EqualizerState(
      enabled: state.enabled,
      bands: _service.bands,
      preset: 'Custom',
    );
  }

  Future<void> applyPreset(String name, List<double> values) async {
    await _service.setPreset(name, values);
    state = EqualizerState(
      enabled: state.enabled,
      bands: values,
      preset: name,
    );
  }
}
