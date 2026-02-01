// ============================================================================
// Settings Service - Persist user preferences
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/user_preferences.dart';
import '../../core/constants/storage_keys.dart';

/// Service for persisting and retrieving user settings.
class SettingsService {
  SharedPreferences? _prefs;

  /// Initialize the service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get user preferences
  UserPreferences getPreferences() {
    final json = _prefs?.getString(StorageKeys.userPreferences);
    if (json == null) return const UserPreferences();

    try {
      return UserPreferences.fromJson(jsonDecode(json));
    } catch (_) {
      return const UserPreferences();
    }
  }

  /// Save user preferences
  Future<void> savePreferences(UserPreferences prefs) async {
    final json = jsonEncode(prefs.toJson());
    await _prefs?.setString(StorageKeys.userPreferences, json);
  }

  /// Get a specific setting
  T? get<T>(String key) {
    return _prefs?.get(key) as T?;
  }

  /// Set a specific setting
  Future<void> set<T>(String key, T value) async {
    if (value is String) {
      await _prefs?.setString(key, value);
    } else if (value is int) {
      await _prefs?.setInt(key, value);
    } else if (value is double) {
      await _prefs?.setDouble(key, value);
    } else if (value is bool) {
      await _prefs?.setBool(key, value);
    } else if (value is List<String>) {
      await _prefs?.setStringList(key, value);
    }
  }

  /// Remove a setting
  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }
}
