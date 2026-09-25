import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../settings/application_settings_service.dart';
import 'expert_context_info.dart';
import 'expert_info_dialog.dart';

class ExpertInfoButton extends StatelessWidget {
  final ExpertContextInfo info;

  const ExpertInfoButton({
    super.key,
    required this.info,
  });

  Future<void> _showInfo(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => ExpertInfoDialog(info: info),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: S.of(context).g_technical_informations,
      onPressed: () => _showInfo(context),
      icon: const Icon(Icons.developer_mode_outlined),
    );
  }
}

/// Displays the technical information button only when expert mode is enabled.
class ExpertModeInfoButton extends StatefulWidget {
  final ExpertContextInfo info;

  const ExpertModeInfoButton({super.key, required this.info});

  @override
  State<ExpertModeInfoButton> createState() => _ExpertModeInfoButtonState();
}

class _ExpertModeInfoButtonState extends State<ExpertModeInfoButton> {
  late final Future<bool> _expertModeEnabled;

  @override
  void initState() {
    super.initState();
    _expertModeEnabled =
        const ApplicationSettingsService().isExpertModeEnabled();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _expertModeEnabled,
      builder: (context, snapshot) {
        if (snapshot.data != true) return const SizedBox.shrink();

        return ExpertInfoButton(info: widget.info);
      },
    );
  }
}
