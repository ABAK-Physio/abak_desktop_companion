import 'dart:async';

import 'package:flutter/material.dart';
import '../../generated/l10n.dart';

import 'speech_recording_service.dart';
import 'speech_to_text_provider.dart';
import 'speech_to_text_provider_registry.dart';
import 'package:url_launcher/url_launcher.dart';

class SpeechDictationButton extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const SpeechDictationButton({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  @override
  State<SpeechDictationButton> createState() =>
      _SpeechDictationButtonState();
}

class _SpeechDictationButtonState extends State<SpeechDictationButton> {
  final SpeechRecordingService _recordingService =
  SpeechRecordingService();

  SpeechToTextProvider? _provider;

  bool _isRecording = false;
  bool _isTranscribing = false;

  @override
  void initState() {
    super.initState();
    _loadProvider();
  }

  Future<void> _loadProvider() async {
    final provider =
    await SpeechToTextProviderRegistry.firstAvailableProvider();

    if (!mounted) {
      return;
    }

    setState(() {
      _provider = provider;
    });
  }

  Future<void> _toggleDictation() async {
    if (_provider == null) {
      final provider =
      await SpeechToTextProviderRegistry.firstAvailableProvider();

      if (!mounted) {
        return;
      }

      if (provider == null) {
        await _showAddonNotInstalledDialog();
        return;
      }

      setState(() {
        _provider = provider;
      });
    }

    if (_isRecording) {
      await _stopAndTranscribe();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      await _recordingService.start();

      if (!mounted) {
        return;
      }

      setState(() {
        _isRecording = true;
      });
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _stopAndTranscribe() async {
    final provider = _provider;

    if (provider == null) {
      return;
    }

    setState(() {
      _isRecording = false;
      _isTranscribing = true;
    });

    try {
      final audioPath = await _recordingService.stop();

      if (!mounted) {
        return;
      }

      if (audioPath == null) {
        throw StateError(
          S.of(context).speechDictationButton_audio,
        );
      }

      final text = await provider.transcribeFile(audioPath);

      if (!mounted) {
        return;
      }

      _insertText(text);
    } catch (error) {
      if (mounted) {
        _showError(error);
      }
    } finally {
      await _recordingService.deleteTemporaryAudio();

      if (mounted) {
        setState(() {
          _isTranscribing = false;
        });
      }
    }
  }

  Future<void> _showAddonNotInstalledDialog() async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        final s = S.of(context);

        return AlertDialog(
          title: Text(s.speechDictationButton_title),
          content: Text(
            s.speechDictationButton_information,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(s.speechDictationButton_close),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(context).pop();

                final uri = Uri.parse(
                  'https://abak.care/dictee-vocale/',
                );

                await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
              },
              child: Text(s.speechDictationButton_download),
            ),
          ],
        );
      },
    );
  }

  void _insertText(String text) {
    final controller = widget.controller;
    final selection = controller.selection;

    final start = selection.isValid
        ? selection.start
        : controller.text.length;

    final end = selection.isValid
        ? selection.end
        : controller.text.length;

    final prefix = controller.text.substring(0, start);
    final suffix = controller.text.substring(end);

    final needsSpace =
        prefix.isNotEmpty &&
            !RegExp(r'\s$').hasMatch(prefix);

    final insertedText = needsSpace ? ' $text' : text;

    final newText = '$prefix$insertedText$suffix';
    final cursorPosition =
        prefix.length + insertedText.length;

    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: cursorPosition,
      ),
    );

    widget.focusNode.requestFocus();
  }

  void _showError(Object error) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          S.of(context).speechDictationButton_failure(error),
        ),
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_recordingService.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    if (_isTranscribing) {
      return const SizedBox(
        width: 48,
        height: 48,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      );
    }

    return IconButton(
      onPressed: _toggleDictation,
      tooltip: _isRecording
          ? s.speechDictationButton_stop
          : s.speechDictationButton_dictate,
      icon: Icon(
        _isRecording
            ? Icons.stop_circle_outlined
            : Icons.mic_none,
      ),
    );
  }
}
