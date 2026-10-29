import 'dart:async';
import 'package:abak_desktop_companion/features/dmp_resources/nos_import.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_resources/dmp_resources.dart';

String fixture(String name) =>
    File('test/fixtures/dmp_resources/$name').readAsStringSync();

class FakeTransport implements ResourceTransport {
  final replies = <FutureOr<ResourceReply> Function()>[];
  final calls = <Uri>[];
  @override
  Future<ResourceReply> get(Uri uri, String? etag) async {
    calls.add(uri);
    return await replies.removeAt(0)();
  }

  void reply(int status, {String body = '', String? location, String? etag}) =>
      replies.add(
        () => ResourceReply(status, body: body, location: location, etag: etag),
      );
}

class FaultStore implements ResourceStore {
  FaultStore(this.inner);
  final ResourceStore inner;
  bool fail = false;
  @override
  String? read() => inner.read();
  @override
  void commit(String s) {
    if (fail) throw FileSystemException('Interruption simulée');
    inner.commit(s);
  }
}

void main() {
  late Directory dir;
  late FaultStore store;
  late FakeTransport transport;
  late DateTime time;
  late DmpResources service;
  DmpResources construct() => DmpResources(
    transport: transport,
    store: store,
    now: () => time,
    source: Uri.parse('https://parametres.example.invalid/a'),
    allowedHosts: {'parametres.example.invalid', 'nouveau.example.invalid'},
  );
  Future<void> seed() async {
    transport.reply(200, body: fixture('parametres-valides.xml'), etag: 'v1');
    await service.refresh();
    expect(service.parameters, isNotNull);
  }

  bool install(String name) {
    final body = fixture(name);
    return service.installCatalog(
      body,
      ticket: service.beginCatalogUpdate(),
      expectedHash: DmpResources.digest(body),
      provenance: 'fixture:$name',
    );
  }

  setUp(() {
    dir = Directory.systemTemp.createTempSync('abak-dmp-resources-test-');
    store = FaultStore(FileResourceStore(dir));
    transport = FakeTransport();
    time = DateTime.utc(2026, 10, 9, 10);
    service = construct();
  });
  tearDown(() => dir.deleteSync(recursive: true));
  test('P01 premier chargement et provenance', () async {
    await seed();
    expect(service.parameters!.majority, 18);
    expect(service.lastSuccess, time);
    expect(service.message, contains('actualisés'));
    final cache = jsonDecode(store.read()!);
    expect(cache['parameters']['source'], service.source.toString());
  });
  test('P02 échéance exacte et échec sans report', () async {
    await seed();
    time = time
        .add(const Duration(days: 7))
        .subtract(const Duration(seconds: 1));
    await service.refreshIfDue();
    expect(transport.calls.length, 1);
    time = time.add(const Duration(seconds: 1));
    expect(service.due, true);
    final before = service.lastSuccess;
    transport.reply(503);
    await service.refreshIfDue();
    expect(service.lastSuccess, before);
    expect(service.due, true);
  });
  test('P03 reprise après arrêt prolongé', () async {
    await seed();
    time = time.add(const Duration(days: 8));
    service = construct();
    expect(service.due, true);
    transport.reply(200, body: fixture('parametres-modifies.xml'));
    await service.refreshIfDue();
    expect(service.lastSuccess, time);
    expect(service.parameters!.majority, 21);
  });
  for (final code in [301, 302, 303, 307, 308]) {
    test('P04-$code redirection HTTPS', () async {
      transport.reply(code, location: '/b');
      transport.reply(200, body: fixture('parametres-valides.xml'));
      await service.refresh();
      expect(service.parameters, isNotNull);
      expect(transport.calls.last.path, '/b');
      expect(
        jsonDecode(store.read()!)['parameters']['finalUrl'],
        endsWith('/b'),
      );
    });
  }
  test('P05 changement URL éditeur', () async {
    service.source = Uri.parse('https://nouveau.example.invalid/params');
    await seed();
    expect(transport.calls.single.host, 'nouveau.example.invalid');
  });
  test('P06 boucle et baisse de sécurité', () async {
    await seed();
    final before = store.read();
    transport.reply(302, location: '/a');
    await service.refresh();
    expect(store.read(), before);
    expect(service.parametersDiagnostic, contains('répétée'));
    transport.reply(302, location: 'http://insecure.example.invalid/');
    await service.refresh();
    expect(store.read(), before);
    expect(transport.calls.every((u) => u.scheme == 'https'), true);
  });
  test('P07 erreurs et absence de cache', () async {
    for (final error in [
      TimeoutException('Délai dépassé'),
      StateError('HTTP 503'),
      HandshakeException('Certificat refusé'),
    ]) {
      transport.replies.add(() => throw error);
      await service.refresh();
      expect(service.hasUsableParameters, false);
      expect(service.message, contains('indisponibles'));
    }
    await seed();
    final before = store.read();
    transport.replies.add(() => throw TimeoutException('Délai dépassé'));
    await service.refresh();
    expect(store.read(), before);
    expect(service.message, contains('conservée'));
  });
  for (final name in [
    'boolean-invalide',
    'age-invalide',
    'manquants',
    'doublon',
    'tronques',
    'html',
    'dtd',
  ]) {
    test('P08-$name rejet sans écrasement', () async {
      await seed();
      final before = store.read();
      transport.reply(200, body: fixture('parametres-$name.xml'));
      await service.refresh();
      expect(store.read(), before);
      expect(service.message, contains('échec'));
    });
  }
  test('P09 paramètre inconnu', () async {
    transport.reply(200, body: fixture('parametres-inconnus.xml'));
    await service.refresh();
    expect(service.parameters!.unknown, ['future-option-synthetique']);
    expect(service.parameters!.majority, 18);
    expect(service.message, contains('inconnu'));
  });
  test('P10 consommateurs âge et visibilité', () async {
    await seed();
    final birth = DateTime(2008, 10, 16);
    expect(service.parameters!.isMinor(birth, DateTime(2026, 10, 15)), true);
    expect(service.parameters!.isMinor(birth, DateTime(2026, 10, 16)), false);
    expect(
      service.parameters!.visibilityAllowed(invisible: true, masked: true),
      false,
    );
    transport.reply(200, body: fixture('parametres-modifies.xml'));
    await service.refresh();
    expect(service.parameters!.minors, false);
    expect(service.parameters!.isMinor(birth, DateTime(2026, 10, 15)), false);
    expect(
      service.parameters!.visibilityAllowed(invisible: true, masked: true),
      true,
    );
    final enabled = fixture('parametres-modifies.xml').replaceFirst(
      'code="fonctions-gestion-mineurs" value="false"',
      'code="fonctions-gestion-mineurs" value="true"',
    );
    transport.reply(200, body: enabled);
    await service.refresh();
    expect(service.parameters!.isMinor(birth, DateTime(2026, 10, 16)), true);
  });
  test('P11 interruption et persistance', () async {
    await seed();
    final before = store.read();
    store.fail = true;
    transport.reply(200, body: fixture('parametres-modifies.xml'));
    await service.refresh();
    expect(store.read(), before);
    expect(service.parameters!.majority, 18);
    store.fail = false;
    File('${dir.path}/dmp-resources.json.pending').writeAsStringSync('partiel');
    service = construct();
    expect(service.parameters!.majority, 18);
    transport.reply(200, body: fixture('parametres-modifies.xml'));
    await service.refresh();
    service = construct();
    expect(service.parameters!.majority, 21);
  });
  test('P12 304 seulement avec cache correspondant', () async {
    transport.reply(304);
    await service.refresh();
    expect(service.parameters, isNull);
    await seed();
    time = time.add(const Duration(days: 7));
    transport.reply(304);
    await service.refresh();
    expect(service.lastSuccess, time);
    expect(service.parameters!.majority, 18);
    expect(service.message, contains('inchangés'));
  });
  test('N01 évolution de codes et libellés', () {
    expect(install('jdv-v1.json'), true);
    final old = service.catalog!;
    expect(install('jdv-v2.json'), true);
    expect(service.catalog!.canEmit('urn:abak:test:system', 'TEST_B'), true);
    expect(
      service.catalog!.display('urn:abak:test:system', 'TEST_A'),
      'Libellé modifié',
    );
    expect(old.display('urn:abak:test:system', 'TEST_A'), 'Libellé initial');
  });
  test('N02 candidat incohérent refusé', () {
    install('jdv-v1.json');
    final before = store.read();
    expect(install('jdv-doublon.json'), false);
    for (final b in ['{', '{"version":"X","entries":[]}']) {
      expect(
        service.installCatalog(
          b,
          ticket: service.beginCatalogUpdate(),
          expectedHash: DmpResources.digest(b),
          provenance: 'test',
        ),
        false,
      );
    }
    expect(store.read(), before);
  });
  test('N03 code retiré et historique', () {
    install('jdv-retire.json');
    expect(service.catalog!.canEmit('urn:abak:test:system', 'TEST_A'), false);
    expect(
      service.catalog!.display(
        'urn:abak:test:system',
        'TEST_A',
        historicalLabel: 'Ancien document',
      ),
      'Ancien document',
    );
    expect(
      () => service.catalog!.triplet('urn:abak:test:system', 'TEST_A'),
      throwsFormatException,
    );
  });
  test('N04 valeur inconnue sans permission', () {
    install('jdv-v1.json');
    for (final system in ['urn:abak:test:system', 'autre']) {
      expect(service.catalog!.display(system, 'TEST_INCONNU'), 'TEST_INCONNU');
      expect(service.catalog!.canEmit(system, 'TEST_INCONNU'), false);
    }
  });
  test('N05 associations type classe et média', () {
    final x16 = fixture('ASS_X16-CorrespondanceType-Classe-DMP.tabs');
    expect(
      NosImport.typeClassMatches(
        x16,
        '2.16.840.1.113883.6.1',
        '34120-6',
        '1.2.250.1.213.1.1.4.1',
        '10',
      ),
      true,
    );
    expect(
      NosImport.typeClassMatches(
        x16,
        '2.16.840.1.113883.6.1',
        '34120-6',
        '1.2.250.1.213.1.1.4.1',
        '52',
      ),
      false,
    );
    final a12 = fixture(
      'ASS_A12-CorresMediaTypeCDANonStructure-XdsFormatCode-CISIS-FHIR.json',
    );
    expect(
      NosImport.mediaFormatMatches(
        a12,
        'text/plain',
        'urn:ihe:iti:xds-sd:text:2008',
      ),
      true,
    );
    expect(
      NosImport.mediaFormatMatches(
        a12,
        'text/plain',
        'urn:ihe:iti:xds-sd:pdf:2008',
      ),
      false,
    );

    final j = jsonDecode(fixture('jdv-v2.json'));
    final a = ValueCatalog.key('urn:abak:test:system', 'TEST_A'),
        b = ValueCatalog.key('urn:abak:test:system', 'TEST_B');
    j['associations'] = {
      'X16': [
        [a, b],
      ],
      'A12': [
        [b, a],
      ],
    };
    final body = jsonEncode(j);
    expect(
      service.installCatalog(
        body,
        ticket: service.beginCatalogUpdate(),
        expectedHash: DmpResources.digest(body),
        provenance: 'synthetic',
      ),
      true,
    );
    expect(service.catalog!.related('X16', a, b), true);
    expect(service.catalog!.related('X16', b, a), false);
    expect(service.catalog!.related('A12', b, a), true);
    expect(service.catalog!.related('A12', a, b), false);
    expect(service.catalog!.canEmit('autre', 'TEST_A'), false);
  });
  test('N06 authorSpecialty exact et sans normalisation abusive', () {
    final official = NosImport.jdvTabs(
      fixture('JDV_J56-AuthorSpecialty-DMP.tabs'),
    );
    expect(
      service.installCatalog(
        official,
        ticket: service.beginCatalogUpdate(),
        expectedHash: DmpResources.digest(official),
        provenance: 'archive officielle J56 2024-09-27',
      ),
      true,
    );
    expect(
      service.catalog!.triplet('1.2.250.1.213.1.1.4.5', 'G15_70'),
      'G15_70^Masseur-Kinésithérapeute^1.2.250.1.213.1.1.4.5',
    );

    final b = jsonEncode({
      'version': 'TEST',
      'entries': [
        {
          'system': '1.2.250.1.213.1.1.4.5',
          'code': 'G15_70',
          'label': 'Masseur-Kinésithérapeute',
          'active': true,
        },
      ],
    });
    service.installCatalog(
      b,
      ticket: service.beginCatalogUpdate(),
      expectedHash: DmpResources.digest(b),
      provenance: 'regression',
    );
    final c = service.catalog!;
    expect(
      c.matchesTriplet(
        '1.2.250.1.213.1.1.4.5',
        'G15_70',
        'G15_70^Masseur-Kinésithérapeute^1.2.250.1.213.1.1.4.5',
      ),
      true,
    );
    expect(
      c.matchesTriplet(
        '1.2.250.1.213.1.1.4.5',
        'G15_70',
        'G15_70^Masseur-kinésithérapeute^1.2.250.1.213.1.1.4.5',
      ),
      false,
    );
  });
  test('N07 mises à jour concurrentes', () async {
    final a = service.beginCatalogUpdate(), b = service.beginCatalogUpdate();
    final v1 = fixture('jdv-v1.json'), v2 = fixture('jdv-v2.json');
    expect(
      service.installCatalog(
        v2,
        ticket: b,
        expectedHash: DmpResources.digest(v2),
        provenance: 'test',
      ),
      true,
    );
    expect(
      service.installCatalog(
        v1,
        ticket: a,
        expectedHash: DmpResources.digest(v1),
        provenance: 'test',
      ),
      false,
    );
    expect(construct().catalog!.version, 'TEST-2');
    final pending = Completer<ResourceReply>();
    transport.replies.add(() => pending.future);
    final first = service.refresh();
    transport.reply(200, body: fixture('parametres-modifies.xml'));
    await service.refresh();
    pending.complete(
      ResourceReply(200, body: fixture('parametres-valides.xml')),
    );
    await first;
    expect(service.parameters!.majority, 21);
    expect(construct().parameters!.majority, 21);
  });
  test('N08 intégrité', () {
    install('jdv-v1.json');
    final before = store.read(), b = fixture('jdv-v2.json');
    expect(
      service.installCatalog(
        '$b ',
        ticket: service.beginCatalogUpdate(),
        expectedHash: DmpResources.digest(b),
        provenance: 'test',
      ),
      false,
    );
    expect(store.read(), before);
  });
  test('I01 isolation et transport exclusivement injecté', () async {
    await HttpOverrides.runZoned(() async {
      await seed();
      install('jdv-v1.json');
      expect(service.parameters, isNotNull);
      expect(construct().catalog, isNotNull);
    }, createHttpClient: (_) => throw StateError('Réseau interdit'));
    expect(dir.path, contains('abak-dmp-resources-test-'));
    expect(transport.calls.length, 1);
  });
}
