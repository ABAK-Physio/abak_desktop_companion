import 'package:flutter/services.dart';

import 'patient_fr_insi_ps_signer.dart';

class PatientFrInsiPsMethodChannelSigner
    implements PatientFrInsiPsSigner {
  const PatientFrInsiPsMethodChannelSigner();

  static const MethodChannel _channel =
  MethodChannel('abak_dmp_fr');

  @override
  Future<String> sign({
    required String canonicalSignedInfo,
  }) async {
    final result = await _channel.invokeMethod<String>(
      'signInsiPsAssertion',
      {
        'canonicalSignedInfo': canonicalSignedInfo,
      },
    );

    if (result == null || result.trim().isEmpty) {
      throw StateError(
        'Signature CPS absente',
      );
    }

    return result.trim();
  }
}