import 'dart:io';
import '../dmp_session/dmp_work_context.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../core/database/database_service.dart';
import '../patients/services/document_native_controls.dart';
import 'bundled_pdf_tools.dart';

class DmpSetupService {
  DmpSetupService({
    Future<Database> Function()? database,
    Future<BundledPdfTools> Function()? tools,
    Future<void> Function(BundledPdfTools)? probe,
  }) : database = database ?? (() => DatabaseService.database),
       tools = tools ?? BundledPdfTools.load,
       probe = probe ?? selfTest;
  final Future<Database> Function() database;
  final Future<BundledPdfTools> Function() tools;
  final Future<void> Function(BundledPdfTools) probe;
  static const key = 'dmp_enabled';
  static final changes = ValueNotifier<int>(0);
  bool _busy = false;

  static const patientPersonKey = 'dmp_show_patient_person';

  Future<bool> showPatientPerson() async {
    final rows = await (await database()).query(
      'application_settings',
      where: 'setting_key=?',
      whereArgs: [patientPersonKey],
    );
    // Missing, malformed and legacy settings all keep identity hidden.
    return rows.length == 1 && rows.single['setting_value'] == 'true';
  }

  Future<void> setShowPatientPerson(bool value) async {
    await (await database()).insert('application_settings', {
      'setting_key': patientPersonKey,
      'setting_value': value.toString(),
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    changes.value++;
  }

  static const idleKey = 'dmp_idle_lock_minutes';
  static const idleChoices = [5, 15, 30, 60];

  Future<int> idleMinutes() async {
    final rows = await (await database()).query(
      'application_settings',
      where: 'setting_key=?',
      whereArgs: [idleKey],
    );
    final value = rows.isEmpty
        ? null
        : int.tryParse(rows.single['setting_value'].toString());
    return idleChoices.contains(value) ? value! : 15;
  }

  Future<void> setIdleMinutes(int value) async {
    if (!idleChoices.contains(value)) throw ArgumentError.value(value);
    await (await database()).insert('application_settings', {
      'setting_key': idleKey,
      'setting_value': value.toString(),
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    changes.value++;
  }

  Future<bool> managedEnabled() async {
    final rows = await (await database()).query(
      'application_settings',
      where: 'setting_key=?',
      whereArgs: [key],
    );
    return rows.isNotEmpty && rows.single['setting_value'] == 'true';
  }

  /// Only the user's explicit choice enables DMP and its future session policy.
  /// Existing control tools are not evidence of consent to enable DMP.
  Future<bool> enabled() => managedEnabled();

  static Future<void> requireEnabled(DatabaseExecutor db) async {
    final rows = await db.query(
      'application_settings',
      where: 'setting_key=?',
      whereArgs: [key],
    );
    if (rows.isEmpty || rows.single['setting_value'] != 'true') {
      throw StateError('Activez « Utiliser le DMP » dans les réglages.');
    }
  }

  Future<void> setEnabled(bool value) async {
    if (_busy) throw StateError('Préparation DMP déjà en cours.');
    _busy = true;
    try {
      if (value) {
        final ready = await tools();
        await probe(ready);
        if ((await tools()).fingerprint != ready.fingerprint) {
          throw StateError('Les outils DMP ont changé pendant la préparation.');
        }
      }
      await (await database()).insert('application_settings', {
        'setting_key': key,
        'setting_value': value.toString(),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      DmpWorkContext.current.setEnabled(value);
      changes.value++;
    } finally {
      _busy = false;
    }
  }

  /// Legacy installations retain their existing configuration until the user
  /// explicitly changes this option. Explicit disabling always blocks preparation.
  static Future<void> requireNotDisabled(DatabaseExecutor db) async {
    final rows = await db.query(
      'application_settings',
      where: 'setting_key=?',
      whereArgs: [key],
    );
    if (rows.isNotEmpty && rows.single['setting_value'] != 'true') {
      throw StateError('Activez « Utiliser le DMP » dans les réglages.');
    }
  }

  static Future<void> selfTest(BundledPdfTools tools) async {
    final temp = await Directory.systemTemp.createTemp('abak-dmp-setup-');
    final job = Directory(await temp.resolveSymbolicLinks());
    try {
      for (final fixture in {
        'positif_pdf.pdf': 'conforme',
        'sans_xmp_pdf.pdf': 'refuse',
      }.entries) {
        final sample = await Directory(
          p.join(job.path, fixture.value),
        ).create();
        final data = await rootBundle.load(
          'assets/dmp_local/pdf_cda_native/${fixture.key}',
        );
        final pdf = File(p.join(sample.path, 'document.pdf'));
        await pdf.writeAsBytes(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
          flush: true,
        );
        final result = await LocalDocumentControlRunner().process(tools.java, [
          '-cp',
          tools.vera,
          'org.verapdf.apps.GreenfieldCliWrapper',
          '--format',
          'xml',
          '--flavour',
          '1b',
          pdf.path,
        ], sample);
        if (pdfaVerdict(result.stdout as String, result.exitCode, pdf) !=
            fixture.value) {
          throw StateError(
            'Le contrôle PDF/A fourni avec Companion ne fonctionne pas. L’activation DMP est interrompue.',
          );
        }
      }
    } finally {
      await job.delete(recursive: true);
    }
  }
}
