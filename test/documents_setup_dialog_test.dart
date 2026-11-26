import 'package:abak_desktop_companion/core/settings/documents_setup_dialog.dart';
import 'package:abak_desktop_companion/core/settings/generated_documents_directory_service.dart';
import 'package:abak_desktop_companion/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

class _Service extends GeneratedDocumentsDirectoryService {
  bool configured = false, fail = false, cancel = false;
  int recommendedCalls = 0, customCalls = 0;
  @override
  Future<bool> needsInitialConfiguration() async => !configured;
  @override
  Future<String> recommendedPath() async => '/test/Documents/ABAK_DOCUMENTS';
  @override
  Future<String?> useRecommended() async {
    recommendedCalls++;
    if (fail) throw StateError('Permission denied');
    if (cancel) return null;
    configured = true;
    return '/test/Documents/ABAK_DOCUMENTS';
  }

  @override
  Future<String?> chooseAndSave() async {
    customCalls++;
    if (fail) throw StateError('Permission denied');
    if (cancel) return null;
    configured = true;
    return '/test/custom';
  }
}

void main() {
  Future<BuildContext> launch(WidgetTester tester, _Service service) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr', 'FR'),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: Builder(
          builder: (c) {
            context = c;
            return const Scaffold(body: Text('Accueil'));
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    showInitialDocumentsSetup(context, service: service);
    await tester.pumpAndSettle();
    return context;
  }

  testWidgets('Later leaves configuration untouched; next launch asks again', (
    tester,
  ) async {
    final service = _Service();
    final context = await launch(tester, service);
    expect(find.text('/test/Documents/ABAK_DOCUMENTS'), findsOneWidget);
    expect(service.recommendedCalls, 0);
    expect(service.customCalls, 0);
    await tester.tap(find.text('Configurer plus tard'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(service.configured, isFalse);
    await tester.pump();
    expect(find.byType(AlertDialog), findsNothing);
    showInitialDocumentsSetup(context, service: service);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
  });
  for (final recommended in [true, false]) {
    testWidgets(
      'Explicit ${recommended ? "recommendation" : "custom selection"} closes after save; restart does not prompt',
      (tester) async {
        final service = _Service();
        final context = await launch(tester, service);
        await tester.tap(
          find.text(
            recommended ? 'Utiliser ce dossier' : 'Choisir un autre dossier',
          ),
        );
        await tester.pumpAndSettle();
        expect(service.configured, isTrue);
        expect(find.byType(AlertDialog), findsNothing);
        showInitialDocumentsSetup(context, service: service);
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);
      },
    );
  }
  testWidgets('Cancellation keeps dialog open with later available', (
    tester,
  ) async {
    final service = _Service()..cancel = true;
    await launch(tester, service);
    await tester.tap(find.text('Choisir un autre dossier'));
    await tester.pumpAndSettle();
    expect(service.configured, isFalse);
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('Configurer plus tard'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });
  testWidgets('Authorization error is localized and allows retry', (
    tester,
  ) async {
    final service = _Service()..fail = true;
    await launch(tester, service);
    await tester.tap(find.text('Utiliser ce dossier'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Impossible de préparer'), findsOneWidget);
    expect(service.configured, isFalse);
    service.fail = false;
    await tester.tap(find.text('Utiliser ce dossier'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });
}
