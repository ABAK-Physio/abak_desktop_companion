import 'package:flutter/services.dart';

import '../models/vitale_identity.dart';
import 'vitale_xml_parser.dart';

class VitaleIdentityService {
  const VitaleIdentityService();

  static const MethodChannel _channel = MethodChannel(
    'abak.smart_card',
  );

  Future<Map<String, dynamic>?> _invokeNativeRead() async {
    final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'readVitaleIdentity',
    );

    if (result == null) {
      return null;
    }

    return Map<String, dynamic>.from(result);
  }

  Map<String, dynamic>? _extractIdentityMap(
      Map<String, dynamic> result,
      ) {
    /*
     * Premier format possible :
     *
     * {
     *   "success": true,
     *   "identity": {
     *     "lastName": "...",
     *     ...
     *   }
     * }
     */
    final identityRaw = result['identity'];

    if (identityRaw is Map) {
      return Map<String, dynamic>.from(identityRaw);
    }

    /*
     * Deuxième format :
     *
     * {
     *   "success": true,
     *   "xml": "<?xml ... ?>"
     * }
     *
     * Le XML est décodé par le parseur Dart commun.
     */
    final xml = result['xml']?.toString();

    if (xml != null && xml.trim().isNotEmpty) {
      final identity = VitaleXmlParser.parse(xml);

      if (!identity.hasUsableIdentity) {
        return null;
      }

      return {
        ...identity.toMap(),
        'source': result['source']?.toString() ?? 'api_lec',
      };
    }

    /*
     * Troisième format, actuellement renvoyé par le code natif macOS :
     *
     * {
     *   "success": true,
     *   "lastName": "...",
     *   "firstName": "...",
     *   "birthDate": "...",
     *   "sexCode": "...",
     *   "nir": "...",
     *   "source": "api_lec"
     * }
     */
    final hasIdentityData =
        result['lastName'] != null ||
            result['firstName'] != null ||
            result['birthDate'] != null ||
            result['nir'] != null;

    if (!hasIdentityData) {
      return null;
    }

    return {
      'lastName': result['lastName'],
      'firstName': result['firstName'],
      'birthDate': result['birthDate'],
      'sexCode': result['sexCode'],
      'nir': result['nir'],
      'source': result['source'] ?? 'api_lec',
    };
  }

  Future<VitaleIdentity?> readVitaleIdentity() async {
    try {
      final result = await _invokeNativeRead();

      if (result == null || result['success'] != true) {
        return null;
      }

      final identityMap = _extractIdentityMap(result);

      if (identityMap == null) {
        return null;
      }

      return VitaleIdentity.fromMap(identityMap);
    } on PlatformException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> readVitaleIdentityDiagnostic() async {
    try {
      final result = await _invokeNativeRead();

      if (result == null) {
        return {
          'success': false,
          'error': 'Réponse native vide',
        };
      }

      final identityMap = _extractIdentityMap(result);

      if (identityMap != null) {
        /*
         * VitaleIdentityScreen attend cette clé pour construire
         * l’objet VitaleIdentity retourné au formulaire patient.
         */
        result['identity'] = identityMap;
      }

      return result;
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