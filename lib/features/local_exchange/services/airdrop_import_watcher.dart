import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/settings/exchange_directory_service.dart';
import '../../import_export/abak_import_launcher.dart';

class AirDropImportWatcher {
  AirDropImportWatcher._();

  static final AirDropImportWatcher instance = AirDropImportWatcher._();

  final ExchangeDirectoryService _exchangeDirectoryService =
  ExchangeDirectoryService();

  Timer? _timer;
  void Function(String message)? onImportMessage;
  final Set<String> _seenPaths = <String>{};
  final Set<String> _processingPaths = <String>{};

  bool get isRunning => _timer != null;

  Future<void> start() async {
    if (_timer != null) return;

    final exchangeDir =
    await _exchangeDirectoryService.getExchangeDirectory();

    debugPrint('📥 Watcher dossier d’échange démarré');
    debugPrint('📂 Dossier surveillé : ${exchangeDir.path}');

    await _markExistingFiles(exchangeDir);

    _timer = Timer.periodic(
      const Duration(seconds: 3),
          (_) => _scan(exchangeDir),
    );
  }

  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    _seenPaths.clear();
    _processingPaths.clear();

    debugPrint('📥 Watcher dossier d’échange arrêté');
  }

  Future<void> _markExistingFiles(Directory exchangeDir) async {
    try {
      if (!await exchangeDir.exists()) {
        debugPrint(
          '⚠️ Dossier d’échange introuvable : ${exchangeDir.path}',
        );
        return;
      }

      final existingFiles = exchangeDir
          .listSync()
          .whereType<File>()
          .where(_isAbakFile)
          .toList();

      for (final file in existingFiles) {
        _seenPaths.add(file.path);
      }

      debugPrint(
        '📚 ${_seenPaths.length} fichier(s) .abak déjà présent(s)',
      );
    } catch (e) {
      debugPrint(
        '⚠️ Watcher dossier d’échange erreur initialisation : $e',
      );
    }
  }

  Future<void> _scan(Directory exchangeDir) async {
    try {
      if (!await exchangeDir.exists()) {
        debugPrint(
          '⚠️ Dossier d’échange introuvable : ${exchangeDir.path}',
        );
        return;
      }

      final files = exchangeDir
          .listSync()
          .whereType<File>()
          .where(_isAbakFile)
          .toList();

      for (final file in files) {
        final path = file.path;

        if (_seenPaths.contains(path)) continue;
        if (_processingPaths.contains(path)) continue;

        _seenPaths.add(path);
        _processingPaths.add(path);

        await _handleNewExchangeFile(file);
      }
    } catch (e) {
      debugPrint('⚠️ Watcher dossier d’échange erreur scan : $e');
    }
  }

  bool _isAbakFile(File file) {
    return p.extension(file.path).toLowerCase() == '.abak';
  }

  Future<void> _handleNewExchangeFile(File file) async {
    final originalPath = file.path;

    try {
      await _waitForStableFile(file);

      final stat = await file.stat();

      debugPrint('🆕 Nouveau fichier .abak détecté');
      debugPrint('📄 Nom : ${p.basename(originalPath)}');
      debugPrint('📍 Chemin : $originalPath');
      debugPrint('📦 Taille : ${stat.size} octets');
      debugPrint('🕒 Modifié : ${stat.modified.toIso8601String()}');

      final destinationPath = await _copyToIncomingAbak(file);

      debugPrint('📦 Copie vers incoming_abak');
      debugPrint('📍 Destination : $destinationPath');

      final result = await AbakImportLauncher.importArchiveFromPath(
        destinationPath,
        sourceLabel: 'exchange_directory',
      );

      debugPrint('📥 IMPORT DOSSIER ÉCHANGE = $result');
      final message = result['message'] as String? ?? 'Import terminé.';

      onImportMessage?.call(message);

      final status = result['status'] as String?;

      final importedResults = result['importedResults'] as int? ?? 0;
      final skippedResults = result['skippedResults'] as int? ?? 0;
      final conflictResults = result['conflictResults'] as int? ?? 0;
      final importedMetrics = result['importedMetrics'] as int? ?? 0;
      final patientLabel = result['patientLabel'] as String?;

      debugPrint('📣 Résultat import dossier d’échange');
      debugPrint('   Statut : $status');
      debugPrint('   Message : $message');

      if (patientLabel != null && patientLabel.trim().isNotEmpty) {
        debugPrint('   Patient : $patientLabel');
      }

      debugPrint('   Résultats importés : $importedResults');
      debugPrint('   Résultats ignorés : $skippedResults');
      debugPrint('   Conflits : $conflictResults');
      debugPrint('   Métriques importées : $importedMetrics');
    } catch (e, stack) {
      debugPrint('❌ Erreur traitement fichier $originalPath : $e');
      debugPrint('$stack');
    } finally {
      _processingPaths.remove(originalPath);
    }
  }

  Future<void> _waitForStableFile(File file) async {
    int? previousSize;

    for (var i = 0; i < 5; i++) {
      if (!await file.exists()) {
        await Future<void>.delayed(
          const Duration(milliseconds: 500),
        );
        continue;
      }

      final currentSize = await file.length();

      if (previousSize != null && currentSize == previousSize) {
        return;
      }

      previousSize = currentSize;

      await Future<void>.delayed(
        const Duration(milliseconds: 500),
      );
    }
  }

  Future<String> _copyToIncomingAbak(File sourceFile) async {
    final appSupportDir = await getApplicationSupportDirectory();

    final incomingDir = Directory(
      p.join(appSupportDir.path, 'incoming_abak'),
    );

    if (!await incomingDir.exists()) {
      await incomingDir.create(recursive: true);
    }

    final originalName = p.basename(sourceFile.path);
    final safeName = _uniqueFileName(incomingDir, originalName);

    final destinationPath = p.join(
      incomingDir.path,
      safeName,
    );

    await sourceFile.copy(destinationPath);

    return destinationPath;
  }

  String _uniqueFileName(Directory directory, String fileName) {
    final baseName = p.basenameWithoutExtension(fileName);
    final extension = p.extension(fileName);

    var candidate = fileName;
    var index = 1;

    while (File(p.join(directory.path, candidate)).existsSync()) {
      candidate = '${baseName}_$index$extension';
      index++;
    }

    return candidate;
  }
}