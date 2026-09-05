import 'dart:io';

import '../../generated/l10n.dart';

import 'external_speech_to_text_provider.dart';

class AbakWhisperSpeechProvider extends ExternalSpeechToTextProvider {
  AbakWhisperSpeechProvider()
      : super(
    executablePath: _executablePath,
    id: 'abak_whisper',
    displayName: '',
    isLocal: true,
    requiresInternet: false,
  );

  @override
  String get displayName => S.current.abakWhisperSpeechProvider_name;

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