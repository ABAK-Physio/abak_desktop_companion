import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:abak_desktop_companion/features/companion_access/personal_code_hasher.dart';

/// Only workflow tests use this fast verifier. Production uses PBKDF2 in an
/// isolate; the real implementation has its own test below.
class FastTestCodeHasher implements PersonalCodeHasher {
  String digest(String code) =>
      base64Encode(sha256.convert(utf8.encode('test:$code')).bytes);
  @override
  Future<PersonalCodeVerifier> create(String code) async =>
      PersonalCodeVerifier(
        algorithm: 'test-only',
        iterations: 1,
        salt: 'test-only',
        verifier: digest(code),
      );
  @override
  Future<bool> verify(String code, PersonalCodeVerifier stored) async =>
      stored.verifier == digest(code);
}

Future<Database> openAccessTestDatabase(String path) async {
  final db = await DatabaseService.openDatabaseFile(
    path,
    factory: databaseFactoryFfi,
  );
  for (final id in ['a', 'b', 'c']) {
    await db.insert('practitioners', {
      'practitioner_id': id,
      'display_name': 'Kiné ${id.toUpperCase()}',
      'created_at': 1,
    });
  }
  return db;
}

Future<String> seedPatientReferrer([Database? database]) async {
  final db = database ?? await DatabaseService.database;
  await db.insert('practitioners', {
    'practitioner_id': 'test-referrer', 'display_name': 'Kiné de test', 'created_at': 1,
  }, conflictAlgorithm: ConflictAlgorithm.ignore);
  return 'test-referrer';
}
