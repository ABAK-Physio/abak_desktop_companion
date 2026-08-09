import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
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