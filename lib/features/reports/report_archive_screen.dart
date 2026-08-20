import 'package:flutter/material.dart';

import '../../generated/l10n.dart';

class ReportArchiveScreen extends StatelessWidget {
  const ReportArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Center(
      child: Text(
        s.reportArchive_title,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}
