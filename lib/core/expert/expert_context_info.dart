class ExpertContextInfo {
  final String contextName;
  final String sourceFile;
  final String? arbPrefix;
  final String? comment;

  const ExpertContextInfo({
    required this.contextName,
    required this.sourceFile,
    this.arbPrefix,
    this.comment,
  });
}