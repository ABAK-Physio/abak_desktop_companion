import 'dart:convert';
import '../../dmp_setup/bundled_pdf_tools.dart';
import '../../dmp_setup/dmp_setup_service.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../models/episode_document_version.dart';
import 'document_controls_service.dart';
import 'document_medical_service.dart';
import 'document_native_controls.dart';
import 'document_tools_access.dart';
import 'final_pdf_document_service.dart';

/// Advisory check only: never writes medical approvals or DMP control results.
/// The existing post-approval PDF/A and CDA controls remain mandatory.
class PdfaPreflightService {
  PdfaPreflightService(this.controls, {LocalDocumentControlRunner? runner})
    : runner = runner ?? LocalDocumentControlRunner();
  final DocumentControlsService controls;
  final LocalDocumentControlRunner runner;

  Future<String> check(EpisodeDocumentVersion version) async {
    Directory? job;
    DocumentToolsAccess? access;
    try {
      final bundled = await managedTools();
      if (bundled != null) return await _checkManaged(version, bundled);
      final cfg = await controls.configuration();
      if (cfg == null) return 'non_verifie';
      final config = Map<String, Object?>.from(
        jsonDecode(cfg['data_json'] as String),
      );
      final paths = Map<String, String>.from(config['paths'] as Map);
      access = await acquire(paths);
      if (medicalHash(await runner.inspect(paths)) != cfg['fingerprint']) {
        return 'non_verifie';
      }
      final source = await controls.medical.pdf.verifiedFile(version);
      final bytes = await source.readAsBytes();
      if (FinalPdfDocumentService.hash(bytes) != version.digest) {
        return 'non_verifie';
      }
      final temp = await Directory.systemTemp.createTemp('abak-pdfa-import-');
      job = Directory(await temp.resolveSymbolicLinks());
      final pdf = File(p.join(job.path, 'document.pdf'));
      await pdf.writeAsBytes(bytes, flush: true);
      final result = await runner.process(paths['java']!, [
        '-cp',
        paths['vera']!,
        'org.verapdf.apps.GreenfieldCliWrapper',
        '--format',
        'xml',
        '--flavour',
        '1b',
        pdf.path,
      ], job);
      final verdict = pdfaVerdict(
        result.stdout as String,
        result.exitCode,
        pdf,
      );
      await controls.medical.pdf.verifiedFile(version);
      final current = await controls.configuration();
      if (FinalPdfDocumentService.hash(await pdf.readAsBytes()) !=
              version.digest ||
          current?['revision'] != cfg['revision'] ||
          current?['fingerprint'] != cfg['fingerprint'] ||
          medicalHash(await runner.inspect(paths)) != cfg['fingerprint']) {
        return 'non_verifie';
      }
      return verdict;
    } catch (_) {
      return 'non_verifie';
    } finally {
      try {
        if (job != null) await job.delete(recursive: true);
      } finally {
        await access?.release();
      }
    }
  }

  Future<BundledPdfTools?> managedTools() async =>
      await DmpSetupService(
        database: controls.medical.pdf.database,
      ).managedEnabled()
      ? BundledPdfTools.load()
      : null;

  Future<String> _checkManaged(
    EpisodeDocumentVersion version,
    BundledPdfTools tools,
  ) async {
    final source = await controls.medical.pdf.verifiedFile(version);
    final bytes = await source.readAsBytes();
    if (FinalPdfDocumentService.hash(bytes) != version.digest) {
      return 'non_verifie';
    }
    final temporary = await Directory.systemTemp.createTemp(
      'abak-pdfa-managed-',
    );
    final job = Directory(await temporary.resolveSymbolicLinks());
    try {
      final pdf = File(p.join(job.path, 'document.pdf'));
      await pdf.writeAsBytes(bytes, flush: true);
      final output = await runner.process(tools.java, [
        '-cp',
        tools.vera,
        'org.verapdf.apps.GreenfieldCliWrapper',
        '--format',
        'xml',
        '--flavour',
        '1b',
        pdf.path,
      ], job);
      final verdict = pdfaVerdict(
        output.stdout as String,
        output.exitCode,
        pdf,
      );
      await controls.medical.pdf.verifiedFile(version);
      if (FinalPdfDocumentService.hash(await pdf.readAsBytes()) !=
              version.digest ||
          (await managedTools())?.fingerprint != tools.fingerprint) {
        return 'non_verifie';
      }
      return verdict;
    } finally {
      await job.delete(recursive: true);
    }
  }

  Future<DocumentToolsAccess?> acquire(Map<String, String> paths) =>
      DocumentToolsAccess.acquire(paths);

  static String message(String verdict) => switch (verdict) {
    'conforme' =>
      'Précontrôle PDF/A-1b conforme. Validation médicale et contrôles PDF/A/CDA avant DMP toujours requis.',
    'refuse' =>
      'PDF non conforme à PDF/A-1b. Il reste conservé comme document ordinaire. Si votre logiciel le permet, exportez une nouvelle version en PDF/A-1b ; sinon, convertissez le PDF avec un outil adapté, puis importez le résultat. Consultez les parcours PDF/A-1b et leurs statuts de vérification. L’import ne réalise pas cette conversion.',
    _ =>
      'Conformité PDF/A non vérifiée. Le PDF reste conservé. Configurez les outils locaux ou relancez le contrôle avant de décider si une conversion est nécessaire. Aucune conformité DMP établie.',
  };
}
