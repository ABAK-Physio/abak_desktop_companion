import 'dart:convert';
import 'dart:typed_data';

/// Windows IPC preparation only. This contract never authorizes execution.
/// macOS XPC evidence must continue to use the existing macOS validation.
abstract final class WindowsDocumentControlsContract {
  static const protocol = 1;
  static const contract = 'ABAK-WINDOWS-CONTROLS-1';
  static const pipeName = r'\\.\pipe\ABAK.DocumentControls.v1';
  static const unavailableCode = 'WINDOWS_ISOLATION_UNAVAILABLE';
  static const maxMetadataBytes = 64 * 1024;
  static const maxInputBytes = 64 * 1024 * 1024;
  static const maxOutputBytes = 12 * 1024 * 1024;
  static const prefixBytes = 12;
  static const operations = {'pdfa', 'version', 'cda'};
  static const isolationChecks = {
    'qualified',
    'serviceIdentityVerified',
    'processIsolationVerified',
    'jobObjectVerified',
    'networkDeniedVerified',
    'filesystemRestrictedVerified',
  };
  static final _uuid = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  );
  static final _digest = RegExp(r'^[0-9a-f]{64}$');
  static bool _validUuid(String value) =>
      value.length == 36 && _uuid.hasMatch(value);

  static Map<String, Object?> request({
    required String requestId,
    required String operation,
    required int timeoutMs,
    int inputSize = 0,
    String inputSha256 = '',
  }) {
    if (!operations.contains(operation)) {
      throw const FormatException('INVALID_OPERATION');
    }
    if (!_validUuid(requestId)) {
      throw const FormatException('INVALID_REQUEST_ID');
    }
    final maximum = operation == 'version' ? 10000 : 240000;
    if (timeoutMs <= 0 || timeoutMs > maximum) {
      throw const FormatException('INVALID_TIMEOUT');
    }
    if (operation == 'version') {
      if (inputSize != 0 || inputSha256.isNotEmpty) {
        throw const FormatException('INVALID_INPUT');
      }
    } else if (inputSize <= 0 ||
        inputSize > maxInputBytes ||
        inputSha256.length != 64 ||
        !_digest.hasMatch(inputSha256)) {
      throw const FormatException('INVALID_INPUT');
    }
    return Map.unmodifiable({
      'protocol': protocol,
      'contract': contract,
      'operation': operation,
      'requestId': requestId,
      'timeoutMs': timeoutMs,
      'input': operation == 'version'
          ? null
          : Map<String, Object>.unmodifiable({
              'name': operation == 'pdfa' ? 'document.pdf' : 'document.xml',
              'size': inputSize,
              'sha256': inputSha256,
            }),
    });
  }

  static Map<String, Object?> unavailable({
    required String requestId,
    required String operation,
  }) {
    if (!operations.contains(operation) || !_validUuid(requestId)) {
      throw const FormatException('INVALID_REQUEST');
    }
    return {
      'protocol': protocol,
      'contract': contract,
      'operation': operation,
      'requestId': requestId,
      'executed': false,
      'pid': 0,
      'exitCode': -1,
      'stdoutLength': 0,
      'stderrLength': 0,
      'files': <Object>[],
      'input': null,
      'truncated': false,
      'error': {
        'code': unavailableCode,
        'message': 'Windows document isolation is not qualified.',
      },
      'isolation': {
        'platform': 'windows',
        for (final name in isolationChecks) name: false,
      },
    };
  }

  /// Internal wire representation, distinct from the macOS Flutter map.
  /// The second length prevents allocating a body from unbounded JSON values.
  static Uint8List encodeFrame(
    Map<String, Object?> metadata,
    Uint8List payload, {
    required bool response,
  }) {
    final header = utf8.encode(jsonEncode(metadata));
    final maximum = response ? maxOutputBytes : maxInputBytes;
    if (header.isEmpty ||
        header.length > maxMetadataBytes ||
        payload.length > maximum) {
      throw const FormatException('FRAME_LIMIT_EXCEEDED');
    }
    final result = Uint8List(prefixBytes + header.length + payload.length);
    final data = ByteData.sublistView(result);
    data.setUint32(0, header.length, Endian.little);
    data.setUint64(4, payload.length, Endian.little);
    result.setRange(prefixBytes, prefixBytes + header.length, header);
    result.setRange(prefixBytes + header.length, result.length, payload);
    return result;
  }

  /// Only a refusal can be represented in W1. No successful response can pass.
  static WindowsDocumentControlRefusal decodeRefusal(
    Uint8List frame, {
    required String requestId,
    required String operation,
  }) {
    if (frame.length < prefixBytes) {
      throw const FormatException('INVALID_FRAME');
    }
    final prefix = ByteData.sublistView(frame, 0, prefixBytes);
    final headerSize = prefix.getUint32(0, Endian.little);
    final payloadSize = prefix.getUint64(4, Endian.little);
    if (headerSize == 0 ||
        headerSize > maxMetadataBytes ||
        payloadSize < 0 ||
        payloadSize > maxOutputBytes ||
        frame.length != prefixBytes + headerSize + payloadSize) {
      throw const FormatException('INVALID_FRAME');
    }
    final header = utf8.decode(
      frame.sublist(prefixBytes, prefixBytes + headerSize),
      allowMalformed: false,
    );
    final decoded = jsonDecode(header);
    // Require the producer's compact representation. This also rejects duplicate
    // keys rather than silently using jsonDecode's last value for those keys.
    if (jsonEncode(decoded) != header) {
      throw const FormatException('NON_CANONICAL_METADATA');
    }
    return validateRefusal(
      decoded,
      payloadSize: payloadSize,
      requestId: requestId,
      operation: operation,
    );
  }

  static WindowsDocumentControlRefusal validateRefusal(
    Object? value, {
    required int payloadSize,
    required String requestId,
    required String operation,
  }) {
    if (!operations.contains(operation) || !_validUuid(requestId)) {
      throw const FormatException('INVALID_REQUEST');
    }
    final data = _map(value, {
      'protocol', 'contract', 'operation', 'requestId', 'executed', 'pid',
      'exitCode', 'stdoutLength', 'stderrLength', 'files', 'input',
      'truncated', 'error', 'isolation',
    });
    if (data['protocol'] is! int ||
        data['protocol'] != protocol ||
        data['contract'] != contract ||
        data['operation'] != operation ||
        data['requestId'] != requestId) {
      throw const FormatException('RESPONSE_MISMATCH');
    }
    if (data['executed'] != false || data['truncated'] != false) {
      throw const FormatException(unavailableCode);
    }
    if (payloadSize != 0 ||
        data['pid'] is! int || data['pid'] != 0 ||
        data['exitCode'] is! int || data['exitCode'] != -1 ||
        data['stdoutLength'] is! int || data['stdoutLength'] != 0 ||
        data['stderrLength'] is! int || data['stderrLength'] != 0 ||
        data['files'] is! List || (data['files'] as List).isNotEmpty ||
        data['input'] != null) {
      throw const FormatException('INCONSISTENT_REFUSAL');
    }
    final isolation = _map(data['isolation'], {'platform', ...isolationChecks});
    if (isolation['platform'] != 'windows' ||
        isolationChecks.any((name) => isolation[name] != false)) {
      throw const FormatException('INVALID_WINDOWS_ISOLATION');
    }
    final error = _map(data['error'], {'code', 'message'});
    if (error['code'] != unavailableCode ||
        error['message'] is! String ||
        (error['message'] as String).isEmpty ||
        utf8.encode(error['message'] as String).length > 4096) {
      throw const FormatException('INVALID_REFUSAL_ERROR');
    }
    return WindowsDocumentControlRefusal(
      requestId: requestId,
      operation: operation,
      message: error['message'] as String,
    );
  }

  static Map<String, Object?> _map(Object? value, Set<String> keys) {
    if (value is! Map ||
        value.length != keys.length ||
        value.keys.any((key) => key is! String || !keys.contains(key))) {
      throw const FormatException('INVALID_RESPONSE_SCHEMA');
    }
    return Map<String, Object?>.from(value);
  }
}

final class WindowsDocumentControlRefusal {
  const WindowsDocumentControlRefusal({
    required this.requestId,
    required this.operation,
    required this.message,
  });

  final String requestId;
  final String operation;
  final String message;
  String get code => WindowsDocumentControlsContract.unavailableCode;
}
