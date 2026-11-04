import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/patients/services/document_windows_contract.dart';

const id = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee';
typedef Contract = WindowsDocumentControlsContract;

Map<String, Object?> refusal() => Contract.unavailable(
  requestId: id,
  operation: 'version',
);

void main() {
  test('only the three closed operations and bounded inputs are accepted', () {
    for (final operation in ['pdfa', 'version', 'cda']) {
      final value = Contract.request(
        requestId: id,
        operation: operation,
        timeoutMs: operation == 'version' ? 10000 : 240000,
        inputSize: operation == 'version' ? 0 : 1,
        inputSha256: operation == 'version' ? '' : 'a' * 64,
      );
      expect(value['operation'], operation);
      expect(value.keys, isNot(contains('java')));
    }
    for (final operation in ['', 'PDFa', 'cmd', '../cda']) {
      expect(() => Contract.request(requestId: id, operation: operation,
        timeoutMs: 10000), throwsFormatException);
    }
    expect(() => Contract.request(requestId: id, operation: 'version',
      timeoutMs: 10001), throwsFormatException);
    expect(() => Contract.request(requestId: id, operation: 'pdfa',
      timeoutMs: 240001, inputSize: 1, inputSha256: 'a' * 64), throwsFormatException);
    expect(() => Contract.request(requestId: id, operation: 'cda',
      timeoutMs: 1, inputSize: Contract.maxInputBytes + 1,
      inputSha256: 'a' * 64), throwsFormatException);
    expect(() => Contract.request(requestId: id, operation: 'version',
      timeoutMs: 1, inputSize: 1), throwsFormatException);
    expect(() => Contract.request(requestId: '$id\n', operation: 'version',
      timeoutMs: 1), throwsFormatException);
    expect(() => Contract.request(requestId: id, operation: 'cda',
      timeoutMs: 1, inputSize: 1, inputSha256: '${'a' * 64}\n'),
      throwsFormatException);
  });

  test('native C++ fixture decodes to a refusal, never to a process result', () {
    final frame = File('test/fixtures/windows_controls_w1_refusal.bin').readAsBytesSync();
    final result = Contract.decodeRefusal(frame, requestId: id, operation: 'version');
    expect(result.code, Contract.unavailableCode);
    expect(result.operation, 'version');
    final own = Contract.encodeFrame(refusal(), Uint8List(0), response: true);
    expect(own, orderedEquals(frame));
  });

  test('all truncated frames, appended data and hostile lengths are rejected', () {
    final bytes = Contract.encodeFrame(refusal(), Uint8List(0), response: true);
    for (var cut = 0; cut < bytes.length; cut++) {
      expect(() => Contract.decodeRefusal(Uint8List.sublistView(bytes, 0, cut),
        requestId: id, operation: 'version'), throwsFormatException);
    }
    final appended = Uint8List.fromList([...bytes, 0]);
    expect(() => Contract.decodeRefusal(appended,
      requestId: id, operation: 'version'), throwsFormatException);
    final huge = Uint8List(12);
    ByteData.sublistView(huge).setUint32(0, 0xffffffff, Endian.little);
    expect(() => Contract.decodeRefusal(huge,
      requestId: id, operation: 'version'), throwsFormatException);
    ByteData.sublistView(huge).setUint32(0, 1, Endian.little);
    huge.fillRange(4, 12, 255);
    expect(() => Contract.decodeRefusal(huge,
      requestId: id, operation: 'version'), throwsFormatException);
    ByteData.sublistView(huge).setUint32(0, 1, Endian.little);
    ByteData.sublistView(huge).setUint64(4, Contract.maxOutputBytes + 1, Endian.little);
    expect(() => Contract.decodeRefusal(huge,
      requestId: id, operation: 'version'), throwsFormatException);
  });

  test('wrong correlation, malformed types and macOS evidence are rejected', () {
    for (final change in <String, Object?>{
      'protocol': 1.0, 'contract': 'ABAK-MACOS-CONTROLS-1',
      'operation': 'pdfa', 'requestId': 'ffffffff-bbbb-cccc-dddd-eeeeeeeeeeee',
      'pid': 12, 'exitCode': 0, 'stdoutLength': -1,
      'truncated': true, 'files': ['xsd.xml'],
      'isolation': {'serviceIdentifier': 'fr.abakphysio.documentcontrols'},
      'error': null,
    }.entries) {
      final data = refusal()..[change.key] = change.value;
      expect(() => Contract.validateRefusal(data, payloadSize: 0,
        requestId: id, operation: 'version'), throwsFormatException);
    }
    final unknown = refusal()..['arguments'] = ['-version'];
    expect(() => Contract.validateRefusal(unknown, payloadSize: 0,
      requestId: id, operation: 'version'), throwsFormatException);
  });

  test('a forged successful or qualified response cannot enable W1', () {
    final data = refusal()..['executed'] = true;
    (data['isolation'] as Map)['qualified'] = true;
    expect(() => Contract.validateRefusal(data, payloadSize: 0,
      requestId: id, operation: 'version'), throwsFormatException);
    for (final name in Contract.isolationChecks) {
      final data = refusal();
      (data['isolation'] as Map)[name] = true;
      expect(() => Contract.validateRefusal(data, payloadSize: 0,
        requestId: id, operation: 'version'), throwsFormatException);
    }
  });

  test('duplicate JSON keys and malformed UTF-8 are rejected', () {
    final normal = jsonEncode(refusal());
    final duplicate = normal.replaceFirst('{', '{"protocol":2,');
    final metadata = utf8.encode(duplicate);
    final frame = Uint8List(12 + metadata.length);
    ByteData.sublistView(frame).setUint32(0, metadata.length, Endian.little);
    frame.setRange(12, frame.length, metadata);
    expect(() => Contract.decodeRefusal(frame,
      requestId: id, operation: 'version'), throwsFormatException);
    frame[12] = 0xff;
    expect(() => Contract.decodeRefusal(frame,
      requestId: id, operation: 'version'), throwsFormatException);
  });
}
