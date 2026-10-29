import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../contracts.dart';
import '../../../../dmp_transfer/transfer_simulation.dart';

class DmpNativeFailure extends DmpChainBlock {
  DmpNativeFailure(this.code) : super(messageFor(code));
  final String code;
  static String messageFor(String code) {
    const stages = {
      'CONFIGURATION': 'préparation du moteur',
      'TRUST': 'contrôle des autorités et listes de révocation',
      'CARD': 'ouverture de la session carte',
      'CERTIFICATE': 'contrôle des certificats CPS',
      'CHALLENGE': 'vérification cryptographique de la CPS',
      'TD_TLS': 'connexion sécurisée au service patients DV1',
      'REPOSITORY_TLS': 'connexion sécurisée au service repository DV1',
      'RESULT': 'lecture du résultat d’authentification',
    };
    const categories = [
      'PROVIDER',
      'MISSING_VALUE',
      'INVALID_VALUE',
      'IO',
      'UNSUPPORTED',
      'INTERNAL',
    ];
    for (final stage in stages.entries) {
      for (final category in categories) {
        if (code == 'NATIVE_OPEN_${stage.key}_$category') {
          return 'Arrêt du moteur CPS : ${stage.value}. Diagnostic : $code. Aucune nouvelle tentative automatique.';
        }
      }
    }
    const sessionStages = [
      'CONFIGURATION',
      'CONTEXT',
      'EXCHANGE',
      'RESULT',
      'SESSION',
    ];
    if (sessionStages.any((s) => code == 'NATIVE_SESSION_$s')) {
      return 'Companion n’a pas pu établir la session d’authentification. Diagnostic : $code.';
    }
    return switch (code) {
      'NATIVE_LAUNCH' =>
        'Le moteur CPS ne peut pas démarrer. Vérifiez l’installation de Companion.',
      'NATIVE_EXIT' =>
        'Le moteur CPS s’est arrêté avant de répondre. Aucun résultat DV1 confirmé. Consultez le diagnostic local.',
      'NATIVE_TIMEOUT' =>
        'Le moteur CPS ne répond pas dans le délai prévu. Opération arrêtée, sans nouvelle tentative automatique.',
      'NATIVE_PROTOCOL' =>
        'Réponse du moteur CPS illisible ou incohérente. Opération arrêtée.',
      'CPS_MECHANISM' =>
        'La Cryptolib refuse le mécanisme cryptographique demandé. Opération arrêtée.',
      'CPS_CRYPTO_FAILURE' =>
        'La Cryptolib signale un échec de l’opération cryptographique. Aucune nouvelle tentative automatique.',
      'CPS_KEY_USAGE' =>
        'La CPS refuse cet usage de la clé cryptographique. Opération arrêtée.',
      'AUTHENTICATION_EXPIRED' =>
        'L’authentification CPS a pris fin. Relancez la préparation pour saisir votre PIN. Aucun accès DMP effectué.',
      'CPS_PIN' => 'PIN incorrect. Aucune nouvelle tentative automatique.',
      'CPS_BLOCKED' => 'PIN bloqué. Authentification arrêtée.',
      'CPS_ABSENT' => 'CPS absente ou retirée. Traitement arrêté.',
      'CPS_BUSY' => 'Une opération CPS est déjà active. Traitement arrêté.',
      'CPS_IDENTITY' => 'CPS ou situation différente du contexte validé.',
      'CPS_CERTIFICATE' => 'Certificats CPS absents, ambigus ou différents.',
      'CPS_UNAVAILABLE' =>
        'Service CPS indisponible. Aucun nouvel essai automatique.',
      'CANCELLED' => 'Authentification annulée.',
      'TLS_TRUST' => TlsFailure.trust.message,
      'TLS_HOSTNAME' => TlsFailure.hostname.message,
      'TLS_EXPIRED' => TlsFailure.expired.message,
      'TLS_FUTURE' => TlsFailure.future.message,
      'TLS_REVOKED' => TlsFailure.revoked.message,
      'TLS_CRL' => TlsFailure.staleCrl.message,
      'TCP_CONNECT_TIMEOUT' =>
        'Délai dépassé lors de la connexion réseau à DV1. Aucune relance automatique.',
      'TLS_HANDSHAKE_TIMEOUT' =>
        'Délai dépassé pendant la négociation TLS avec DV1. Aucune relance automatique.',
      'HTTP_STATUS_TIMEOUT' =>
        'Délai dépassé dans l’attente du début de la réponse DV1. Aucune relance automatique.',
      'HTTP_HEADERS_TIMEOUT' =>
        'Délai dépassé pendant la lecture des en-têtes de réponse DV1. Aucune relance automatique.',
      'HTTP_BODY_TIMEOUT' =>
        'Délai dépassé pendant la lecture du contenu de la réponse DV1. Réponse incomplète ; aucune relance automatique.',
      'TLS_TIMEOUT' => TlsFailure.timeout.message,
      'TLS_UNAVAILABLE' => TlsFailure.unavailable.message,
      'TLS_PROTOCOL' => 'Version TLS ou suite cryptographique non autorisée.',
      'SESSION' => 'Session native expirée, modifiée ou déjà consommée.',
      'HTTP' => 'Réponse HTTP absente, ambiguë ou trop volumineuse.',
      'CONFIGURATION' =>
        'Configuration native absente, modifiée ou non vérifiée.',
      _ =>
        'Service natif indisponible ou réponse non vérifiée. Traitement arrêté.',
    };
  }
}

