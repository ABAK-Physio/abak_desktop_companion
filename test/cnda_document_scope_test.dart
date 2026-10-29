import 'dart:convert';
import 'dart:typed_data';
import 'package:xml/xml.dart';
import 'package:abak_desktop_companion/features/patients/services/document_cda_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/patients/services/cnda_patient_recipe.dart';

void main() {
  late Map<String, Object?> identity;
  late Map<String, Object?> recipe;
  Map<String, Object?> snapshot() => {
    'identity': CndaPatientRecipe.documentIdentity(identity, recipe),
    'cndaRecipe': recipe,
  };
  setUp(() {
    identity = {
      'identity_status': 'provisional',
      'identity_fictitious': 1,
      'identity_doubtful': 0,
      'birth_last_name': 'FICTIF',
      'birth_first_names': 'TEST',
      'birth_date': '1987-01-01',
      'sex_code': 'M',
      'birth_place_code': '24252', // Synthetic fixture, not CNDA evidence.
    };
    recipe = {
      'schema': 1,
      'scope': CndaPatientRecipe.scope,
      'testIns': '187012425258307',
      'source': 'Synthetic fixture for offline regression',
      'confirmedAt': '2026-10-27T10:00:00Z',
      'traitsHash': CndaPatientRecipe.fingerprint(identity),
    };
  });
  test(
    'projection preserves provisional status and leaves stored identity untouched',
    () {
      final original = Map.of(identity);
      final projected = snapshot();
      CndaPatientRecipe.checkDocument(projected);
      expect(identity, original);
      expect(identity.containsKey('ins_number'), false);
      expect((projected['identity'] as Map)['identity_status'], 'provisional');
      expect((projected['identity'] as Map)['ins_number'], '1870124252583');
    },
  );
  test(
    'explicit experimental birthplace stays out of patient traits and is DV1 only',
    () {
      identity['birth_place_code'] = '';
      recipe['traitsHash'] = CndaPatientRecipe.fingerprint(identity);
      recipe.addAll({
        'experimentalBirthPlace': '24252',
        'experimentalBirthPlaceReason': 'Synthetic value pending CNDA reply',
        'originalBirthPlace': '',
      });
      final data = snapshot();
      expect(identity['birth_place_code'], '');
      expect((data['identity'] as Map)['birth_place_code'], '24252');
      expect(data['cndaRecipe'], recipe);
      CndaPatientRecipe.checkDestination(data, CndaPatientRecipe.repository);
      expect(
        () => CndaPatientRecipe.checkDestination(
          data,
          'https://lps.dmp.gouv.fr/si-dmp-server/v2/services/repository',
        ),
        throwsStateError,
      );
      (data['identity'] as Map)['birth_place_code'] = '75056';
      expect(() => CndaPatientRecipe.checkDocument(data), throwsStateError);
      recipe['experimentalBirthPlaceReason'] = '';
      expect(snapshot, throwsStateError);
      recipe['experimentalBirthPlaceReason'] = 'Declared synthetic value';
      identity['birth_place_code'] = '75056';
      recipe['traitsHash'] = CndaPatientRecipe.fingerprint(identity);
      expect(snapshot, throwsStateError);
    },
  );
  test('legacy medical-only consent cannot enable CDA or deposit', () {
    recipe['scope'] = CndaPatientRecipe.reviewScope;
    CndaPatientRecipe.check(identity, recipe); // Review remains possible.
    expect(() => CndaPatientRecipe.checkDocument(snapshot()), throwsStateError);
  });
  test('only exact DV1 service is allowed for each action', () {
    final data = snapshot();
    CndaPatientRecipe.checkDestination(data, CndaPatientRecipe.repository);
    CndaPatientRecipe.checkDestination(
      data,
      CndaPatientRecipe.patients,
      accessOnly: true,
    );
    for (final endpoint in [
      'https://lps.dmp.gouv.fr/si-dmp-server/v2/services/repository',
      '${CndaPatientRecipe.repository}?redirect=production',
      CndaPatientRecipe.patients,
    ]) {
      expect(
        () => CndaPatientRecipe.checkDestination(data, endpoint),
        throwsStateError,
      );
    }
  });
  test('level 1 CDA embeds the selected bytes and declared test identity', () {
    final data = snapshot()
      ..addAll({
        'version': {
          'version_id': 'test-version',
          'document_id': 'test-document',
          'sequence_number': 1,
          'episode_id': 'test-episode',
        },
        'preparation': {
          'data_json': jsonEncode({
            'authorId': 'test-author',
            'validatorId': 'test-author',
            'patientVisibility': 'visible',
            'professionalVisibility': 'visible',
            'representativesVisibility': 'sans objet',
            'clinicalDate': '2026-10-27T10:00:00+01:00',
            'typeCode': 'TEST',
            'typeSystem': '1.2.3',
            'typeLabel': 'Synthetic test',
            'title': 'Offline fixture',
            'language': 'fr-FR',
          }),
        },
        'practice': {
          'data_json': jsonEncode({
            'setting': 'Ambulatoire',
            'familyName': 'FICTIF',
            'givenNames': 'TEST',
            'identifier': 'TEST',
            'authority': '1.2.3',
            'professionCode': 'G15_70',
            'professionSystem': '1.2.250.1.213.1.1.4.5',
            'professionLabel': 'Masseur-kinésithérapeute',
            'structureAuthority': '1.2.3',
            'structureId': 'TEST',
            'structureName': 'Test',
            'facilityCode': 'SA07',
            'facilityLabel': 'Cabinet',
          }),
        },
      });
    // Synthetic bytes: this test verifies encapsulation, not PDF/A conformity.
    final pdf = Uint8List.fromList(utf8.encode('%PDF synthetic fixture'));
    final xml = XmlDocument.parse(
      utf8.decode(
        DocumentCdaBuilder.build(
          data,
          pdf,
          DateTime.utc(2026, 10, 27, 10).millisecondsSinceEpoch,
        ),
      ),
    );
    expect(
      base64Decode(
        xml
            .findAllElements('nonXMLBody')
            .single
            .findElements('text')
            .single
            .innerText,
      ),
      pdf,
    );
    expect(
      xml
          .findAllElements('patientRole')
          .single
          .findElements('id')
          .single
          .getAttribute('extension'),
      recipe['testIns'],
    );
    expect(identity.containsKey('ins_number'), false);
  });
  test('changed traits invalidate the declaration', () {
    identity['birth_date'] = '1988-01-01';
    expect(snapshot, throwsStateError);
  });
  test('real or qualified identity cannot use the recipe exception', () {
    identity['identity_fictitious'] = 0;
    expect(snapshot, throwsStateError);
    identity['identity_fictitious'] = 1;
    identity['identity_status'] = 'qualified';
    expect(snapshot, throwsStateError);
  });
  test('missing birthplace and bad INS key block document preparation', () {
    identity['birth_place_code'] = '';
    recipe['traitsHash'] = CndaPatientRecipe.fingerprint(identity);
    expect(() => CndaPatientRecipe.checkDocument(snapshot()), throwsStateError);
    identity['birth_place_code'] = '24252';
    recipe['traitsHash'] = CndaPatientRecipe.fingerprint(identity);
    recipe['testIns'] = '187012425258308';
    expect(() => CndaPatientRecipe.checkDocument(snapshot()), throwsStateError);
  });
  test('changed projected INS cannot diverge from declared test patient', () {
    final data = snapshot();
    (data['identity'] as Map)['ins_number'] = '1870124252584';
    expect(() => CndaPatientRecipe.checkDocument(data), throwsStateError);
  });
}
