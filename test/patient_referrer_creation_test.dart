import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:abak_desktop_companion/features/patients/data/patient_repository.dart';
import 'package:abak_desktop_companion/features/companion_access/companion_access_service.dart';
import 'package:abak_desktop_companion/features/companion_access/patient_referrer_picker.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'support/companion_access_test_support.dart';

class _Paths extends PathProviderPlatform {
  _Paths(this.path);
  final String path;
  @override
  Future<String?> getApplicationSupportPath() async => path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory temp;
  late PathProviderPlatform previous;
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('patient_referrer_creation_');
    previous = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _Paths(temp.path);
  });
  tearDown(() async {
    await DatabaseService.closeDatabase();
    PathProviderPlatform.instance = previous;
    await temp.delete(recursive: true);
  });
  test(
    'creation requires an active referrer and rolls back patient on invalid selection',
    () async {
      final db = await DatabaseService.database;
      for (final id in [null, 'unknown']) {
        await expectLater(
          PatientRepository().createPatient(
            referringPractitionerId: id,
            lastName: 'Test',
            firstName: 'Patient',
          ),
          throwsA(isA<CompanionAccessException>()),
        );
        expect(await db.query('patients'), isEmpty);
      }
      final referrer = await seedPatientReferrer();
      await db.update(
        'practitioners',
        {'archived_at': 2},
        where: 'practitioner_id = ?',
        whereArgs: [referrer],
      );
      await expectLater(
        PatientRepository().createPatient(
          referringPractitionerId: referrer,
          lastName: 'Test',
          firstName: 'Patient',
        ),
        throwsA(isA<CompanionAccessException>()),
      );
      expect(await db.query('patients'), isEmpty);
      expect(await db.query('companion_patient_access'), isEmpty);
    },
  );
  test(
    'creation stores the chosen patient referrer in the same transaction',
    () async {
      final id = await seedPatientReferrer();
      final patient = await PatientRepository().createPatient(
        referringPractitionerId: id,
        lastName: 'Test',
        firstName: 'Patient',
      );
      final db = await DatabaseService.database;
      final assignment = (await db.query('companion_patient_access')).single;
      expect(assignment['patient_id'], patient.patientId);
      expect(assignment['referring_practitioner_id'], id);
    },
  );
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 15; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump(const Duration(milliseconds: 30));
    }
  }

  for (final multiple in [false, true]) {
    testWidgets(
      multiple
          ? 'several practitioners require a choice'
          : 'single practitioner is proposed',
      (tester) async {
        await tester.runAsync(() async {
          await seedPatientReferrer();
          if (multiple) {
            await (await DatabaseService.database).insert('practitioners', {
              'practitioner_id': 'other',
              'display_name': 'Autre kiné',
              'created_at': 2,
            });
          }
        });
        String? selected;
        final key = GlobalKey<FormState>();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: key,
                child: PatientReferrerPicker(onChanged: (id) => selected = id),
              ),
            ),
          ),
        );
        await settle(tester);
        expect(key.currentState!.validate(), !multiple);
        expect(selected, multiple ? isNull : 'test-referrer');
        if (multiple) {
          await tester.tap(find.byType(DropdownButtonFormField<String>));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Autre kiné').last);
          await tester.pumpAndSettle();
          expect(selected, 'other');
          expect(key.currentState!.validate(), isTrue);
        }
        expect(find.text('Créer un kiné'), findsOneWidget);
      },
    );
  }
}
