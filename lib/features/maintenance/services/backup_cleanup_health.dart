import 'package:flutter/foundation.dart';
import '../models/backup_cleanup_result.dart';

enum BackupCleanupHealth { notChecked, healthy, incomplete, unavailable }

/// Session state: a successful backup does not clear an unresolved purge error.
class BackupCleanupMonitor extends ValueNotifier<BackupCleanupHealth> {
  BackupCleanupMonitor() : super(BackupCleanupHealth.notChecked);
  static final instance = BackupCleanupMonitor();
  Future<BackupCleanupResult> run(
    Future<BackupCleanupResult> Function() cleanup,
  ) async {
    try {
      final result = await cleanup();
      value = result.failedPaths.isEmpty
          ? BackupCleanupHealth.healthy
          : BackupCleanupHealth.incomplete;
      return result;
    } catch (_) {
      value = BackupCleanupHealth.unavailable;
      rethrow;
    }
  }
}
