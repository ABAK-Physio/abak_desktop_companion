import 'package:flutter/material.dart';

import '../../generated/l10n.dart';

class AvertissementScreen extends StatelessWidget {
  const AvertissementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.legalNotice_appBarTitle)),
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
