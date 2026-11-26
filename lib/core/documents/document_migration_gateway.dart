import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../database/database_service.dart';
import '../settings/application_settings_service.dart';
import '../settings/macos_directory_access_service.dart';
import '../../features/maintenance/services/backup_directory_access.dart';
import 'document_root_migration.dart';
import 'document_activity_coordinator.dart';

final documentRootRevision = ValueNotifier<int>(0);
typedef MigrationProgress = void Function(String phase, int done, int total);

abstract class DocumentMigrationGateway {
  bool get pending;
  bool get canAuthorize;
  Future<String?> root();
  Future<bool> dmpEnabled();
  Future<String?> choose(String title);
  Future<void> open(String path);
  Future<void> authorize(String path, String title);
  Future<DocumentMigrationPlan> plan(String path);
  Future<bool> execute(
    DocumentMigrationPlan plan,
    MigrationConsent consent,
    MigrationCancellation cancellation,
    MigrationProgress progress,
  );
  Future<List<MigrationRecoveryDetails>> details();
  Future<List<MigrationRecovery>> recover();
}

class LocalDocumentMigrationGateway implements DocumentMigrationGateway {
  @override
  bool get pending => DocumentActivityCoordinator.shared.recoveryRequired;
  @override
  bool get canAuthorize => Platform.isMacOS;
  Future<DocumentRootMigration> _service({MigrationProgress? progress}) async =>
      DocumentRootMigration(
        database: await DatabaseService.database,
        support: await getApplicationSupportDirectory(),
        progress: progress,
      );
  @override
  Future<String?> root() =>
      const ApplicationSettingsService().getString(migrationRootKey);
  @override
  Future<bool> dmpEnabled() async => [
    'true',
    '1',
  ].contains(await const ApplicationSettingsService().getString('dmp_enabled'));
  @override
  Future<String?> choose(String title) async {
    final lease = await (await _service()).chooseDestination(title);
    try {
      return lease?.path;
    } finally {
      await lease?.release();
    }
  }

  @override
  Future<void> open(String path) =>
      DocumentActivityCoordinator.shared.activity(() async {
        final lease = await const BackupDirectoryAccess().acquire(path);
        try {
          if (!p.equals(lease.path, path)) {
            throw DirectoryAuthorizationRequired(path);
          }
          if (!await Directory(path).exists()) {
            throw FileSystemException('directory_unavailable', path);
          }
          if (!await launchUrl(
            Uri.directory(path, windows: Platform.isWindows),
          )) {
            throw const FileSystemException('folder_open_failed');
          }
        } finally {
          await lease.release();
        }
      });
  @override
  Future<void> authorize(String path, String title) async =>
      (await _service()).authorizeRoot(path, title);
  @override
  Future<DocumentMigrationPlan> plan(String path) async =>
      (await _service()).plan(path);
  @override
  Future<bool> execute(
    DocumentMigrationPlan plan,
    MigrationConsent consent,
    MigrationCancellation cancellation,
    MigrationProgress progress,
  ) async => (await _service(
    progress: progress,
  )).execute(plan, consent, cancellation: cancellation);
  @override
  Future<List<MigrationRecoveryDetails>> details() async =>
      (await _service()).recoveryDetails();
  @override
  Future<List<MigrationRecovery>> recover() async =>
      (await _service()).recover();
}
