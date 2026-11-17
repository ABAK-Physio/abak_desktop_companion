/// Presentation only. The service checks the saved approval against the current
/// PDF and context before returning `approved` or `test_approved`.
class DocumentMedicalProgress {
  const DocumentMedicalProgress({
    required this.status,
    required this.dirty,
    required this.renderError,
    required this.pageCount,
    required this.reviewedPageCount,
  });

  final String? status;
  final bool dirty, renderError;
  final int? pageCount;
  final int reviewedPageCount;

  bool get validationRecorded =>
      !dirty && (status == 'approved' || status == 'test_approved');

  bool get activeReviewComplete =>
      !dirty &&
      !renderError &&
      pageCount != null &&
      pageCount! > 0 &&
      reviewedPageCount == pageCount;

  bool get reviewComplete => validationRecorded || activeReviewComplete;

  String get reviewSubtitle => validationRecorded
      ? 'Revue enregistrée avec la validation'
      : pageCount == null
      ? 'Revue à commencer'
      : '$reviewedPageCount / $pageCount page(s) examinée(s)';
}
