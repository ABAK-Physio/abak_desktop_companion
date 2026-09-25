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
  ExchangeDirectoryAccess? _directoryAccess;
  Future<void>? _activeScan;
  Future<void> _lifecycle = Future<void>.value();

  /// L’interface pourra afficher cet état même si l’erreur survient
  /// avant la création de la première fenêtre Flutter.
  final ValueNotifier<String?> accessProblem = ValueNotifier<String?>(null);

  void Function(String message)? onImportMessage;
  final Set<String> _seenPaths = <String>{};
  final Set<String> _processingPaths = <String>{};

  bool get isRunning => _timer != null;

  Future<void> _serialize(Future<void> Function() operation) {
    final next = _lifecycle.then((_) => operation());
    _lifecycle = next.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return next;
  }

  Future<void> start() => _serialize(_start);

  Future<void> _start() async {
    if (_timer != null) return;
    await _stop();

    try {
      final access = await _exchangeDirectoryService.acquireExchangeDirectory();
      _directoryAccess = access;
      final exchangeDir = access.directory;

      await _markExistingFiles(exchangeDir);
      accessProblem.value = null;

      _timer = Timer.periodic(const Duration(seconds: 3), (_) {
        // Un seul scan à la fois : ne pas libérer un accès encore utilisé.
        if (_activeScan != null) return;
        _activeScan = _runScan(exchangeDir);
      });
      debugPrint('📥 Surveillance du dossier d’échange démarrée');
    } catch (error) {
      _suspendForAccessProblem();
      await _releaseDirectoryAccess();
      debugPrint('Surveillance du dossier d’échange suspendue : $error');
    }
  }

  Future<void> stop() => _serialize(_stop);

  Future<void> _stop() async {
    _timer?.cancel();
    _timer = null;
    // Laisser finir une copie/importation avant de retirer son autorisation.
    final scan = _activeScan;
    if (scan != null) await scan;
    await _releaseDirectoryAccess();
    _seenPaths.clear();
    _processingPaths.clear();
  }

  Future<void> restart() => _serialize(() async {
    await _stop();
    await _start();
  });

  Future<void> _releaseDirectoryAccess() async {
    final access = _directoryAccess;
    if (access == null) return;
    _directoryAccess = null;
    try {
      await access.release();
    } catch (error) {
      debugPrint('Impossible de libérer l’accès au dossier d’échange : $error');
    }
  }

  void _suspendForAccessProblem() {
    _timer?.cancel();
    _timer = null;
    accessProblem.value =
    'La surveillance du dossier d’échange est suspendue. '
        'Dans Réglages, sélectionnez à nouveau ce dossier pour autoriser '
        'son accès, ou reconnectez son volume puis réessayez.';
  }

  Future<void> _markExistingFiles(Directory exchangeDir) async {
    if (!await exchangeDir.exists()) {
      throw FileSystemException('Dossier d’échange indisponible', exchangeDir.path);
    }
    // La lecture réelle doit réussir ; exists() seul ne valide pas l’accès.
    final existingFiles = await exchangeDir.list().where((entry) =>
    entry is File && _isAbakFile(entry)).toList();
    _seenPaths.addAll(existingFiles.map((file) => file.path));
  }

  Future<void> _runScan(Directory exchangeDir) async {
    try {
      await _scan(exchangeDir);
    } finally {
      if (_timer == null) await _releaseDirectoryAccess();
      _activeScan = null;
    }
  }

  Future<void> _scan(Directory exchangeDir) async {
    try {
      if (!await exchangeDir.exists()) {
        throw FileSystemException('Dossier d’échange indisponible', exchangeDir.path);
      }

      final entries = await exchangeDir.list().toList();
      final files = entries.whereType<File>().where(_isAbakFile);
      for (final file in files) {
        // Un arrêt demandé laisse finir le fichier courant, sans en ouvrir un autre.
        if (_timer == null) break;
        final path = file.path;
        if (_seenPaths.contains(path) || _processingPaths.contains(path)) continue;
        _seenPaths.add(path);
        _processingPaths.add(path);
        await _handleNewExchangeFile(file);
      }
    } catch (error) {
      _suspendForAccessProblem();
      debugPrint('Lecture du dossier d’échange impossible : $error');
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
      if ((status == 'needs_resolution' || status == 'error') &&
          await file.exists()) {
        await file.delete();

        debugPrint(
          '🧹 Fichier source supprimé du dossier d’échange : $originalPath',
        );
      }

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
        await Future<void>.delayed(const Duration(milliseconds: 500));
        continue;
      }

      final currentSize = await file.length();

      if (previousSize != null && currentSize == previousSize) {
        return;
      }

      previousSize = currentSize;

      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<String> _copyToIncomingAbak(File sourceFile) async {
    final appSupportDir = await getApplicationSupportDirectory();

    final incomingDir = Directory(p.join(appSupportDir.path, 'incoming_abak'));

    if (!await incomingDir.exists()) {
      await incomingDir.create(recursive: true);
    }

    final originalName = p.basename(sourceFile.path);
    final safeName = _uniqueFileName(incomingDir, originalName);

    final destinationPath = p.join(incomingDir.path, safeName);

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