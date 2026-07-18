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

class SmartCardVitaleApiResult {
  final bool success;
  final bool dllLoaded;
  final bool hnInitFound;
  final bool hnReadIdentityFound;
  final bool hnFinishFound;
  final int? hnInitReturn;
  final int? hnInitMode;
  final int? hnInitError;
  final String? message;
  final int? windowsError;
  final int hnReadReturn;
  final int hnReadLength;
  final int hnCardState;
  final int hnReadError;
  final int hnReadBufferSize;
  final String? xml;

  const SmartCardVitaleApiResult({
    required this.success,
    required this.dllLoaded,
    required this.hnInitFound,
    required this.hnReadIdentityFound,
    required this.hnFinishFound,
    this.hnInitReturn,
    this.hnInitMode,
    this.hnInitError,
    this.message,
    this.windowsError,
    required this.hnReadReturn,
    required this.hnReadLength,
    required this.hnCardState,
    required this.hnReadError,
    required this.hnReadBufferSize,
    this.xml,
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

  Future<SmartCardVitaleApiResult> checkVitaleApi() async {
    try {
      final raw = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'checkVitaleApi',
      );

      final data = raw ?? const <dynamic, dynamic>{};

      return SmartCardVitaleApiResult(
        success: data['success'] == true,
        dllLoaded: data['dllLoaded'] == true,
        hnInitFound: data['hnInitFound'] == true,
        hnReadIdentityFound: data['hnReadIdentityFound'] == true,
        hnFinishFound: data['hnFinishFound'] == true,

        hnInitReturn: data['hnInitReturn'] is int
            ? data['hnInitReturn'] as int
            : null,

        hnInitMode: data['hnInitMode'] is int
            ? data['hnInitMode'] as int
            : null,

        hnInitError: data['hnInitError'] is int
            ? data['hnInitError'] as int
            : null,

        message: data['message']?.toString(),

        windowsError: data['windowsError'] is int
            ? data['windowsError'] as int
            : null,

        hnReadReturn: data['hnReadReturn'] is int
            ? data['hnReadReturn'] as int
            : 0,

        hnReadLength: data['hnReadLength'] is int
            ? data['hnReadLength'] as int
            : 0,

        hnCardState: data['hnCardState'] is int
            ? data['hnCardState'] as int
            : 0,

        hnReadError: data['hnReadError'] is int
            ? data['hnReadError'] as int
            : 0,
        hnReadBufferSize: data['hnReadBufferSize'] is int
            ? data['hnReadBufferSize'] as int
            : 0,
        xml: data['xml']?.toString(),
      );

    } catch (e) {
      return SmartCardVitaleApiResult(
        success: false,
        dllLoaded: false,
        hnInitFound: false,
        hnReadIdentityFound: false,
        hnFinishFound: false,
        message: e.toString(),
        hnReadReturn: 0,
        hnReadLength: 0,
        hnCardState: 0,
        hnReadError: 0,
        hnReadBufferSize: 0,
      );
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
