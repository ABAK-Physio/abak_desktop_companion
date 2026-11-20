import 'dart:io';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_insi_cr01_injection.dart';

void main() {
  final fixture = File('test/fixtures/insi_rep_cr01.b64');
  Future<List<int>> originalBytes() async =>
      base64Decode((await fixture.readAsString()).trim());

  test('official CNDA SOAP uses the normal parser and returns no identity', () async {
    final injection = PatientInsiCr01Injection.decode(await originalBytes());
    expect(injection.result.isNotFound, isTrue);
    expect(injection.result.insNumber, isNull);
    expect(injection.result.birthLastName, isNull);
    expect(injection.xml, utf8.decode(await originalBytes()));
  });

  test('refuses a modified official response', () async {
    final bytes = await originalBytes();
    bytes[bytes.length - 1] ^= 1;
    expect(() => PatientInsiCr01Injection.decode(bytes), throwsStateError);
  });

  test('refuses arbitrary or oversized XML before parsing', () {
    expect(() => PatientInsiCr01Injection.decode('<RESULTAT/>'.codeUnits), throwsStateError);
    expect(() => PatientInsiCr01Injection.decode(List.filled(65537, 0)), throwsStateError);
  });
}