abstract interface class DmpNativeBridge {
  Future<Map<String, String>> call(
    String operation,
    Map<String, String> fields,
  );
  Future<void> close();
}

/// A single worker, no shell, no PIN in argv/environment/files/logs. The worker
/// has no listener or HTTP control API. Only correlated, bounded stdio frames.
class DmpProcessBridge implements DmpNativeBridge {
  DmpProcessBridge({
    required this.executable,
    required List<String> arguments,
    this.timeout = const Duration(seconds: 45),
    this.searchTimeout = const Duration(seconds: 90),
  }) : arguments = List.unmodifiable(arguments);
  final String executable;
  final List<String> arguments;
  final Duration timeout, searchTimeout;
  Duration timeoutFor(String operation) =>
      const {
        'finddocuments',
        'submissionsearch',
        'search',
        'consultmetadata',
        'visibilitymetadata',
      }.contains(operation)
      ? searchTimeout
      : timeout;
  Process? _process;
  StreamIterator<String>? _lines;
  StreamSubscription<List<int>>? _errors;
  bool _busy = false, _closed = false;
  int _sequence = 0;
  @override
  Future<Map<String, String>> call(
    String operation,
    Map<String, String> fields,
  ) async {
    if (_busy || _closed) throw DmpNativeFailure('SESSION');
    _busy = true;
    try {
      return await _exchange(operation, fields).timeout(timeoutFor(operation));
    } on DmpNativeFailure {
      rethrow;
    } on ProcessException {
      await _terminate();
      throw DmpNativeFailure('NATIVE_LAUNCH');
    } on TimeoutException {
      await _terminate();
      throw DmpNativeFailure('NATIVE_TIMEOUT');
    } on FormatException {
      await _terminate();
      throw DmpNativeFailure('NATIVE_PROTOCOL');
    } catch (_) {
      await _terminate();
      throw DmpNativeFailure('NATIVE');
    } finally {
      _busy = false;
    }
  }

  Future<Map<String, String>> _exchange(
    String operation,
    Map<String, String> fields,
  ) async {
    if (!RegExp(r'^[a-z]+$').hasMatch(operation) ||
        fields.keys.any((k) => !RegExp(r'^[a-zA-Z]+$').hasMatch(k))) {
      throw DmpNativeFailure('CONFIGURATION');
    }
    if (_process == null) {
      final environment = Map<String, String>.from(Platform.environment)
        ..remove('JAVA_TOOL_OPTIONS')
        ..remove('_JAVA_OPTIONS')
        ..remove('JDK_JAVA_OPTIONS')
        ..remove('CLASSPATH')
        ..remove('DYLD_INSERT_LIBRARIES');
      _process = await Process.start(
        executable,
        arguments,
        environment: environment,
        includeParentEnvironment: false,
      );
      // Compiler/library diagnostics can contain sensitive card details. Discard.
      _errors = _process!.stderr.listen((_) {});
      _lines = StreamIterator(_boundedLines(_process!.stdout));
    }
    final id = '${++_sequence}';
    final frame = [
      id,
      operation,
      ...fields.entries.map(
        (e) => '${e.key}=${base64Encode(utf8.encode(e.value))}',
      ),
    ].join('\t');
    if (frame.length > 24 * 1024 * 1024) {
      throw DmpNativeFailure('CONFIGURATION');
    }
    _process!.stdin.writeln(frame);
    await _process!.stdin.flush();
    if (!await _lines!.moveNext()) throw DmpNativeFailure('NATIVE_EXIT');
    final parts = _lines!.current.split('\t');
    if (parts.length < 2 || parts[0] != id) {
      throw DmpNativeFailure('NATIVE_PROTOCOL');
    }
    if (parts[1] != 'OK') {
      if (parts.length != 2 || !parts[1].startsWith('ERR_')) {
        throw DmpNativeFailure('NATIVE_PROTOCOL');
      }
      throw DmpNativeFailure(parts[1].substring(4));
    }
    final result = <String, String>{};
    for (final part in parts.skip(2)) {
      final split = part.indexOf('=');
      if (split < 1) throw DmpNativeFailure('NATIVE_PROTOCOL');
      final key = part.substring(0, split);
      if (result.containsKey(key)) throw DmpNativeFailure('NATIVE_PROTOCOL');
      result[key] = utf8.decode(base64Decode(part.substring(split + 1)));
    }
    return result;
  }

  static Stream<String> _boundedLines(Stream<List<int>> bytes) async* {
    final pending = <int>[];
    await for (final chunk in bytes) {
      for (final byte in chunk) {
        if (byte == 10) {
          yield utf8.decode(pending);
          pending.clear();
        } else {
          pending.add(byte);
          if (pending.length > 32 * 1024 * 1024) {
            throw const FormatException('frame');
          }
        }
      }
    }
    if (pending.isNotEmpty) throw const FormatException('truncated');
  }

  Future<void> _terminate() async {
    _closed = true;
    final p = _process;
    if (p != null) {
      p.kill(ProcessSignal.sigkill);
      await p.exitCode.timeout(const Duration(seconds: 5));
    }
    await _lines?.cancel();
    await _errors?.cancel();
  }

  @override
  Future<void> close() async {
    if (_closed) {
      await _terminate();
      return;
    }
    try {
      if (_process != null) await call('close', {});
    } catch (_) {
      // Worker exit, not the acknowledgement, is the resource boundary.
    } finally {
      await _terminate();
    }
  }
}
