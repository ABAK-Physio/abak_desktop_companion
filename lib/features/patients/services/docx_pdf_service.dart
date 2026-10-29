import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';
import 'document_controls_service.dart';
import 'document_medical_service.dart';
import 'document_native_controls.dart';
import 'document_native_launcher.dart';
import 'document_tools_access.dart';
import 'final_pdf_document_service.dart';
import 'pdf_conversion_evidence.dart';
import '../models/episode_document_version.dart';

class DocxPdfService {
  DocxPdfService({required this.controls});
  final DocumentControlsService controls;

  /// Inspect the bounded OOXML package before Office reads it. No macros,
  /// embedded programs, external content or data fields may be evaluated.
  static void inspectDocx(Uint8List bytes) {
    if (bytes.isEmpty || bytes.length > FinalPdfDocumentService.limit) {
      throw FinalPdfException(
        'Le DOCX doit être non vide et ne pas dépasser 20 Mio.',
      );
    }
    final archive = ZipDecoder().decodeBytes(bytes, verify: true);
    var total = 0;
    final seen = <String>{};
    XmlDocument? body;
    if (archive.length > 1500) throw FinalPdfException('DOCX trop complexe.');
    for (final file in archive) {
      final name = file.name;
      if (!seen.add(name) ||
          name.startsWith('/') ||
          name.contains('\\') ||
          name.split('/').contains('..') ||
          file.isSymbolicLink ||
          RegExp(
            r'vbaproject|activex|embeddings/',
            caseSensitive: false,
          ).hasMatch(name)) {
        throw FinalPdfException(
          'DOCX contenant un composant incorporé non pris en charge.',
        );
      }
      total += file.size;
      if (total > 80 * 1024 * 1024 || file.size > 25 * 1024 * 1024) {
        throw FinalPdfException('DOCX décompressé trop volumineux.');
      }
      if (!file.isFile || !(name.endsWith('.xml') || name.endsWith('.rels'))) {
        continue;
      }
      final text = utf8.decode(file.content);
      if (RegExp(r'<!DOCTYPE|<!ENTITY', caseSensitive: false).hasMatch(text)) {
        throw FinalPdfException('Déclarations XML externes interdites.');
      }
      final xml = XmlDocument.parse(text);
      if (name == 'word/document.xml') body = xml;
      for (final e in xml.descendants.whereType<XmlElement>()) {
        if (e.name.local == 'Relationship' &&
            e.getAttribute('TargetMode') == 'External') {
          // Web hyperlinks are not fetched. Linked pictures, templates and
          // local-file hyperlinks would otherwise leak external source data.
          final uri = Uri.tryParse(e.getAttribute('Target') ?? '');
          if (!(e.getAttribute('Type') ?? '').endsWith('/hyperlink') ||
              uri == null ||
              !['https', 'http', 'mailto'].contains(uri.scheme)) {
            throw FinalPdfException(
              'Le DOCX contient un contenu externe lié. Incorporez-le avant conversion.',
            );
          }
        }
        if (['altChunk', 'object', 'ins', 'del'].contains(e.name.local)) {
          throw FinalPdfException(
            'Contenu incorporé ou modifications suivies : finalisez le DOCX avant conversion.',
          );
        }
      }
      final fields =
          '${xml.descendants.whereType<XmlElement>().where((e) => e.name.local == 'instrText').map((e) => e.innerText).join(' ')} ${xml.descendants.whereType<XmlElement>().where((e) => e.name.local == 'fldSimple').map((e) => e.attributes.map((a) => a.value).join(' ')).join(' ')}';
      if (RegExp(
        r'\b(DDE|DDEAUTO|INCLUDETEXT|INCLUDEPICTURE|LINK|DATABASE|MACROBUTTON)\b',
        caseSensitive: false,
      ).hasMatch(fields)) {
        throw FinalPdfException(
          'Champs de contenu externe non pris en charge.',
        );
      }
    }
    final text =
        body?.descendants
            .whereType<XmlElement>()
            .where((e) => e.name.local == 't')
            .map((e) => e.innerText)
            .join('')
            .trim() ??
        '';
    if (!seen.contains('[Content_Types].xml') || body == null || text.isEmpty) {
      throw FinalPdfException('Le DOCX ne contient pas de texte à convertir.');
    }
  }

