class BackupCleanupResult {
  final int scannedCount;
  final int deletedCount;
  final int keptCount;
  final List<String> deletedPaths;

  const BackupCleanupResult({
    required this.scannedCount,
    required this.deletedCount,
    required this.keptCount,
    required this.deletedPaths,
  });
}
