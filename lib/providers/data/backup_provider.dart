// ============================================================================
// Backup Provider - Exposes BackupService
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/data/backup_service.dart';
import '../../data/database/database_service.dart';

final backupServiceProvider = Provider((ref) {
  final dbService = ref.read(databaseServiceProvider);
  return BackupService(dbService);
});
