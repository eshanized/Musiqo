// ============================================================================
// Google Auth Service - Manages optional Google authentication
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
//
// Sign-in is OPTIONAL - the app works fine without it.
// Logging in enables personalized recommendations and library sync.
// ============================================================================

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/logger.dart';

/// Keys for storing auth data
class AuthKeys {
  static const String innerTubeCookie = 'auth_innertube_cookie';
  static const String visitorData = 'auth_visitor_data';
  static const String dataSyncId = 'auth_data_sync_id';
  static const String accountName = 'auth_account_name';
  static const String accountEmail = 'auth_account_email';
  static const String accountThumbnail = 'auth_account_thumbnail';
}

/// Account information for logged-in user
class AccountInfo {
  final String name;
  final String email;
  final String? thumbnailUrl;

  const AccountInfo({
    required this.name,
    required this.email,
    this.thumbnailUrl,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'thumbnailUrl': thumbnailUrl,
  };

  factory AccountInfo.fromJson(Map<String, dynamic> json) => AccountInfo(
    name: json['name'] as String,
    email: json['email'] as String,
    thumbnailUrl: json['thumbnailUrl'] as String?,
  );
}

/// Service for managing Google authentication.
/// 
/// HOW IT WORKS:
/// We don't use Google Sign-In SDK. Instead, we use a WebView to let the user
/// log in to YouTube Music directly. We then capture the cookies and use them
/// for authenticated API requests.
/// 
/// This approach is used by most third-party YouTube Music clients like
/// BlackHole, OpenTune, and Echo-Music.
/// 
/// NOTE: We use SharedPreferences for simplicity. The cookie data is
/// session-based and not highly sensitive (no passwords stored).
class GoogleAuthService {
  // Cached values for performance
  String? _cachedCookie;
  String? _cachedVisitorData;
  String? _cachedDataSyncId;
  AccountInfo? _cachedAccountInfo;

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final cookie = await getCookie();
    if (cookie == null || cookie.isEmpty) return false;
    
    // Check if SAPISID is present in cookie (required for auth)
    return cookie.contains('SAPISID');
  }

  /// Get the stored cookie
  Future<String?> getCookie() async {
    if (_cachedCookie != null) return _cachedCookie;
    final prefs = await SharedPreferences.getInstance();
    _cachedCookie = prefs.getString(AuthKeys.innerTubeCookie);
    return _cachedCookie;
  }

  /// Get visitor data
  Future<String?> getVisitorData() async {
    if (_cachedVisitorData != null) return _cachedVisitorData;
    final prefs = await SharedPreferences.getInstance();
    _cachedVisitorData = prefs.getString(AuthKeys.visitorData);
    return _cachedVisitorData;
  }

  /// Get data sync ID
  Future<String?> getDataSyncId() async {
    if (_cachedDataSyncId != null) return _cachedDataSyncId;
    final prefs = await SharedPreferences.getInstance();
    _cachedDataSyncId = prefs.getString(AuthKeys.dataSyncId);
    return _cachedDataSyncId;
  }

  /// Get account info
  Future<AccountInfo?> getAccountInfo() async {
    if (_cachedAccountInfo != null) return _cachedAccountInfo;

    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(AuthKeys.accountName);
    final email = prefs.getString(AuthKeys.accountEmail);

    if (name == null) return null;

    _cachedAccountInfo = AccountInfo(
      name: name,
      email: email ?? '',
      thumbnailUrl: prefs.getString(AuthKeys.accountThumbnail),
    );
    return _cachedAccountInfo;
  }

  /// Save authentication data after successful login
  Future<void> saveAuthData({
    required String cookie,
    required String visitorData,
    required String dataSyncId,
    required String accountName,
    required String accountEmail,
    String? accountThumbnail,
  }) async {
    Log.info('Saving auth data for $accountName', tag: 'Auth');

    final prefs = await SharedPreferences.getInstance();
    
    // Store all auth data
    await prefs.setString(AuthKeys.innerTubeCookie, cookie);
    await prefs.setString(AuthKeys.visitorData, visitorData);
    await prefs.setString(AuthKeys.dataSyncId, dataSyncId);
    await prefs.setString(AuthKeys.accountName, accountName);
    await prefs.setString(AuthKeys.accountEmail, accountEmail);
    if (accountThumbnail != null) {
      await prefs.setString(AuthKeys.accountThumbnail, accountThumbnail);
    }

    // Update cache
    _cachedCookie = cookie;
    _cachedVisitorData = visitorData;
    _cachedDataSyncId = dataSyncId;
    _cachedAccountInfo = AccountInfo(
      name: accountName,
      email: accountEmail,
      thumbnailUrl: accountThumbnail,
    );
  }

  /// Log out and clear all auth data
  Future<void> logout() async {
    Log.info('Logging out', tag: 'Auth');

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AuthKeys.innerTubeCookie);
    await prefs.remove(AuthKeys.visitorData);
    await prefs.remove(AuthKeys.dataSyncId);
    await prefs.remove(AuthKeys.accountName);
    await prefs.remove(AuthKeys.accountEmail);
    await prefs.remove(AuthKeys.accountThumbnail);

    // Clear cache
    _cachedCookie = null;
    _cachedVisitorData = null;
    _cachedDataSyncId = null;
    _cachedAccountInfo = null;
  }

  /// Generate SAPISID hash for authenticated requests
  /// 
  /// YouTube requires this hash in the Authorization header for authenticated
  /// requests. It's SHA-1 of the current timestamp + SAPISID + origin.
  String? generateSapisidHash(String origin) {
    final cookie = _cachedCookie;
    if (cookie == null) return null;

    // Extract SAPISID from cookie
    final sapisidMatch = RegExp(r'SAPISID=([^;]+)').firstMatch(cookie);
    if (sapisidMatch == null) return null;

    final sapisid = sapisidMatch.group(1)!;
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    // SHA-1 hash of "timestamp SAPISID origin"
    final input = '$timestamp $sapisid $origin';
    final hash = sha1.convert(utf8.encode(input)).toString();

    return 'SAPISIDHASH ${timestamp}_$hash';
  }

  /// Parse cookie string to map
  static Map<String, String> parseCookie(String cookie) {
    final map = <String, String>{};
    for (final part in cookie.split(';')) {
      final trimmed = part.trim();
      final equals = trimmed.indexOf('=');
      if (equals > 0) {
        final key = trimmed.substring(0, equals).trim();
        final value = trimmed.substring(equals + 1).trim();
        map[key] = value;
      }
    }
    return map;
  }
}
