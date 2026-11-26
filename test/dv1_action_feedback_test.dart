import 'package:abak_desktop_companion/core/documents/document_migration_gateway.dart';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:abak_desktop_companion/features/dmp_session/dmp_work_context.dart';
import 'package:abak_desktop_companion/features/patients/models/episode_document_version.dart';
import 'package:abak_desktop_companion/features/patients/screens/document_dv1_panel.dart';
import 'package:abak_desktop_companion/features/patients/services/document_journal_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_medical_service.dart';

// In-memory query double: no database file, native service, card or network.
// A configuration with only a professional ID is enough to exercise the early
// selection gate. If that gate passes, stop before filesystem/CPS validation.
class QueryOnlyDatabase implements Database {
  QueryOnlyDatabase({this.configured = true});
  bool configured;
  int reads = 0, writes = 0;
  Map<String, Object?> get configuration {
    final value = {
      'schema': 1,
      'environment': 'DV1',
      'fields': {'professionalId': 'michel'},
      'resources': <String, Object?>{},
    };
    return {
      'revision': 1,
      'data_json': jsonEncode(value),
      'data_hash': medicalHash(value),
    };
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #rawQuery) {
      reads++;
      final sql = invocation.positionalArguments.first as String;
      return Future<List<Map<String, Object?>>>.value(
        configured && sql.contains('sqlite_master')
            ? [
                {'name': 'document_dv1_configurations'},
              ]
            : [],
      );
    }
    if (invocation.memberName == #query) {
      reads++;
      return Future<List<Map<String, Object?>>>.value(
        configured &&
                invocation.positionalArguments.first ==
                    'document_dv1_configurations'
            ? [configuration]
            : [],
      );
    }
    writes++;
    throw UnsupportedError('Unexpected database mutation or service.');
  }
}

class QueryOnlyJournal implements DocumentJournalService {
  QueryOnlyJournal(this.db);
  final QueryOnlyDatabase db;
  @override
  Future<Database> get database async => db;
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Stop before filesystem, CPS and network.');
}

EpisodeDocumentVersion version(String id) => EpisodeDocumentVersion({
  'version_id': id,
  'document_id': 'synthetic-document',
  'sha256': 'a' * 64,
});

class PanelHarness {
  PanelHarness({bool configured = true})
    : db = QueryOnlyDatabase(configured: configured);
  final QueryOnlyDatabase db;
  final context = DmpWorkContext(); // isolated: never closes a CPS lease
  final key = GlobalKey();
  final enabled = ValueNotifier(true);
  final selectedVersion = ValueNotifier(version('v1'));
  Future<void> Function() onCompleted = () async {};

