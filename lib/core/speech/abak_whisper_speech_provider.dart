import 'dart:io';

import 'external_speech_to_text_provider.dart';

class AbakWhisperSpeechProvider extends ExternalSpeechToTextProvider {
  AbakWhisperSpeechProvider()
      : super(
    executablePath: _executablePath,
    id: 'abak_whisper',
    displayName: 'ABAK Dictée vocale',
    isLocal: true,
    requiresInternet: false,
  );

  static String get _executablePath {
    if (Platform.isMacOS) {
      return '/Library/Application Support/ABAK/speech/abak-speech';
    }

    if (Platform.isWindows) {
      final programData = Platform.environment['PROGRAMDATA'];

      if (programData != null && programData.isNotEmpty) {
        return '$programData\\ABAK\\speech\\abak-speech.exe';
      }

      return r'C:\ProgramData\ABAK\speech\abak-speech.exe';
    }

    return '';
  }
}