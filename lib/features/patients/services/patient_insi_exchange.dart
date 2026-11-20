import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

/// Technical evidence only. Never stores the CPS PIN or private key.
class InsiExchange {
  const InsiExchange({
    required this.id,
    required this.requestXml,
    required this.recordedAt,
    this.responseXml,
    this.httpStatus,
    this.failure,
  });

  final String id, requestXml;
  final String? responseXml, failure;
  final int? httpStatus;
  final DateTime recordedAt;

  static String digest(String text) => sha256.convert(utf8.encode(text)).toString();

  Map<String, Object?> toMap() => {
    'requestId': id,
    'requestXml': requestXml,
    'requestHash': digest(requestXml),
    'responseXml': responseXml,
    'responseHash': responseXml == null ? null : digest(responseXml!),
    'httpStatus': httpStatus,
    'failure': failure,
    'recordedAt': recordedAt.toIso8601String(),
  };

  static Future<void> export(
    Map<String, dynamic> evidence,
    String directory,
    String prefix,
  ) async {
    if (!RegExp(r'^Test_[1-4]\.[0-9]{2}(_cas_[1-9][0-9]*)?$').hasMatch(prefix)) {
      throw StateError('Numéro de test ou de cas invalide.');
    }
    final request = evidence['requestXml'] as String?;
    final response = evidence['responseXml'] as String?;
    if (request == null || digest(request) != evidence['requestHash'] ||
        (response != null && digest(response) != evidence['responseHash'])) {
      throw StateError('Les traces conservées sont incomplètes ou incohérentes.');
    }
    final files = <String, String>{
      '${prefix}_REQUETE.xml': request,
      '${prefix}_REPONSE.xml': ?response,
      '${prefix}_DIAGNOSTIC.txt':
          'Échange : ${evidence['requestId']}\n'
          'Date UTC : ${evidence['recordedAt']}\n'
          'HTTP : ${evidence['httpStatus'] ?? 'non reçu'}\n'
          'Réponse : ${response == null ? 'aucune réponse complète conservée' : 'conservée'}\n'
          'Diagnostic : ${evidence['failure'] ?? 'traitement terminé'}\n',
    };
    final root = Directory(directory);
    final created = <File>[];
    try {
      for (final entry in files.entries) {
        final file = File.fromUri(root.uri.resolve(entry.key));
        await file.create(exclusive: true);
        created.add(file);
        await file.writeAsString(entry.value, encoding: utf8, flush: true);
      }
    } catch (_) {
      for (final file in created.reversed) {
        try { await file.delete(); } catch (_) { /* Do not mask export failure. */ }
      }
      throw StateError(
        'Export non terminé : vérifiez les droits du dossier et utilisez un nom de test/cas encore disponible. Aucun fichier existant n’a été remplacé.',
      );
    }
  }
}
