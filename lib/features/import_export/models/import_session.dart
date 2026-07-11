class ImportSession {
  final String importSessionId;
  final int startedAt;
  final int? completedAt;

  final int processedFilesCount;
  final int failedFilesCount;

  final int importedResultsCount;
  final int skippedResultsCount;
  final int duplicateResultsCount;
  final int importedMetricsCount;

  final String? sourceLabel;
  final String? notes;
  final String status;
  final int conflictResultsCount;

  final String? summaryPatientLabel;
  final String? summaryEpisodeLabel;
  final String? summaryExercisesLabel;

  const ImportSession({
    required this.importSessionId,
    required this.startedAt,
    required this.completedAt,
    required this.processedFilesCount,
    required this.failedFilesCount,
    required this.importedResultsCount,
    required this.skippedResultsCount,
    required this.duplicateResultsCount,
    required this.importedMetricsCount,
    required this.sourceLabel,
    required this.notes,
    required this.status,
    required this.conflictResultsCount,
    required this.summaryPatientLabel,
    required this.summaryEpisodeLabel,
    required this.summaryExercisesLabel,
  });

  factory ImportSession.fromMap(Map<String, dynamic> map) {
    return ImportSession(
      importSessionId: map['import_session_id'] as String,
      startedAt: map['started_at'] as int,
      completedAt: map['completed_at'] as int?,
      processedFilesCount:
      (map['processed_files_count'] as num?)?.toInt() ?? 0,
      failedFilesCount:
      (map['failed_files_count'] as num?)?.toInt() ?? 0,
      importedResultsCount:
      (map['imported_results_count'] as num?)?.toInt() ?? 0,
      skippedResultsCount:
      (map['skipped_results_count'] as num?)?.toInt() ?? 0,
      duplicateResultsCount:
      (map['duplicate_results_count'] as num?)?.toInt() ?? 0,
      importedMetricsCount:
      (map['imported_metrics_count'] as num?)?.toInt() ?? 0,
      sourceLabel: map['source_label'] as String?,
      notes: map['notes'] as String?,
      status: map['status'] as String,
      conflictResultsCount:
      (map['conflict_results_count'] as num?)?.toInt() ?? 0,
      summaryPatientLabel: map['summary_patient_label'] as String?,
      summaryEpisodeLabel: map['summary_episode_label'] as String?,
      summaryExercisesLabel: map['summary_exercises_label'] as String?,
    );
  }
}