  Future<EpisodeDocumentVersion> convert({
    required String sourcePath,
    required String episodeId,
    required String title,
    String? documentId,
    PdfOrigin origin = const PdfOrigin('external'),
    bool reuseOriginDocument = false,
    String? expectedSourceRevision,
    void Function(String)? onProgress,
  }) async {
    if (!Platform.isMacOS) {
      throw FinalPdfException(
        'Conversion DOCX disponible sur macOS uniquement.',
      );
    }
    if (p.extension(sourcePath).toLowerCase() != '.docx') {
      throw FinalPdfException('Sélectionnez un fichier DOCX.');
    }
    final cfg = await controls.configuration();
    if (cfg == null) {
      throw FinalPdfException(
        'Configurez les outils PDF/A et CDA avant la conversion.',
      );
    }
    final configuration = Map<String, Object?>.from(
      jsonDecode(cfg['data_json'] as String),
    );
    final paths = Map<String, String>.from(configuration['paths'] as Map);
    onProgress?.call('Vérification des accès et des outils locaux…');
    final access = await DocumentToolsAccess.acquire(
      paths,
      includeOffice: true,
    );
    try {
      if (medicalHash(await controls.runner.inspect(paths)) !=
          cfg['fingerprint']) {
        throw FinalPdfException(
          'Les outils de contrôle ont changé : vérifiez leur configuration.',
        );
      }
      await LocalDocumentControlRunner.regular(sourcePath);
      final source = File(sourcePath);
      if (await source.length() > FinalPdfDocumentService.limit) {
        throw FinalPdfException('DOCX limité à 20 Mio.');
      }
      final bytes = await source.readAsBytes();
      inspectDocx(bytes);
      final sourceHash = FinalPdfDocumentService.hash(bytes);
      final temp = await Directory.systemTemp.createTemp('abak-docx-');
      final job = Directory(await temp.resolveSymbolicLinks());
      try {
        await File(
          p.join(job.path, 'source.docx'),
        ).writeAsBytes(bytes, flush: true);
        onProgress?.call('Conversion du DOCX enregistré en PDF…');
        final answer = await NativeDocumentLauncher.channel
            .invokeMapMethod<String, dynamic>('run', {
              'protocol': 1,
              'operation': 'docx',
              'job': job.path,
              'sourceHash': sourceHash,
              'office': (paths['office'] ?? '').isEmpty
                  ? '/Applications/LibreOffice.app'
                  : paths['office']!,
            })
            .timeout(const Duration(minutes: 5));
        if (answer == null || answer['error'] != null) {
          throw FinalPdfException(
            answer?['error'] ?? 'Conversion indisponible.',
          );
        }
        if (answer['protocol'] != 1 ||
            answer['operation'] != 'docx' ||
            answer['sourceHash'] != sourceHash ||
            answer['engineSignatureVerified'] != true ||
            answer['networkDenied'] != true ||
            answer['privateProfile'] != true ||
            answer['macrosDisabled'] != true) {
          throw FinalPdfException('Conversion locale non vérifiée.');
        }
        final pdf = base64Decode(answer['pdf'] as String);
        if (pdf.length > FinalPdfDocumentService.limit ||
            FinalPdfDocumentService.hash(pdf) != answer['pdfHash']) {
          throw FinalPdfException(
            'PDF produit différent du rapport de conversion.',
          );
        }
        final target = File(p.join(job.path, 'document.pdf'));
        await target.writeAsBytes(pdf, flush: true);
        onProgress?.call('Vérification de la conformité PDF/A-1b…');
        final result = await NativeDocumentLauncher.run(
          paths['java']!,
          [
            '-cp',
            paths['vera']!,
            'org.verapdf.apps.GreenfieldCliWrapper',
            '--format',
            'xml',
            '--flavour',
            '1b',
            target.path,
          ],
          job,
          const Duration(minutes: 4),
        );
        final verdict = pdfaVerdict(
          result.stdout as String,
          result.exitCode,
          target,
        );
        if (verdict != 'conforme') {
          throw FinalPdfException(
            verdict == 'refuse'
                ? 'Le PDF produit ne respecte pas PDF/A-1. Aucune version finale conservée.'
                : 'Conformité PDF/A non vérifiée. Aucune version finale conservée.',
          );
        }
        if (FinalPdfDocumentService.hash(await source.readAsBytes()) !=
                sourceHash ||
            (await controls.configuration())?['fingerprint'] !=
                cfg['fingerprint']) {
          throw FinalPdfException(
            'DOCX ou configuration modifiés pendant la conversion. Recommencez.',
          );
        }
        final evidence = PdfConversionEvidence({
          'source.docx': bytes,
          'conversion.json': utf8.encode(
            jsonEncode({
              for (final e in answer.entries)
                if (e.key != 'pdf') e.key: e.value,
              'pdfa': verdict,
              'validationConfigurationHash': cfg['fingerprint'],
              'createdAt': DateTime.now().toUtc().toIso8601String(),
            }),
          ),
          'conversion-pdfa.xml': utf8.encode(result.stdout as String),
          'conversion-pdfa-launch.json': await File(
            p.join(job.path, 'native-launch-pdfa.json'),
          ).readAsBytes(),
        });
        onProgress?.call(
          'Conservation de la version PDF conforme et de ses preuves…',
        );
        return await controls.medical.pdf.importPdf(
          episodeId: episodeId,
          sourcePath: target.path,
          title: title,
          documentId: documentId,
          origin: origin,
          conversion: evidence,
          reuseOriginDocument: reuseOriginDocument,
          expectedSourceRevision: expectedSourceRevision,
        );
      } on PlatformException catch (e) {
        throw FinalPdfException(
          e.message ?? 'Service de conversion indisponible.',
        );
      } finally {
        await temp.delete(recursive: true);
      }
    } finally {
      await access.release();
    }
  }
}
