class PendingImportViewModel {
  final String fileName;
  final String filePath;
  final int? fileSize;

  final String pathologyLabel;
  final String patientLabel;

  final DateTime? examinationDate;

  final List<String> exerciseLabels;
  final int resultsCount;

  const PendingImportViewModel({
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.pathologyLabel,
    required this.patientLabel,
    required this.examinationDate,
    required this.exerciseLabels,
    required this.resultsCount,
  });

  String get displayPathology {
    return pathologyLabel.trim().isEmpty
        ? 'Pathologie non renseignée'
        : pathologyLabel.trim();
  }

  String get displayPatient {
    return patientLabel.trim().isEmpty
        ? 'Patient ABAK non renseigné'
        : patientLabel.trim();
  }

  String get resultsSummary {
    if (resultsCount <= 0) {
      return 'Aucun résultat';
    }

    if (resultsCount == 1) {
      return '1 résultat';
    }

    return '$resultsCount résultats';
  }

  List<String> get visibleExerciseLabels {
    return exerciseLabels.take(3).toList();
  }

  int get hiddenExerciseCount {
    final hidden = exerciseLabels.length - visibleExerciseLabels.length;
    return hidden < 0 ? 0 : hidden;
  }
}
