class EpisodeDocumentVersion {
  const EpisodeDocumentVersion(this.values);
  final Map<String, Object?> values;
  String get id => values['version_id'] as String;
  String get documentId => values['document_id'] as String;
  String get relativePath => values['relative_path'] as String;
  String get digest => values['sha256'] as String;
  int get number => values['sequence_number'] as int;
  int get size => values['byte_size'] as int;
  int get pages => values['page_count'] as int;
  String get sourceKind => values['source_kind'] as String;
}
