import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;

/// Normalized media types for new generic attachments. Not a clinical validation.
class DocumentMime {
  static const types = <String, String>{
    'pdf': 'application/pdf',
    'txt': 'text/plain',
    'csv': 'text/csv',
    'doc': 'application/msword',
    'docx':
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'odt': 'application/vnd.oasis.opendocument.text',
    'xls': 'application/vnd.ms-excel',
    'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'ods': 'application/vnd.oasis.opendocument.spreadsheet',
    'rtf': 'application/rtf',
    'png': 'image/png',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'gif': 'image/gif',
    'webp': 'image/webp',
    'heic': 'image/heic',
  };
  static Future<String> forFile(File file) async {
    final handle = await file.open();
    late List<int> head;
    try {
      head = await handle.read(8);
    } finally {
      await handle.close();
    }
    if (latin1.decode(head).startsWith('%PDF-')) return 'application/pdf';
    final ext = p.extension(file.path).replaceFirst('.', '').toLowerCase();
    // A .pdf suffix alone is not a PDF.
    if (ext == 'pdf') return 'application/octet-stream';
    return types[ext] ?? 'application/octet-stream';
  }

  static String extension(String? stored, String path) {
    final type = stored?.trim().toLowerCase() ?? '';
    for (final entry in types.entries) {
      if (entry.value == type) return entry.key;
    }
    if (type.isNotEmpty && !type.contains('/')) {
      return type.replaceFirst('.', '');
    }
    return p.extension(path).replaceFirst('.', '').toLowerCase();
  }
}
