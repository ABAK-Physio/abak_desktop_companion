import 'dart:convert';
import 'dart:io';

import '../../generated/l10n.dart';

import 'speech_to_text_provider.dart';

class ExternalSpeechToTextProvider implements SpeechToTextProvider {
  ExternalSpeechToTextProvider({
    required this.executablePath,
    required this.id,
    required this.displayName,
    required this.isLocal,
    required this.requiresInternet,
  });

  final String executablePath;

  @override
  final String id;

  @override
  final String displayName;

  @override
  final bool isLocal;

  @override
  final bool requiresInternet;

  @override
  Future<bool> isAvailable() async {
    final executable = File(executablePath);

    if (!await executable.exists()) {
      return false;
    }

    try {
      final result = await Process.run(
        executablePath,
        ['--status'],
      );

      if (result.exitCode != 0) {
        return false;
      }

      final output = result.stdout.toString().trim();
      if (output.isEmpty) {
        return false;
      }

      final json = jsonDecode(output);

      return json is Map<String, dynamic> && json['ok'] == true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String> transcribeFile(String audioFilePath) async {
    final result = await Process.run(
      executablePath,
      [
        '--transcribe',
        audioFilePath,
      ],
    );

    if (result.exitCode != 0) {
      throw StateError(
        S.current.externalSpeechToTextProvider_failure,
      );
    }

    final output = result.stdout.toString().trim();

    if (output.isEmpty) {
      throw StateError(
        S.current.externalSpeechToTextProvider_empty,
      );
    }

    final json = jsonDecode(output);

    if (json is! Map<String, dynamic>) {
      throw FormatException(
        S.current.externalSpeechToTextProvider_invalid,
      );
    }

    if (json['ok'] != true) {
      final message = json['message']?.toString();

      throw StateError(
        message ?? S.current.externalSpeechToTextProvider_transcription,
      );
    }

    final text = json['text']?.toString();

    if (text == null || text.trim().isEmpty) {
      throw StateError(
        S.current.externalSpeechToTextProvider_noText,
      );
    }

    return text.trim();
  }
}