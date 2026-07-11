import 'package:flutter/services.dart';

class SmartCardDiagnosticResult {
  final bool readerDetected;
  final bool cardDetected;
  final String? readerName;
  final String? atr;
  final String rawOutput;
  final String? error;

  const SmartCardDiagnosticResult({
    required this.readerDetected,
    required this.cardDetected,
    required this.rawOutput,
    this.readerName,
    this.atr,
    this.error,
  });
}

class SmartCardDiagnosticService {
  const SmartCardDiagnosticService();

  static const MethodChannel _channel = MethodChannel('abak.smart_card');

  Future<SmartCardDiagnosticResult> readStatus() async {
    try {
      final raw = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'getStatus',
      );

      final data = raw ?? const <dynamic, dynamic>{};

      final readerDetected = data['readerDetected'] == true;
      final cardDetected = data['cardDetected'] == true;
      final readerName = data['readerName']?.toString();
      final atr = data['atr']?.toString();
      final error = data['error']?.toString();

      return SmartCardDiagnosticResult(
        readerDetected: readerDetected,
        cardDetected: cardDetected,
        readerName: readerName,
        atr: atr,
        error: error,
        rawOutput: data.toString(),
      );
    } catch (e, stackTrace) {
      return SmartCardDiagnosticResult(
        readerDetected: false,
        cardDetected: false,
        rawOutput:
            '''
Exception:
$e

StackTrace:
$stackTrace
''',
        error: e.toString(),
      );
    }
  }

  Future<SmartCardApduResult> testApdu() async {
    try {
      final raw = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'testApdu',
      );

      final data = raw ?? const <dynamic, dynamic>{};

      return SmartCardApduResult(
        success: data['success'] == true,
        command: data['command']?.toString(),
        response: data['response']?.toString(),
        readerName: data['readerName']?.toString(),
        error: data['error']?.toString(),
        protocol: data['protocol'] is int ? data['protocol'] as int : null,
      );
    } catch (e) {
      return SmartCardApduResult(success: false, error: e.toString());
    }
  }
}

class SmartCardApduResult {
  final bool success;
  final String? command;
  final String? response;
  final String? readerName;
  final int? protocol;
  final String? error;

  const SmartCardApduResult({
    required this.success,
    this.command,
    this.response,
    this.readerName,
    this.protocol,
    this.error,
  });
}
