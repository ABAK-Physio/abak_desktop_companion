import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_dv1_access/nia_injection.dart';
import 'package:abak_desktop_companion/features/dmp_td02/access_identity.dart';

String recordHash(Object? value) {
  Object? sort(Object? v) {
    if (v is Map) {
      final keys = v.keys.cast<String>().toList()..sort();
      return {for (final k in keys) k: sort(v[k])};
    }
    if (v is List) return v.map(sort).toList();
    return v;
  }

  return sha256.convert(utf8.encode(jsonEncode(sort(value)))).toString();
}

void main() {
  final bytes = File('test/fixtures/dv1_nia/TEST_NIA.xml').readAsBytesSync();
  Map<String, dynamic> snapshot(Dv1NiaInjection i) => {
    'identity': {...i.identity},
    'recipe': {
      'scenario': '0.2-080',
      'patient': i.patient,
      'birthDate': i.result.birthDate,
    },
  };
  late Directory root;
  late Dv1NiaArchive archive;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('abak_nia_test_');
    archive = Dv1NiaArchive(root, hash: recordHash);
  });
  tearDown(() async => root.delete(recursive: true));
  test(
    'actual CNDA SOAP is processed by the INSi parser and preserves NIA traits',
    () {
      final i = Dv1NiaInjection.decode(bytes);
      expect(i.ins, '109076322088835');
      expect(i.result.insOid, DmpAccessIdentity.niaOid);
      expect(i.patient, 'PROVISOIRE MATRICULE');
      expect(i.result.birthDate, '2009-07-01');
      expect(i.result.sexCode, 'M');
      expect(i.result.birthPlaceCode, '63220');
      expect(i.identity['identifierType'], 'NIA');
    },
  );
  test('altered, unrelated and oversized XML are rejected before import', () {
    for (final value in [
      utf8.encode('<invalid/>'),
      [...bytes, 32],
      List<int>.filled(65537, 0),
      utf8.encode(
        utf8
            .decode(bytes)
            .replaceAll(DmpAccessIdentity.niaOid, DmpAccessIdentity.nirOid),
      ),
    ]) {
      expect(() => Dv1NiaInjection.decode(value), throwsStateError);
    }
  });
  test('type NIA and original XML survive a fresh archive instance', () async {
    final e = await archive.importResponse(bytes);
    final fresh = Dv1NiaArchive(root, hash: recordHash);
    final r = await fresh.verify(e);
    expect(r['state'], 'nia_imported');
    expect(r['injectedIdentity']['ins_oid'], DmpAccessIdentity.niaOid);
    expect(await fresh.file(e.id, 'insi-injected.xml').readAsBytes(), bytes);
    expect(r['cardAccessed'], isFalse);
    expect(r['networkAccessed'], isFalse);
    expect(r['nativeSessionOpened'], isFalse);
  });
  test('real shared guard refuses NIA and unknown authority, accepts NIR authority', () {
    expect(
      () => DmpAccessIdentity.requireNirOid(DmpAccessIdentity.niaOid),
      throwsA(isA<DmpNiaBlocked>()),
    );
    for (final oid in [null, '', 'unknown', '${DmpAccessIdentity.niaOid} ']) {
      expect(() => DmpAccessIdentity.requireNirOid(oid), throwsStateError);
    }
    DmpAccessIdentity.requireNirOid(DmpAccessIdentity.nirOid);
  });
  test(
    'access refusal is persisted without inventing an HTTP or native session',
    () async {
      final e = await archive.importResponse(bytes);
      final r = await archive.blockAccess(e, snapshot(e.injection));
      expect(r['state'], 'nia_blocked');
      expect(r['testExpectedMatched'], isTrue);
      expect(r['context']['identity']['ins_oid'], DmpAccessIdentity.niaOid);
      for (final key in [
        'cardAccessed',
        'networkAccessed',
        'nativeSessionOpened',
      ]) {
        expect(r[key], isFalse);
      }
      expect(r.containsKey('httpStatus'), isFalse);
      expect(r.containsKey('session'), isFalse);
      expect((await archive.verify(e))['state'], 'nia_blocked');
    },
  );
  test(
    'manually relabelling NIA as NIR cannot produce a successful proof',
    () async {
      final e = await archive.importResponse(bytes);
      final data = snapshot(e.injection);
      data['identity']['ins_oid'] = DmpAccessIdentity.nirOid;
      await expectLater(archive.blockAccess(e, data), throwsStateError);
      expect((await archive.verify(e))['state'], 'nia_imported');
    },
  );
  test(
    'another patient, birth, identifier or test cannot reuse the injection',
    () async {
      final e = await archive.importResponse(bytes);
      for (final pair in [
        ['patient', 'HUIT HENRI'],
        ['birthDate', '1989-01-01'],
        ['scenario', '0.2-070'],
      ]) {
        final data = snapshot(e.injection);
        data['recipe'][pair[0]] = pair[1];
        await expectLater(archive.blockAccess(e, data), throwsStateError);
      }
      final data = snapshot(e.injection);
      data['identity']['ins_number'] = '1890181570576';
      await expectLater(archive.blockAccess(e, data), throwsStateError);
    },
  );
  test('tampered archived XML cannot be used for the refusal proof', () async {
    final e = await archive.importResponse(bytes);
    await archive.file(e.id, 'insi-injected.xml').writeAsString('<invalid/>');
    await expectLater(archive.verify(e), throwsStateError);
  });
  test('tampered evidence summary and path traversal are rejected', () async {
    final e = await archive.importResponse(bytes);
    final file = archive.file(e.id, 'result.json');
    final value = jsonDecode(await file.readAsString());
    value['record']['state'] = 'forged';
    await file.writeAsString(jsonEncode(value));
    await expectLater(archive.verify(e), throwsStateError);
    expect(() => archive.directory('../elsewhere'), throwsStateError);
  });
}
