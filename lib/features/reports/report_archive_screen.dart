import 'package:flutter/material.dart';

import '../../core/expert/expert_context_info.dart';
import '../../core/expert/expert_info_button.dart';

import '../../generated/l10n.dart';

class ReportArchiveScreen extends StatelessWidget {
  const ReportArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.reportArchive_title),
        actions: [
          ExpertModeInfoButton(
            info: ExpertContextInfo(
              contextName: s.reportArchive_title,
              sourceFile: 'lib/features/reports/report_archive_screen.dart',
              arbPrefix: 'reportArchive',
            ),
          ),
        ],
      ),
      body: Center(
        child: Text(
          s.reportArchive_title,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
