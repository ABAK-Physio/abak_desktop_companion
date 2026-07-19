import 'package:flutter/services.dart';

class SmartCardReaderService {
  const SmartCardReaderService();

  static const MethodChannel _channel = MethodChannel('abak.smart_card');

  Future<List<String>> getAvailableReaders() async {
    try {
      final readers = await _channel.invokeMethod<List<dynamic>>(
        'getAvailableReaders',
      );

      return (readers ?? const <dynamic>[])
          .map((reader) => reader.toString())
          .toList();
    } catch (_) {
      return const <String>[];
    }
  }
}