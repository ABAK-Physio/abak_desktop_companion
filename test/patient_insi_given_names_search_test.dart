import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_insi_given_names_search.dart';

void main() {
  test('one compound given name remains one attempt', () {
    expect(PatientInsiGivenNamesSearch.plan([' Jean Claude ']), ['Jean Claude']);
    expect(PatientInsiGivenNamesSearch.plan(['JEAN-CLAUDE', 'PAUL']),
      ['JEAN-CLAUDE', 'PAUL', 'JEAN-CLAUDE PAUL']);
  });

  test('stops immediately on a unique result from the second attempt', () async {
    final sent = <String>[];
    final result = await PatientInsiGivenNamesSearch.run<String>(
      firstNames: ['JOSEPH', 'DOUME', 'PIERRE'],
      attempt: (name) async {
        sent.add(name);
        return sent.length == 2 ? '00' : '01';
      },
      isSuccess: (result) => result == '00',
    );
    expect(sent, ['JOSEPH', 'DOUME']);
    expect(result, '00');
  });

  test('tries each name and then all names once, after CR01 or CR02', () async {
    final sent = <String>[];
    final result = await PatientInsiGivenNamesSearch.run<String>(
      firstNames: ['PIERRE', 'PAUL', 'JACQUES'],
      attempt: (name) async {
        sent.add(name);
        return sent.length == 1 ? '02' : '01';
      },
      isSuccess: (result) => result == '00',
    );
    expect(sent, ['PIERRE', 'PAUL', 'JACQUES', 'PIERRE PAUL JACQUES']);
    expect(result, '01');
  });

  test('technical failure aborts without trying the next name', () async {
    final sent = <String>[];
    await expectLater(PatientInsiGivenNamesSearch.run<String>(
      firstNames: ['PIERRE', 'PAUL'],
      attempt: (name) async {
        sent.add(name);
        throw StateError('SOAP fault or evidence archive failure');
      },
      isSuccess: (result) => result == '00',
    ), throwsStateError);
    expect(sent, ['PIERRE']);
  });

  test('empty or blank names are refused before any attempt', () async {
    for (final names in [<String>[], ['PIERRE', '  ']]) {
      var calls = 0;
      await expectLater(PatientInsiGivenNamesSearch.run<String>(
        firstNames: names,
        attempt: (_) async { calls++; return '00'; },
        isSuccess: (result) => result == '00',
      ), throwsArgumentError);
      expect(calls, 0);
    }
  });
}
