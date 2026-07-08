class ImportSessionFile {
  final String sessionFileId;
  final String importSessionId;

  final String fileName;
  final String? filePath;
  final int? fileSize;
  final int processedAt;

  final int importedResultsCount;
  final int skippedResultsCount;
  final int importedMetricsCount;

  final String status;
  final String? errorMessage;
  final int conflictResultsCount;

  const ImportSessionFile({
    required this.sessionFileId,
    required this.importSessionId,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.processedAt,
    required this.importedResultsCount,
    required this.skippedResultsCount,
    required this.importedMetricsCount,
    required this.status,
    required this.errorMessage,
    required this.conflictResultsCount,
  });

  factory ImportSessionFile.fromMap(Map<String, dynamic> map) {
    return ImportSessionFile(
      sessionFileId: map['session_file_id'] as String,
      importSessionId: map['import_session_id'] as String,
      fileName: map['file_name'] as String,
      filePath: map['file_path'] as String?,
      fileSize: map['file_size'] as int?,
      processedAt: map['processed_at'] as int,
      importedResultsCount: map['imported_results_count'] as int,
      skippedResultsCount: map['skipped_results_count'] as int,
      importedMetricsCount: map['imported_metrics_count'] as int,
      status: map['status'] as String,
      errorMessage: map['error_message'] as String?,
      conflictResultsCount: map['conflict_results_count'] as int,
    );
  }
}