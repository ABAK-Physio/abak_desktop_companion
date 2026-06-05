class SystemHealthSnapshot {
  final int databaseSizeBytes;
  final int backupsCount;
  final int backupsTotalSizeBytes;
  final int activePatientsCount;
  final int archivedPatientsCount;
  final int importsCount;
  final int failedImportsCount;
  final int runningImportsCount;
  final int? lastBackupAt;
  final int? lastRestoreAt;

  const SystemHealthSnapshot({
    required this.databaseSizeBytes,
    required this.backupsCount,
    required this.backupsTotalSizeBytes,
    required this.activePatientsCount,
    required this.archivedPatientsCount,
    required this.importsCount,
    required this.failedImportsCount,
    required this.runningImportsCount,
    required this.lastBackupAt,
    required this.lastRestoreAt,
  });

  bool get hasNoBackup => lastBackupAt == null;

  bool get hasOldBackup {
    if (lastBackupAt == null) return true;

    final lastBackupDate = DateTime.fromMillisecondsSinceEpoch(lastBackupAt!);
    final age = DateTime.now().difference(lastBackupDate);

    return age.inDays > 7;
  }

  bool get hasFailedImports => failedImportsCount > 0;

  bool get hasRunningImports => runningImportsCount > 0;
}