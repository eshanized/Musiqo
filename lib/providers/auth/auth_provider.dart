// ============================================================================
// Auth Provider - State management for user session
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth/google_auth_service.dart';
import '../../providers/data/youtube_provider.dart';

final googleAuthServiceProvider = Provider<GoogleAuthService>((ref) {
  return GoogleAuthService();
});

class AccountInfo {
  final String name;
  final String email;
  final String? thumbnailUrl;
  
  const AccountInfo({required this.name, required this.email, this.thumbnailUrl});
}

final accountInfoProvider = StateProvider<AsyncValue<AccountInfo?>>((ref) {
  return const AsyncValue.data(null);
});

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<bool>>((ref) {
  final service = ref.watch(googleAuthServiceProvider);
  return AuthNotifier(service, ref);
});

class AuthNotifier extends StateNotifier<AsyncValue<bool>> {
  final GoogleAuthService _service;
  final Ref _ref;

  AuthNotifier(this._service, this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      await _service.init();
      if (_service.isLoggedIn) {
        _updateClientAuth();
        // User info cannot be extracted from cookies - show authenticated state
        _ref.read(accountInfoProvider.notifier).state = const AsyncValue.data(
          AccountInfo(name: 'Signed In', email: 'YouTube Music Account'),
        );
      } else {
         _ref.read(accountInfoProvider.notifier).state = const AsyncValue.data(null);
      }
      state = AsyncValue.data(_service.isLoggedIn);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void _updateClientAuth() {
     final client = _ref.read(innerTubeClientProvider);
     client.setAuth(_service.cookies);
  }

  Future<void> login(String rawCookies, {String? visitorData, String? dataSyncId}) async {
    state = const AsyncValue.loading();
    try {
      await _service.login(rawCookies, visitorData: visitorData, dataSyncId: dataSyncId);
      _updateClientAuth();
      _ref.read(accountInfoProvider.notifier).state = const AsyncValue.data(
          AccountInfo(name: 'Signed In', email: 'YouTube Music Account'),
      );
      state = const AsyncValue.data(true);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _service.logout();
      final client = _ref.read(innerTubeClientProvider);
      client.clearAuth();
      _ref.read(accountInfoProvider.notifier).state = const AsyncValue.data(null);
      state = const AsyncValue.data(false);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
