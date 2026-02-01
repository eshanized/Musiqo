// ============================================================================
// Auth Provider - Riverpod state for optional Google authentication
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/auth/google_auth_service.dart';

/// Provider for the auth service
final authServiceProvider = Provider<GoogleAuthService>((ref) {
  return GoogleAuthService();
});

/// Provider to check if user is logged in
final isLoggedInProvider = FutureProvider<bool>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return authService.isLoggedIn();
});

/// Provider for account info (null if not logged in)
final accountInfoProvider = FutureProvider<AccountInfo?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final isLoggedIn = await authService.isLoggedIn();
  if (!isLoggedIn) return null;
  return authService.getAccountInfo();
});

/// Provider for cookie (used by InnerTube client)
final authCookieProvider = FutureProvider<String?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return authService.getCookie();
});

/// Provider for visitor data
final visitorDataProvider = FutureProvider<String?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return authService.getVisitorData();
});

/// Provider for data sync ID
final dataSyncIdProvider = FutureProvider<String?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return authService.getDataSyncId();
});

/// Notifier for auth state changes
class AuthNotifier extends StateNotifier<AsyncValue<bool>> {
  final GoogleAuthService _authService;
  final Ref _ref;

  AuthNotifier(this._authService, this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    final isLoggedIn = await _authService.isLoggedIn();
    state = AsyncValue.data(isLoggedIn);
  }

  /// Save login data and update state
  Future<void> login({
    required String cookie,
    required String visitorData,
    required String dataSyncId,
    required String accountName,
    required String accountEmail,
    String? accountThumbnail,
  }) async {
    await _authService.saveAuthData(
      cookie: cookie,
      visitorData: visitorData,
      dataSyncId: dataSyncId,
      accountName: accountName,
      accountEmail: accountEmail,
      accountThumbnail: accountThumbnail,
    );

    // Refresh providers
    _ref.invalidate(isLoggedInProvider);
    _ref.invalidate(accountInfoProvider);
    _ref.invalidate(authCookieProvider);
    _ref.invalidate(visitorDataProvider);
    _ref.invalidate(dataSyncIdProvider);

    state = const AsyncValue.data(true);
  }

  /// Logout and clear all auth data
  Future<void> logout() async {
    await _authService.logout();

    // Refresh providers
    _ref.invalidate(isLoggedInProvider);
    _ref.invalidate(accountInfoProvider);
    _ref.invalidate(authCookieProvider);
    _ref.invalidate(visitorDataProvider);
    _ref.invalidate(dataSyncIdProvider);

    state = const AsyncValue.data(false);
  }
}

/// Provider for auth state notifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<bool>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService, ref);
});
