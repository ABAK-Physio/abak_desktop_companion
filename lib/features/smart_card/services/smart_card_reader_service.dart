import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class SmartCardReaderService {
  const SmartCardReaderService();

  static const MethodChannel _channel = MethodChannel('abak.smart_card');

  Future<List<String>> getAvailableReaders() async {
    try {
      final readers = await _channel.invokeMethod<List<dynamic>>(
        'getAvailableReaders',
      );

      debugPrint(
        'getAvailableReaders : retour brut = $readers',
      );

      final result = (readers ?? const <dynamic>[])
          .map((reader) => reader.toString())
          .toList();

      debugPrint(
        'getAvailableReaders : lecteurs = $result',
      );

      return result;
    } on PlatformException catch (error, stackTrace) {
      debugPrint(
        'getAvailableReaders : PlatformException '
            'code=${error.code}, '
            'message=${error.message}, '
            'details=${error.details}',
      );
      debugPrintStack(stackTrace: stackTrace);

      return const <String>[];
    } catch (error, stackTrace) {
      debugPrint(
        'getAvailableReaders : erreur inattendue = $error',
      );
      debugPrintStack(stackTrace: stackTrace);

      return const <String>[];
    }
  }
}