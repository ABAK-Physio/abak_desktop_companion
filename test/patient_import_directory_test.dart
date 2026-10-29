import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_documents_service.dart';

void main() {
  test('finds registered patient report folder using care_episode_id', () async {
    sqfliteFfiInit();
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    final root = await Directory.systemTemp.createTemp('patient-import-');
    addTearDown(() async {
      await db.close();
      await root.delete(recursive: true);
    });
    await db.execute(
      'CREATE TABLE care_episodes(care_episode_id TEXT,patient_id TEXT)',
    );
    await db.execute(
      'CREATE TABLE patient_document_folders(patient_id TEXT,root_path TEXT,folder_name TEXT)',
    );
    await db.insert('care_episodes', {
      'care_episode_id': 'episode',
      'patient_id': 'patient',
    });
    await db.insert('patient_document_folders', {
      'patient_id': 'patient',
      'root_path': root.path,
      'folder_name': 'PATIENT_FICTIF',
    });
    final report = await Directory(
      '${root.path}/PATIENT_FICTIF/Rapport',
    ).create(recursive: true);
    final folders = await const PatientDocumentsService().findForEpisode(
      episodeId: 'episode',
      rootPath: root.path,
      database: db,
    );
    expect(folders?.report, report.path);
    expect(await Directory(folders!.report).exists(), isTrue);
    expect(
      await const PatientDocumentsService().findForEpisode(
        episodeId: 'absent',
        rootPath: root.path,
        database: db,
      ),
      isNull,
    );
    expect(
      await const PatientDocumentsService().findForEpisode(
        episodeId: 'episode',
        rootPath: root.parent.path,
        database: db,
      ),
      isNull,
    );
  });
}
