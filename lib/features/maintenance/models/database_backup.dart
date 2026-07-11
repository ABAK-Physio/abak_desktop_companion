class DatabaseBackup {
  final String backupId;

  final String fileName;
  final String filePath;

  final int createdAt;
  final int fileSize;

  final String status;
  final String? notes;

  const DatabaseBackup({
    required this.backupId,
    required this.fileName,
    required this.filePath,
    required this.createdAt,
    required this.fileSize,
    required this.status,
    required this.notes,
  });

  factory DatabaseBackup.fromMap(Map<String, dynamic> map) {
    return DatabaseBackup(
      backupId: map['backup_id'] as String,
      fileName: map['file_name'] as String,
      filePath: map['file_path'] as String,
      createdAt: map['created_at'] as int,
      fileSize: map['file_size'] as int,
      status: map['status'] as String,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'backup_id': backupId,
      'file_name': fileName,
      'file_path': filePath,
      'created_at': createdAt,
      'file_size': fileSize,
      'status': status,
      'notes': notes,
    };
  }
}
