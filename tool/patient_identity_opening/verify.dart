// One user-authorized diagnostic: open the real identity form from the real
// patient detail screen. Synthetic local data only; no validation or card call.
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:abak_desktop_companion/features/patients/data/patient_repository.dart';
import 'package:abak_desktop_companion/features/patients/patient_detail_screen.dart';
import 'package:abak_desktop_companion/features/patients/screens/patient_qualification_screen.dart';
import 'package:abak_desktop_companion/generated/l10n.dart';

class _Paths extends PathProviderPlatform {
  final String root;
  _Paths(this.root);
  @override
  Future<String?> getApplicationSupportPath() async => '$root/support';
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final output = Directory(Platform.environment['IDENTITY_OPENING_OUTPUT']!);
  final root = await output.createTemp('synthetic-');
  PathProviderPlatform.instance = _Paths(root.path);
  // This standalone diagnostic must never read the user's preferences.
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({});
  final errors = <String>[];
  FlutterError.onError = (details) {
    errors.add(details.toString());
    stderr.writeln(details);
  };
  final controller = LiveWidgetController(WidgetsBinding.instance);
  Future<void> pump() async {
    await controller.pump(const Duration(milliseconds: 25));
    await Future<void>.delayed(const Duration(milliseconds: 15));
  }
  Future<void> until(bool Function() ready) async {
    await pump();
    final deadline = DateTime.now().add(const Duration(seconds: 8));
    while (!ready() && errors.isEmpty) {
      if (DateTime.now().isAfter(deadline)) throw StateError('Ouverture non obtenue dans le délai.');
      await pump();
    }
    await pump();
  }
  var success = false;
  try {
    final patient = await PatientRepository().createPatient(
      lastName: 'SYNTHETIQUE', firstName: 'Ouverture', birthDate: '1995-11-15', sexCode: 'M');
    await S.load(const Locale('fr', 'FR'));
    runApp(MaterialApp(locale: const Locale('fr', 'FR'),
      localizationsDelegates: const [S.delegate, GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      supportedLocales: S.delegate.supportedLocales,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: PatientDetailScreen(patient: patient)));
    final button = find.text('Compléter l’identité et ses justificatifs');
    await until(() => button.evaluate().isNotEmpty);
    if (errors.isNotEmpty) throw StateError('Erreur avant le clic');
    await controller.ensureVisible(button);
    await pump();
    await controller.tap(button);
    await until(() => find.byType(PatientQualificationScreen).evaluate().isNotEmpty);
    await until(() => find.text('Noms d’usage').evaluate().isNotEmpty);
    if (errors.isNotEmpty) throw StateError('Erreur pendant l’ouverture');
    success = true;
  } catch (error, stack) {
    errors.add('$error\n$stack');
    stderr.writeln('$error\n$stack');
  } finally {
    runApp(const SizedBox.shrink());
    await pump();
    await DatabaseService.closeDatabase();
    File('${output.path}/result.json').writeAsStringSync(const JsonEncoder.withIndent('  ').convert({
      'scenario': 'ouverture du formulaire depuis la fiche patient',
      'success': success && errors.isEmpty, 'errors': errors,
      'syntheticRoot': root.path,
    }));
  }
  stdout.writeln(success && errors.isEmpty ? 'PASS ouverture du formulaire' : 'FAIL ouverture du formulaire');
  exit(success && errors.isEmpty ? 0 : 1);
}
