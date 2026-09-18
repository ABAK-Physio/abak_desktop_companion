import 'package:flutter/material.dart';

import '../../core/expert/expert_context_info.dart';
import '../../core/expert/expert_info_button.dart';

import '../../generated/l10n.dart';

class NouveautesScreen extends StatelessWidget {
  const NouveautesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          ExpertModeInfoButton(
            info: ExpertContextInfo(
              contextName: s.information_newTitle,
              sourceFile: 'lib/features/informations/nouveautes.dart',
              arbPrefix: 'information',
            ),
          ),
        ],
        title: Text(s.information_newTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: SizedBox(
              width: double.infinity,
              child: SelectableText(s.information_new),
            ),
          ),
        ),
      ),
    );
  }
}
