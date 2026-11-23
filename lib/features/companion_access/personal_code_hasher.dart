import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';

class PersonalCodeVerifier {
  const PersonalCodeVerifier({
    required this.algorithm,
    required this.iterations,
    required this.salt,
    required this.verifier,
  });
  final String algorithm, salt, verifier;
  final int iterations;

  factory PersonalCodeVerifier.fromMap(Map<String, Object?> row) =>
      PersonalCodeVerifier(
        algorithm: row['algorithm'] as String,
        iterations: row['iterations'] as int,
        salt: row['salt'] as String,
        verifier: row['verifier'] as String,
      );
  Map<String, Object?> toMap() => {
    'algorithm': algorithm,
    'iterations': iterations,
    'salt': salt,
    'verifier': verifier,
  };
}

abstract interface class PersonalCodeHasher {
  Future<PersonalCodeVerifier> create(String code);
  Future<bool> verify(String code, PersonalCodeVerifier stored);
}

/// CPU-heavy work runs outside the UI isolate. A short PIN is still weak
/// against offline guessing; this is a verifier, not database encryption.
class Pbkdf2PersonalCodeHasher implements PersonalCodeHasher {
  static const algorithm = 'pbkdf2-sha256-v1';
  static const iterations = 600000;

  @override
  Future<PersonalCodeVerifier> create(String code) async {
    final random = Random.secure();
    final salt = base64Encode(
      List<int>.generate(16, (_) => random.nextInt(256)),
    );
    final verifier = await compute(_derive, (code, salt, iterations));
    return PersonalCodeVerifier(
      algorithm: algorithm,
      iterations: iterations,
      salt: salt,
      verifier: verifier,
    );
  }

  @override
  Future<bool> verify(String code, PersonalCodeVerifier stored) async {
    if (stored.algorithm != algorithm ||
        stored.iterations < 100000 ||
        stored.iterations > 2000000) {
      throw const FormatException('Vérificateur de code non pris en charge.');
    }
    final salt = base64Decode(stored.salt);
    final expected = base64Decode(stored.verifier);
    if (salt.length != 16 || expected.length != 32) {
      throw const FormatException('Vérificateur de code invalide.');
    }
    final actual = base64Decode(
      await compute(_derive, (code, stored.salt, stored.iterations)),
    );
    var difference = 0;
    for (var i = 0; i < expected.length; i++) {
      difference |= expected[i] ^ actual[i];
    }
    return difference == 0;
  }
}

String _derive((String, String, int) request) {
  final (code, salt, iterations) = request;
  final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
    ..init(Pbkdf2Parameters(base64Decode(salt), iterations, 32));
  final input = Uint8List.fromList(utf8.encode(code));
  try {
    return base64Encode(derivator.process(input));
  } finally {
    input.fillRange(0, input.length, 0);
    derivator.reset();
  }
}
