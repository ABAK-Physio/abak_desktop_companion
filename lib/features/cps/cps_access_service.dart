import 'package:flutter/services.dart';
import 'cps_profile.dart';
import 'cps_operation_lease.dart';

class CpsAccessService {
  const CpsAccessService();
  static const _channel = MethodChannel('abak_dmp_fr');

  /// One user-initiated attempt. The PIN is never cached or logged.
  Future<CpsProfile> read(String pin, {CpsOperationLease? lease}) async =>
      _profile(await _request(pin, lease: lease));

  Future<Map<String, dynamic>> testSignature(
    String pin,
    String expectedId,
  ) async {
    if (expectedId.isEmpty) {
      throw const FormatException('Relisez la CPS avant le test');
    }
    final result = await _request(pin, expectedId: expectedId);
    if (_profile(result).nationalId != expectedId ||
        result['nationalId'] != expectedId ||
        result['verified'] != true ||
        result['tamperedMessageRejected'] != true ||
        result['certificates'] is! List ||
        (result['certificates'] as List).length != 2) {
      throw const FormatException(
        'Résultat de signature incomplet ou identité différente',
      );
    }
    return result;
  }

  /// Public material for an explicit business signing action, without a
  /// diagnostic signature or network connection. Never called by a status read.
  Future<Map<String, dynamic>> prepareDmpLotLocal(
    String pin,
    String expectedId, {
    required CpsOperationLease lease,
  }) async {
    if (expectedId.isEmpty) throw const FormatException('Signataire absent');
    return _request(
      pin,
      expectedId: expectedId,
      lease: lease,
      prepareSigning: true,
    );
  }

  CpsProfile profileFromResult(Map<String, dynamic> result) => _profile(result);

  Future<Map<String, dynamic>> signDmpLotLocal(
    String pin,
    String expectedId,
    String signedInfo,
    String certificateBase64, {
    CpsOperationLease? lease,
  }) async {
    if (expectedId.isEmpty || signedInfo.isEmpty || certificateBase64.isEmpty) {
      throw const FormatException('Préparation du lot incomplète');
    }
    return _request(
      pin,
      expectedId: expectedId,
      signedInfo: signedInfo,
      certificateBase64: certificateBase64,
      lease: lease,
    );
  }

  Future<Map<String, dynamic>> _request(
    String pin, {
    CpsOperationLease? lease,
    String? expectedId,
    String? signedInfo,
    String? certificateBase64,
    bool prepareSigning = false,
  }) async {
    final owned = lease ?? await CpsOperationLease.acquireAvailable();
    if (!owned.active) throw StateError('Session CPS non disponible.');
    try {
      return await _nativeRequest(
        pin,
        expectedId: expectedId,
        signedInfo: signedInfo,
        certificateBase64: certificateBase64,
        prepareSigning: prepareSigning,
      );
    } finally {
      if (lease == null) owned.release();
    }
  }

  Future<Map<String, dynamic>> _nativeRequest(
    String pin, {
    String? expectedId,
    String? signedInfo,
    String? certificateBase64,
    bool prepareSigning = false,
  }) async {
    if (!RegExp(r'^[0-9]{1,16}$').hasMatch(pin)) {
      throw const FormatException('Saisissez le PIN numérique de votre CPS');
    }
    final result = await _channel.invokeMapMethod<String, dynamic>(
      prepareSigning
          ? 'prepareDmpLotLocal'
          : signedInfo != null
          ? 'signDmpLotLocal'
          : expectedId == null
          ? 'readCpsProfile'
          : 'testCpsSignature',
      {
        'pin': pin,
        'expectedNationalId': ?expectedId,
        'signedInfo': ?signedInfo,
        'certificateBase64': ?certificateBase64,
      },
    );
    if (result == null || result['success'] != true) {
      final step = result?['step'] as String?;
      final code = result?['loginReturnCode'] ?? result?['returnCode'];
      var message = switch (code) {
        0xa0 => 'PIN incorrect. Vérifiez-le avant toute nouvelle tentative.',
        0xa1 || 0xa2 => 'Le format du PIN est refusé par la carte.',
        0xa4 => 'PIN bloqué. La carte doit être débloquée avant de continuer.',
        0xa3 => 'PIN expiré. Mettez à jour la carte avant de continuer.',
        0x100 =>
          'Une authentification CPS est déjà active. Fermez les autres outils CPS avant de relancer la lecture.',
        0x191 =>
          'La Cryptolib est déjà utilisée. Terminez l’opération en cours.',
        0xe0 => 'La Cryptolib ne détecte plus la CPS dans le lecteur.',
        0x30 || 0x32 =>
          'La communication avec la carte ou le lecteur a été interrompue.',
        _ => switch (step) {
          'dlopen' => 'ABAK ne peut pas charger la Cryptolib CPS.',
          'dlsym' =>
            'La Cryptolib CPS ne fournit pas toutes les fonctions nécessaires.',
          'C_Initialize' => 'La Cryptolib CPS ne peut pas démarrer.',
          'C_GetSlotList' || 'C_GetSlotList(ids)' =>
            result?['tokenSlotCount'] == 0
                ? 'La Cryptolib ne détecte aucune CPS. Vérifiez son insertion et le lecteur.'
                : 'La sélection de la CPS a échoué. Ne laissez qu’une CPS insérée.',
          'C_OpenSession' => 'La CPS est détectée mais son ouverture a échoué.',
          'C_Login' =>
            'L’authentification CPS a échoué. Le code reçu ne permet pas de conclure que le PIN est incorrect.',
          'C_ReadObject' ||
          'C_FindObjectsInit' ||
          'C_FindObjects' ||
          'C_FindObjectsFinal' ||
          'C_GetAttributeValue(size)' ||
          'C_GetAttributeValue' =>
            'L’authentification a réussi, mais la lecture des données CPS a échoué.',
          _ => 'Le service CPS a retourné une réponse inattendue.',
        },
      };
      if (expectedId != null &&
          const {
            'identity',
            'certificates',
            'keyBinding',
            'C_SignInit',
            'C_Sign(size)',
            'C_Sign',
            'verification',
          }.contains(step)) {
        message = result?['error'] as String? ?? 'Test de signature impossible';
      }
      // Only technical metadata: never expose the PIN or card contents.
      final diagnostic = <String>[
        if (step != null) 'étape : $step',
        if (step == 'dlopen' && result?['error'] is String)
          'macOS : ${result!['error']}',
        if (code is int)
          'code : 0x${code.toRadixString(16).padLeft(8, '0').toUpperCase()}',
        if (result?['objectLabel'] is String)
          'objet : ${result!['objectLabel']}',
      ];
      throw PlatformException(
        code: 'CPS_READ_FAILED',
        details: {'nativeReturnCode': code, 'nativeStep': step},
        message: diagnostic.isEmpty
            ? message
            : '$message\nDiagnostic : ${diagnostic.join(' · ')}',
      );
    }
    return result;
  }

  CpsProfile _profile(Map<String, dynamic> result) {
    final raw = result['objects'];
    if (raw is! Map) throw const FormatException('Réponse CPS invalide');
    final objects = <String, List<int>>{};
    for (final entry in raw.entries) {
      if (entry.key is! String || entry.value is! List) {
        throw const FormatException('Objet CPS invalide');
      }
      objects[entry.key as String] = (entry.value as List).cast<int>();
    }
    return CpsProfile.fromObjects(objects);
  }
}
