import 'package:flutter/material.dart';
import 'features/dashboard/home_dashboard_screen.dart';

class AbakDesktopApp extends StatelessWidget {
  const AbakDesktopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ABAK Desktop Companion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const HomeDashboardScreen(),
    );
  }
}