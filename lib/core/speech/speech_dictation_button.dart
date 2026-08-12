import 'dart:async';

import 'package:flutter/material.dart';

import 'speech_recording_service.dart';
import 'speech_to_text_provider.dart';
import 'speech_to_text_provider_registry.dart';

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

      if (audioPath == null) {
        throw StateError(
          'Aucun enregistrement audio disponible.',
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
          'La dictée vocale a échoué : $error',
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
    // Aucun add-on installé : aucun bouton affiché.
    if (_provider == null) {
      return const SizedBox.shrink();
    }

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
          ? 'Arrêter la dictée'
          : 'Dicter',
      icon: Icon(
        _isRecording
            ? Icons.stop_circle_outlined
            : Icons.mic_none,
      ),
    );
  }
}