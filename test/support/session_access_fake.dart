import 'dart:async';
import 'package:abak_desktop_companion/features/companion_access/companion_access_service.dart';

/// Tests the session lifecycle independently of hashing and SQLite; those
/// implementations are covered by companion_auth_test.dart.
class SessionAccessFake extends CompanionAccessService {
  final codes = <String, String>{'a': '0123', 'b': '1234'};
  int checks = 0, creations = 0;
  Completer<void>? verificationGate;
  @override
  Future<bool> hasPersonalCode(String id) async => codes.containsKey(id);
  @override
  Future<void> createCode(String id, String code) async {
    if (codes.containsKey(id) || !CompanionAccessService.validCode(code)) {
      throw const CompanionAccessException('Création refusée.');
    }
    codes[id] = code;
    creations++;
  }

  @override
  Future<void> verifyCode(String id, String code) async {
    checks++;
    await verificationGate?.future;
    if (codes[id] != code) {
      throw const CompanionAccessException('Code incorrect.');
    }
  }
}
