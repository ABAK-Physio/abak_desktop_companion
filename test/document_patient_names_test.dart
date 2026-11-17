import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/patients/services/document_patient_names.dart';

void main() {
  Map<String, Object?> ruth() => {
    'birth_last_name': 'NESSI',
    'birth_first_names': 'RUTH ISABELLE',
    'first_birth_name': 'RUTH',
    'used_last_name': 'DE VINCI',
    'used_first_name': 'RUTH',
  };

  test('RNIV preserves all names and maps XPN components 1, 2, 3, 7', () {
    final identity = ruth(), original = Map.of(ruth());
    final names = DocumentPatientNames.fromIdentity(identity);
    expect(names.birthGiven, 'RUTH ISABELLE');
    expect(names.firstBirth, 'RUTH');
    expect(names.pid5, [
      'PID-5|NESSI^RUTH^RUTH ISABELLE^^^^L',
      'PID-5|DE VINCI^RUTH^^^^^D',
    ]);
    expect(identity, original);
  });

  test('an explicit compound first name is not split or truncated', () {
    final identity = ruth()
      ..['birth_first_names'] = 'ANNE MARIE LOUISE'
      ..['first_birth_name'] = 'ANNE MARIE';
    expect(
      DocumentPatientNames.fromIdentity(identity).firstBirth,
      'ANNE MARIE',
    );
  });

  test(
    'a missing first name in a multiple-name list blocks instead of guessing',
    () {
      final identity = ruth()..remove('first_birth_name');
      expect(
        () => DocumentPatientNames.fromIdentity(identity),
        throwsStateError,
      );
    },
  );

  test('the existing unambiguous single-name path remains available', () {
    final identity = {
      'birth_last_name': 'FICTIF',
      'birth_first_names': 'ANNE-LOUIS',
    };
    final names = DocumentPatientNames.fromIdentity(identity);
    expect(names.firstBirth, 'ANNE-LOUIS');
    expect(names.pid5, ['PID-5|FICTIF^ANNE-LOUIS^ANNE-LOUIS^^^^L']);
    expect(names.usedFamily, isNull);
    expect(names.usedGiven, isNull);
  });

  test('a first name must match a complete prefix, not a substring', () {
    for (final first in ['ISABELLE', 'RU', 'RUTH-ISABELLE']) {
      final identity = ruth()..['first_birth_name'] = first;
      expect(
        () => DocumentPatientNames.fromIdentity(identity),
        throwsStateError,
      );
    }
  });

  test(
    'comparison tolerates spacing and case without rewriting the source',
    () {
      final identity = ruth()
        ..['birth_first_names'] = 'Ruth  Isabelle'
        ..['first_birth_name'] = 'RUTH';
      expect(
        DocumentPatientNames.fromIdentity(identity).birthGiven,
        'Ruth  Isabelle',
      );
    },
  );

  test('an optional used name is never substituted with a birth trait', () {
    final identity = ruth()..['used_first_name'] = '';
    expect(
      DocumentPatientNames.fromIdentity(identity).pid5.last,
      'PID-5|DE VINCI^^^^^^D',
    );
  });

  test(
    'HL7 separators in every name component are rejected before assembly',
    () {
      for (final key in ruth().keys) {
        for (final separator in ['^', '~', '|', '&', r'\']) {
          final identity = ruth()..[key] = 'RUTH${separator}INJECTION';
          expect(
            () => DocumentPatientNames.fromIdentity(identity).pid5,
            throwsStateError,
            reason: '$key / $separator',
          );
        }
      }
    },
  );

  test('controls, missing mandatory traits and non-text values block', () {
    for (final key in ruth().keys) {
      final identity = ruth()..[key] = 'RUTH\nINJECTION';
      expect(
        () => DocumentPatientNames.fromIdentity(identity),
        throwsStateError,
      );
    }
    for (final key in ['birth_last_name', 'birth_first_names']) {
      for (final value in [null, '', 42]) {
        final identity = ruth()..[key] = value;
        expect(
          () => DocumentPatientNames.fromIdentity(identity),
          throwsStateError,
        );
      }
    }
  });
}
