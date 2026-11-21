import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'patient_insi_exchange.dart';

/// One HTTP attempt, with evidence captured before business interpretation.
/// The caller owns the client and closes it after this operation completes.
class PatientInsiExchangeTransport {
  const PatientInsiExchangeTransport({
    required this.client,
    this.timeout = const Duration(seconds: 45),
  });
  final http.Client client;
  final Duration timeout;

  Future<T> send<T>({
    required String id,
    required http.Request message,
    required T Function(InsiExchange) interpret,
    required Future<void> Function(InsiExchange) retainExchange,
  }) async {
    final requestXml = message.body;
    message.followRedirects = false;
    final watch = Stopwatch()..start();
    String? responseXml;
    int? statusCode;
    String? failure;
    try {
      final stream = await client.send(message).timeout(timeout);
      // Assign metadata here, outside any asynchronous decoding callback.
      statusCode = stream.statusCode;
      final remaining = timeout - watch.elapsed;
      if (remaining <= Duration.zero) {
        throw TimeoutException('Délai INSi dépassé.');
      }
      final bytes = await stream.stream.fold<List<int>>([], (buffer, chunk) {
        if (buffer.length + chunk.length > 2 * 1024 * 1024) {
          throw StateError('Réponse INSi trop volumineuse.');
        }
        buffer.addAll(chunk);
        return buffer;
      }).timeout(remaining);
      responseXml = utf8.decode(bytes);
      if (statusCode != 200 && statusCode != 500) {
        throw StateError('INSi a répondu HTTP $statusCode. La fiche reste inchangée.');
      }
      if (responseXml.contains('<!DOCTYPE') || responseXml.contains('<!ENTITY')) {
        throw StateError('Réponse INSi non prise en charge.');
      }
      // A SOAP fault may throw here; its HTTP status and XML already exist.
      return interpret(InsiExchange(
        id: id, requestXml: requestXml, responseXml: responseXml,
        httpStatus: statusCode, recordedAt: DateTime.now().toUtc(),
      ));
    } catch (e) {
      // Never archive arbitrary exception strings: they can contain credentials.
      failure = e is StateError ? e.message.toString()
        : e is FormatException ? 'Réponse INSi illisible.'
        : 'Échange INSi interrompu (réseau ou délai dépassé).';
      rethrow;
    } finally {
      watch.stop();
      try {
        await retainExchange(InsiExchange(
          id: id, requestXml: requestXml, responseXml: responseXml,
          httpStatus: statusCode, failure: failure, recordedAt: DateTime.now().toUtc(),
        ));
      } catch (_) {
        throw StateError(
          'Échange INSi effectué ou tenté, mais ses preuves n’ont pas pu être conservées. '
          'Ne relancez pas automatiquement la demande.',
        );
      }
    }
  }
}
