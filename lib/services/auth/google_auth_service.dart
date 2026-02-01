// ============================================================================
// Google Auth Service - WebView based login
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/utils/logger.dart';

class GoogleAuthService {
  final _storage = const FlutterSecureStorage();
  
  static const _kCookies = 'auth_cookies';
  static const _kVisitorData = 'auth_visitor_data';
  static const _kDataSyncId = 'auth_data_sync_id';
  
  Map<String, String>? _cookies;
  String? _visitorData;
  String? _dataSyncId;

  bool get isLoggedIn => _cookies != null && _cookies!.isNotEmpty;
  Map<String, String> get cookies => _cookies ?? {};
  String? get visitorData => _visitorData;
  String? get dataSyncId => _dataSyncId;

  Future<void> init() async {
    try {
      final cookiesStr = await _storage.read(key: _kCookies);
      if (cookiesStr != null) {
        _cookies = _parseCookieString(cookiesStr);
      }
      _visitorData = await _storage.read(key: _kVisitorData);
      _dataSyncId = await _storage.read(key: _kDataSyncId);
    } catch (e) {
      Log.error('Failed to load auth data: $e');
    }
  }

  Future<void> login(String rawCookies, {String? visitorData, String? dataSyncId}) async {
    _cookies = _parseCookieString(rawCookies);
    _visitorData = visitorData;
    _dataSyncId = dataSyncId;
    
    await _storage.write(key: _kCookies, value: rawCookies);
    if (visitorData != null) await _storage.write(key: _kVisitorData, value: visitorData);
    if (dataSyncId != null) await _storage.write(key: _kDataSyncId, value: dataSyncId);
    
    Log.info('User logged in successfully');
  }

  Future<void> logout() async {
    _cookies = null;
    _visitorData = null;
    _dataSyncId = null;
    
    await _storage.delete(key: _kCookies);
    await _storage.delete(key: _kVisitorData);
    await _storage.delete(key: _kDataSyncId);
    
    Log.info('User logged out');
  }
  
  /// Helper to extract SAPISID for hashing
  String? get sapisid {
    return _cookies?['SAPISID'];
  }

  Map<String, String> _parseCookieString(String cookie) {
    final result = <String, String>{};
    final parts = cookie.split(';');
    for (var part in parts) {
      final pair = part.trim().split('=');
      if (pair.length == 2) {
        result[pair[0]] = pair[1];
      }
    }
    return result;
  }
}
