import 'dart:io';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:abak_desktop_companion/features/dmp_setup/bundled_pdf_tools.dart';
import 'package:abak_desktop_companion/features/dmp_dv1_access/consultation_consent.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/dv1_configuration.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final path = Platform.environment['DV1_PREPARATION_CONFIG'];
  test('read-only local preparation checks', () async {
    final c = Dv1Configuration(
      Map<String, dynamic>.from(jsonDecode(File(path!).readAsStringSync())),
    );
    c.check(DateTime.now().toUtc());
    await BundledPdfTools.verify(
      Directory(
        '/Users/jeanclaudebrucher/Applications/ABAK Companion Local.app/Contents/Resources/DmpTools/arm64',
      ),
    );
    await ConsultationConsentStore(
      Directory(
        '/Users/jeanclaudebrucher/Library/Containers/fr.abakphysio.abakdesktopcompanion.local/Data/Library/Application Support/fr.abakphysio.abakdesktopcompanion.local/episode_document_versions/controls/dv1-consultation-consents',
      ),
    ).latest(c.professional, '148115530271002');
    await rootBundle.loadString('assets/dmp_native/DmpNativeBridge.java');
  }, skip: path == null ? 'Opt-in read-only local diagnostic' : false);
}
