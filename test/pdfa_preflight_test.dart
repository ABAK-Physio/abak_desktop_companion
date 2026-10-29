import 'dart:convert';
import 'package:abak_desktop_companion/features/dmp_setup/bundled_pdf_tools.dart';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/patients/models/episode_document_version.dart';
import 'package:abak_desktop_companion/features/patients/services/document_controls_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_medical_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_native_controls.dart';
import 'package:abak_desktop_companion/features/patients/services/document_tools_access.dart';
import 'package:abak_desktop_companion/features/patients/services/final_pdf_document_service.dart';
import 'package:abak_desktop_companion/features/patients/services/pdfa_preflight_service.dart';

class StoredPdf extends FinalPdfDocumentService {
  StoredPdf(this.file)
    : super(
        database: () =>
            throw StateError('No medical or DMP database access permitted'),
      );
  final File file;
  int reads = 0;
  @override
  Future<File> verifiedFile(EpisodeDocumentVersion version) async {
    reads++;
    if (hash(await file.readAsBytes()) != version.digest) {
      throw StateError('Modified PDF');
    }
    return file;
  }

  static String hash(List<int> bytes) => FinalPdfDocumentService.hash(bytes);
}

class ConfigControls extends DocumentControlsService {
  ConfigControls(FinalPdfDocumentService pdf, this.config)
    : super(medical: DocumentMedicalService(pdf: pdf));
  Map<String, Object?>? config;
  @override
  Future<Map<String, Object?>?> configuration() async => config;
}

class Validator extends LocalDocumentControlRunner {
  final configuration = <String, Object?>{
    'paths': <String, String>{'java': '/java', 'vera': '/vera.jar'},
  };
  String result = 'conforme';
  bool changed = false;
  Future<void> Function(Directory)? during;
  Directory? job;
  int calls = 0;
  @override
  Future<Map<String, Object?>> inspect(Map<String, String> paths) async =>
      changed ? {'changed': true} : configuration;
  @override
  Future<ProcessResult> process(
    String java,
    List<String> args,
    Directory job,
  ) async {
    calls++;
    this.job = job;
    expect(args.sublist(3, 7), ['--format', 'xml', '--flavour', '1b']);
    final file = File(args.last);
    final size = await file.length();
    await during?.call(job);
    if (result == 'exception') {
      throw const ProcessException('/java', [], 'Unavailable');
    }
    if (result == 'malformed') return ProcessResult(1, 0, '<report/>', '');
    final ok = result == 'conforme';
    final n = ok ? 0 : 1;
    return ProcessResult(
      1,
      n,
      '''<report><jobs><job><item size="$size"><name>${file.path}</name></item>
<validationReport profileName="PDF/A-1b validation profile" jobEndStatus="normal" isCompliant="$ok"><details passedRules="1" passedChecks="1" failedRules="$n" failedChecks="$n"/></validationReport>
</job></jobs><batchSummary totalJobs="1" failedToParse="0" encrypted="0" outOfMemory="0" veraExceptions="0"><validationReports failedJobs="0" compliant="${ok ? 1 : 0}" nonCompliant="$n">1</validationReports></batchSummary></report>''',
      '',
    );
  }
}

class AccessiblePreflight extends PdfaPreflightService {
  AccessiblePreflight(super.controls, {required super.runner});
  BundledPdfTools? bundled;
  @override
  Future<BundledPdfTools?> managedTools() async => bundled;
  @override
  Future<DocumentToolsAccess?> acquire(Map<String, String> paths) async => null;
}

void main() {
  late Directory dir;
  late File file;
  late StoredPdf pdf;
  late Validator runner;
  late ConfigControls controls;
  late EpisodeDocumentVersion version;
  late AccessiblePreflight service;
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('preflight-test-');
    file = await File('${dir.path}/source.pdf').writeAsString('%PDF-test');
    pdf = StoredPdf(file);
    runner = Validator();
    controls = ConfigControls(pdf, {
      'data_json': jsonEncode(runner.configuration),
      'fingerprint': medicalHash(runner.configuration),
      'revision': 1,
    });
    version = EpisodeDocumentVersion({
      'version_id': 'v1',
      'sha256': FinalPdfDocumentService.hash(await file.readAsBytes()),
    });
    service = AccessiblePreflight(controls, runner: runner);
  });
  tearDown(() async => dir.delete(recursive: true));

  test('bundled preflight works without external CDA configuration', () async {
    controls.config = null;
    service.bundled = const BundledPdfTools('/java', '/vera.jar', 'same');
    expect(await service.check(version), 'conforme');
    expect(runner.calls, 1);
  });
  test('bundled preflight rejects disabling during execution', () async {
    service.bundled = const BundledPdfTools('/java', '/vera.jar', 'same');
    runner.during = (_) async {
      service.bundled = null;
    };
    expect(await service.check(version), 'non_verifie');
  });
  test('bundled preflight rejects changed tool fingerprint', () async {
    service.bundled = const BundledPdfTools('/java', '/vera.jar', 'before');
    runner.during = (_) async {
      service.bundled = const BundledPdfTools('/java', '/vera.jar', 'after');
    };
    expect(await service.check(version), 'non_verifie');
  });

  for (final entry in {
    'conforme': 'conforme',
    'refuse': 'refuse',
    'malformed': 'non_verifie',
    'exception': 'non_verifie',
  }.entries) {
    test(
      '${entry.key}: checks stored bytes without medical/DMP database access',
      () async {
        runner.result = entry.key;
        expect(await service.check(version), entry.value);
        expect(runner.calls, 1);
        expect(await runner.job!.exists(), false);
        expect(await file.readAsString(), '%PDF-test');
      },
    );
  }
  test(
    'missing configuration never claims conformity or launches a tool',
    () async {
      controls.config = null;
      expect(await service.check(version), 'non_verifie');
      expect(runner.calls, 0);
    },
  );
  test(
    'changed stored PDF invalidates an otherwise successful check',
    () async {
      runner.during = (_) async {
        await file.writeAsString('changed');
      };
      expect(await service.check(version), 'non_verifie');
    },
  );
  test('changed checked copy invalidates the verdict', () async {
    runner.during = (job) async {
      await File('${job.path}/document.pdf').writeAsString('changed');
    };
    expect(await service.check(version), 'non_verifie');
  });
  test(
    'configuration revision changed during execution invalidates verdict',
    () async {
      runner.during = (_) async {
        controls.config = {...controls.config!, 'revision': 2};
      };
      expect(await service.check(version), 'non_verifie');
    },
  );
  test('tool mutation invalidates verdict', () async {
    runner.during = (_) async {
      runner.changed = true;
    };
    expect(await service.check(version), 'non_verifie');
  });
  test('changed tools block launch', () async {
    runner.changed = true;
    expect(await service.check(version), 'non_verifie');
    expect(runner.calls, 0);
  });
}
