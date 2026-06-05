class RestoreResult {
  final bool success;
  final String message;
  final String? sourceBackupPath;
  final String? safetyBackupPath;

  const RestoreResult({
    required this.success,
    required this.message,
    this.sourceBackupPath,
    this.safetyBackupPath,
  });
}