  Future<void> mount(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ValueListenableBuilder<bool>(
              valueListenable: enabled,
              builder: (_, available, _) =>
                  ValueListenableBuilder<EpisodeDocumentVersion>(
                    valueListenable: selectedVersion,
                    builder: (_, selected, _) => DocumentDv1Panel(
                      key: key,
                      journal: QueryOnlyJournal(db),
                      version: selected,
                      enabled: available,
                      workContext: context,
                      onBusy: (busy) => enabled.value = !busy,
                      onCompleted: () => onCompleted(),
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  String status(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('dv1-status'))).data!;

  Future<void> forcePreviouslyReady(WidgetTester tester) async {
    // Reproduce the time gap between an earlier successful preparation and a
    // failing explicit action. The action still performs its real guards.
    final dynamic state = key.currentState;
    state.setState(() => state.ready = true);
    await tester.pump();
    await tester.ensureVisible(find.text('Vérifier l’accès DV1 — sans dépôt'));
  }

  Future<void> failDuringParentBusyCycle(WidgetTester tester) async {
    final completed = Completer<void>();
    onCompleted = () => completed.future;
    await forcePreviouslyReady(tester);
    await tester.tap(find.text('Vérifier l’accès DV1 — sans dépôt'));
    await tester
        .pump(); // parent now disables the child while the action awaits
    expect(enabled.value, isFalse);
    completed.complete();
    await tester.pumpAndSettle(); // parent re-enables and refreshes the panel
    expect(enabled.value, isTrue);
  }
}

void main() {
  testWidgets(
    'M2.3 root revision refreshes DV1 display without write or transmission',
    (tester) async {
      final harness = PanelHarness(configured: false);
      await harness.mount(tester);
      final reads = harness.db.reads;
      documentRootRevision.value++;
      await tester.pumpAndSettle();
      expect(harness.db.reads, greaterThan(reads));
      expect(harness.db.writes, 0);
      await tester.pumpWidget(const SizedBox());
      documentRootRevision.value++;
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('missing practitioner is explained before any PIN dialog', (
    tester,
  ) async {
    final harness = PanelHarness();
    harness.context.setEnabled(true);
    await harness.mount(tester);
    expect(harness.status(tester), contains('Sélectionnez un praticien'));
    final button = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Vérifier l’accès DV1 — sans dépôt'),
    );
    expect(button.onPressed, isNull);
    expect(find.byType(AlertDialog), findsNothing);
    expect(harness.db.writes, 0);
  });

  testWidgets('a different selected practitioner remains blocked', (
    tester,
  ) async {
    final harness = PanelHarness();
    harness.context
      ..setEnabled(true)
      ..select('marie');
    await harness.mount(tester);
    expect(harness.status(tester), contains('praticien du bandeau diffère'));
    expect(harness.db.writes, 0);
  });

  testWidgets('unlocking refreshes the selection gate without card work', (
    tester,
  ) async {
    final harness = PanelHarness();
    harness.context
      ..setEnabled(true)
      ..select('michel')
      ..lock();
    await harness.mount(tester);
    expect(harness.status(tester), contains('Déverrouillez Companion'));
    final reads = harness.db.reads;
    harness.context.unlock('michel');
    await tester.pumpAndSettle();
    expect(harness.db.reads, greaterThan(reads));
    expect(harness.status(tester), isNot(contains('Déverrouillez Companion')));
    expect(harness.db.writes, 0);
  });

  testWidgets('an action refusal survives the parent busy refresh', (
    tester,
  ) async {
    final harness = PanelHarness(configured: false);
    await harness.mount(tester);
    await harness.failDuringParentBusyCycle(tester);
    final result = tester.widget<Text>(
      find.byKey(const Key('dv1-action-result')),
    );
    expect(result.data, contains('Configuration DV1 absente.'));
    expect(harness.status(tester), contains('Configurez la recette DV1'));
    expect(find.byType(AlertDialog), findsNothing);
    expect(harness.db.writes, 0);
  });

  testWidgets('manual refresh preserves feedback for the same version', (
    tester,
  ) async {
    final harness = PanelHarness(configured: false);
    await harness.mount(tester);
    await harness.failDuringParentBusyCycle(tester);
    final dynamic state = harness.key.currentState;
    await state.refresh();
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const Key('dv1-action-result'))).data,
      contains('Configuration DV1 absente.'),
    );
    expect(harness.db.writes, 0);
  });

  testWidgets('another document version cannot display old action feedback', (
    tester,
  ) async {
    final harness = PanelHarness(configured: false);
    await harness.mount(tester);
    await harness.failDuringParentBusyCycle(tester);
    expect(find.byKey(const Key('dv1-action-result')), findsOneWidget);
    harness.selectedVersion.value = version('v2');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dv1-action-result')), findsNothing);
    expect(harness.db.writes, 0);
  });

  testWidgets('context notifications after disposal do not update the panel', (
    tester,
  ) async {
    final harness = PanelHarness();
    harness.context.setEnabled(true);
    await harness.mount(tester);
    await tester.pumpWidget(const SizedBox.shrink());
    harness.context.select('michel');
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(harness.db.writes, 0);
  });
}
