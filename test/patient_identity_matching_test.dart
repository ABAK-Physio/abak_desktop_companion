import 'dart:io';

import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:abak_desktop_companion/features/patients/data/patient_repository.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _TestPathProvider extends PathProviderPlatform {
  _TestPathProvider(this.directory);
  final String directory;

  @override
  Future<String?> getApplicationSupportPath() async => directory;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory temporaryDirectory;
  late PathProviderPlatform previousProvider;
  final repository = PatientRepository();

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'abak_identity_test_',
    );
    previousProvider = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _TestPathProvider(
      '${temporaryDirectory.path}/support',
    );
  });

  tearDown(() async {
    await DatabaseService.closeDatabase();
    PathProviderPlatform.instance = previousProvider;
    await temporaryDirectory.delete(recursive: true);
  });

  test(
    'Vitale spacing matches a manually entered compound first name',
    () async {
      final patient = await repository.createPatient(
        lastName: 'Exemple',
        firstName: 'Jean-Claude',
        birthDate: '1980-01-02',
        sexCode: 'M',
      );
      final matches = await repository.findPatientsByIdentity(
        lastName: ' EXEMPLE ',
        firstName: 'JEAN   CLAUDE',
        birthDate: '1980-01-02',
      );
      expect(matches.map((p) => p.patientId), [patient.patientId]);
      expect(matches.single.firstName, 'Jean-Claude');
      expect(matches.single.nir, isNull);
    },
  );

  test('distinct names and birth dates remain distinct', () async {
    await repository.createPatient(
      lastName: 'Exemple',
      firstName: 'Jean',
      birthDate: '1980-01-02',
    );
    await repository.createPatient(
      lastName: 'Autre',
      firstName: 'Jean-Claude',
      birthDate: '1980-01-02',
    );
    await repository.createPatient(
      lastName: 'Exemple',
      firstName: 'Jean-Claude',
      birthDate: '1980-01-03',
    );
    final matches = await repository.findPatientsByIdentity(
      lastName: 'EXEMPLE',
      firstName: 'JEAN CLAUDE',
      birthDate: '1980-01-02',
    );
    expect(matches, isEmpty);
  });

  test('archived identities also match typographic hyphens', () async {
    final patient = await repository.createPatient(
      lastName: 'Exemple',
      firstName: 'Jean‑Claude',
      birthDate: '1980-01-02',
    );
    final db = await DatabaseService.database;
    await db.update(
      'patients',
      {'archived_at': 1},
      where: 'patient_id = ?',
      whereArgs: [patient.patientId],
    );
    final matches = await repository.findArchivedPatientsByIdentity(
      lastName: 'EXEMPLE',
      firstName: 'JEAN CLAUDE',
      birthDate: '1980-01-02',
    );
    expect(matches.map((p) => p.patientId), [patient.patientId]);
    expect(
      await repository.findPatientsByIdentity(
        lastName: 'EXEMPLE',
        firstName: 'JEAN CLAUDE',
        birthDate: '1980-01-02',
      ),
      isEmpty,
    );
  });
}
