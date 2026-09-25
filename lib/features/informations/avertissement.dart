import 'package:flutter/material.dart';

import '../../core/expert/expert_context_info.dart';
import '../../core/expert/expert_info_button.dart';

import '../../generated/l10n.dart';

class AvertissementScreen extends StatelessWidget {
  const AvertissementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          ExpertModeInfoButton(
            info: ExpertContextInfo(
              contextName: s.legalNotice_appBarTitle,
              sourceFile: 'lib/features/informations/avertissement.dart',
              arbPrefix: 'legalNotice',
            ),
          ),
        ],
        title: Text(s.legalNotice_appBarTitle),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.legalNotice_title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              s.legalNotice_content
            ),
          ],
        ),
      ),
    );
  }
}
