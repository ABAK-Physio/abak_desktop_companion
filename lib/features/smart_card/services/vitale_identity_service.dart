import 'package:flutter/services.dart';

import '../models/vitale_identity.dart';

class VitaleIdentityService {
  const VitaleIdentityService();

  static const MethodChannel _channel = MethodChannel('abak.smart_card');

  Future<VitaleIdentity?> readVitaleIdentity() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'readVitaleIdentity',
      );

      if (result == null) {
        return null;
      }

      final success = result['success'] == true;

      if (!success) {
        return null;
      }

      final identityRaw = result['identity'];

      if (identityRaw is! Map) {
        return null;
      }

      return VitaleIdentity.fromMap(identityRaw);
    } on PlatformException {
      return null;
    }
  }

  Future<Map<String, dynamic>> readVitaleIdentityDiagnostic() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'readVitaleIdentity',
      );

      if (result == null) {
        return {
          'success': false,
          'error': 'Réponse native vide',
        };
      }

      return Map<String, dynamic>.from(result);
    } on PlatformException catch (error) {
      return {
        'success': false,
        'error': error.message ?? error.code,
      };
    } catch (error) {
      return {
        'success': false,
        'error': error.toString(),
      };
    }
  }
}