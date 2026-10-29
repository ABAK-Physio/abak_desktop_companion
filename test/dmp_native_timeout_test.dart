import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/bridge.dart';

void main() {
  test(
    'search budget accommodates network, handshake and response without changing mutations',
    () {
      final bridge = DmpProcessBridge(executable: 'unused', arguments: []);
      for (final op in [
        'finddocuments',
        'submissionsearch',
        'search',
        'consultmetadata',
        'visibilitymetadata',
      ]) {
        expect(bridge.timeoutFor(op), const Duration(seconds: 90));
      }
      for (final op in [
        'open',
        'td',
        'deposit',
        'depublish',
        'visibilityupdate',
        'authorization',
      ]) {
        expect(bridge.timeoutFor(op), const Duration(seconds: 45));
      }
    },
  );
  test('each timeout stage has a distinct fixed French diagnostic', () {
    const codes = [
      'TCP_CONNECT_TIMEOUT',
      'TLS_HANDSHAKE_TIMEOUT',
      'HTTP_STATUS_TIMEOUT',
      'HTTP_HEADERS_TIMEOUT',
      'HTTP_BODY_TIMEOUT',
    ];
    final messages = codes.map(DmpNativeFailure.messageFor).toSet();
    expect(messages.length, codes.length);
    for (final message in messages) {
      expect(message.toLowerCase(), contains('aucune relance automatique'));
    }
  });
}
