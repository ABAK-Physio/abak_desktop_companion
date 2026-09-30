class RestoreResult {
  final bool success;
  final String message;
  final String? sourceBackupPath;
  final String? safetyBackupPath;
  final List<String> documentSafetyPaths;

  const RestoreResult({
    required this.success,
    required this.message,
    this.sourceBackupPath,
    this.safetyBackupPath,
    this.documentSafetyPaths = const [],
  });
}
