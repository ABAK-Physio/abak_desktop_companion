

import 'package:flutter_test/flutter_test.dart';

import 'package:abak_desktop_companion/features/cps/cps_profile.dart';
import 'package:abak_desktop_companion/features/dmp_dv1_access/tls050_cps_practice.dart';

const selected = CpsSituation(
  number: 1,
  mode: 0,
  status: 1,
  sector: 'SA07',
  structureId: '499700870597009',
);

CpsProfile profile({
  String professional = '899700870597',
  int profession = 70,
  List<CpsSituation> situations = const [selected],
}) => CpsProfile(
  nationalId: professional,
  familyName: 'TEST',
  givenName: 'RECETTE',
  professionCode: profession,
  cardType: 0,
  situations: situations,
);

String structure(CpsProfile p) => tls050CpsStructure(
  p,
  professional: '899700870597',
  situationNumber: 1,
  situationMode: 0,
  situationStatus: 1,
  situationSector: 'SA07',
);

void main() {
  test('uses the actual CPS structure without a DV1 structureId setting', () {
    expect(structure(profile()), '499700870597009');
    expect(
      structure(
        profile(
          situations: const [
            CpsSituation(
              number: 1,
              mode: 0,
              status: 1,
              sector: 'SA07',
              structureId: '123456789',
            ),
          ],
        ),
      ),
      '123456789',
    );
  });
  test('selects the configured situation, not the first one', () {
    expect(
      structure(
        profile(
          situations: const [
            CpsSituation(
              number: 2,
              mode: 0,
              status: 1,
              sector: 'SA07',
              structureId: '123',
            ),
            selected,
          ],
        ),
      ),
      '499700870597009',
    );
  });
  test('refuses a different professional', () {
    expect(
      () => structure(profile(professional: '899700000000')),
      throwsStateError,
    );
  });
  test('refuses a different profession', () {
    expect(() => structure(profile(profession: 10)), throwsStateError);
  });
  test('refuses a missing configured situation', () {
    expect(() => structure(profile(situations: const [])), throwsStateError);
  });
  test('refuses duplicate configured situations', () {
    expect(
      () => structure(profile(situations: const [selected, selected])),
      throwsStateError,
    );
  });
  for (final bad in <String, CpsSituation>{
    'mode': const CpsSituation(
      number: 1,
      mode: 4,
      status: 1,
      sector: 'SA07',
      structureId: '123',
    ),
    'status': const CpsSituation(
      number: 1,
      mode: 0,
      status: 2,
      sector: 'SA07',
      structureId: '123',
    ),
    'sector': const CpsSituation(
      number: 1,
      mode: 0,
      status: 1,
      sector: 'SA01',
      structureId: '123',
    ),
    'missing sector': const CpsSituation(
      number: 1,
      mode: 0,
      status: 1,
      structureId: '123',
    ),
    'missing structure': const CpsSituation(
      number: 1,
      mode: 0,
      status: 1,
      sector: 'SA07',
    ),
    'empty structure': const CpsSituation(
      number: 1,
      mode: 0,
      status: 1,
      sector: 'SA07',
      structureId: '',
    ),
    'invalid structure': const CpsSituation(
      number: 1,
      mode: 0,
      status: 1,
      sector: 'SA07',
      structureId: 'abc',
    ),
  }.entries) {
    test('refuses ${bad.key} before TLS', () {
      expect(
        () => structure(profile(situations: [bad.value])),
        throwsStateError,
      );
    });
  }
}
