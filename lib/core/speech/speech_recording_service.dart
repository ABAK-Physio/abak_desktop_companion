import 'dart:io';

import 'package:record/record.dart';

import '../../generated/l10n.dart';

class SpeechRecordingService {
  final AudioRecorder _recorder = AudioRecorder();

  String? _currentFilePath;

  Future<String> start() async {
    final hasPermission = await _recorder.hasPermission();

    if (!hasPermission) {
      throw StateError(
        S.current.speechRecordingService_permission,
      );
    }

    final tempDirectory = await Directory.systemTemp.createTemp(
      'abak_speech_recording_',
    );

    final filePath = '${tempDirectory.path}/dictation.wav';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: filePath,
    );

    _currentFilePath = filePath;

    return filePath;
  }

  Future<String?> stop() async {
    final path = await _recorder.stop();

    if (path != null) {
      _currentFilePath = path;
    }

    return path;
  }

  Future<void> cancel() async {
    await _recorder.cancel();
    await deleteTemporaryAudio();
  }

  Future<void> deleteTemporaryAudio() async {
    final path = _currentFilePath;

    if (path == null) {
      return;
    }

    final file = File(path);
    final directory = file.parent;

    if (await file.exists()) {
      await file.delete();
    }

    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }

    _currentFilePath = null;
  }

  Future<void> dispose() async {
    await _recorder.dispose();
  }
}
