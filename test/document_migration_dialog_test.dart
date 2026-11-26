import 'dart:async';
import 'dart:io';
import 'package:abak_desktop_companion/core/documents/document_migration_dialog.dart';
import 'package:abak_desktop_companion/core/documents/document_migration_gateway.dart';
import 'package:abak_desktop_companion/core/documents/document_root_migration.dart';
import 'package:abak_desktop_companion/core/settings/macos_directory_access_service.dart';
import 'package:abak_desktop_companion/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

DocumentMigrationPlan fixture({
  bool impact = false,
  bool unknown = false,
  String id = 'one',
}) => DocumentMigrationPlan({
  'id': id,
  'source': '/synthetic/old',
  'destination': '/synthetic/new',
  'files': 3,
  'bytes': 456,
  'foreignEntries': <String>[],
  'associations': [
    {'patient_id': 'synthetic', 'folder_name': 'PAT'},
  ],
  'manifest': <Object>[],
  'changes': <Object>[],
  'spaceUnknown': unknown,
  'dmp': {
    'approvals': impact ? ['a'] : [],
    'controls': impact ? ['c1', 'c2'] : [],
    'documents': impact ? ['d'] : [],
    'preparingDocuments': impact ? ['p'] : [],
    'acceptedDocuments': impact ? ['d'] : [],
    'blockers': [],
  },
});

class FakeGateway implements DocumentMigrationGateway {
  @override
  bool pending = false;
  @override
  bool canAuthorize = true;
  String? current = '/synthetic/old',
      selection = '/synthetic/new',
      opened,
      authorized;
  bool enabled = false;
  int choices = 0, plans = 0, executions = 0, recoveries = 0;
  DocumentMigrationPlan next = fixture();
  MigrationConsent? consent;
  MigrationCancellation? cancellation;
  MigrationProgress? progress;
  bool sourcesRetained = false;
  Object? planError, executeError, recoveryError, detailsError, openError;
  Completer<void>? wait;
  List<MigrationRecoveryDetails> unfinished = [];
  @override
  Future<String?> root() async => current;
  @override
  Future<bool> dmpEnabled() async => enabled;
  @override
  Future<String?> choose(String title) async {
    choices++;
    return selection;
  }

  @override
  Future<void> open(String path) async {
    if (openError != null) throw openError!;
    opened = path;
  }

  @override
  Future<void> authorize(String path, String title) async {
    authorized = path;
    recoveryError = null;
    openError = null;
  }

  @override
  Future<DocumentMigrationPlan> plan(String path) async {
    plans++;
    if (planError != null) throw planError!;
    return next;
  }

  @override
  Future<bool> execute(
    DocumentMigrationPlan plan,
    MigrationConsent consent,
    MigrationCancellation cancellation,
    MigrationProgress progress,
  ) async {
    executions++;
    this.consent = consent;
    this.cancellation = cancellation;
    this.progress = progress;
    progress('preflight', 0, 0);
    if (wait != null) await wait!.future;
    if (executeError != null) throw executeError!;
    cancellation.check();
    current = plan.destination;
    return sourcesRetained;
  }

  @override
  Future<List<MigrationRecoveryDetails>> details() async {
    if (detailsError != null) throw detailsError!;
    return unfinished;
  }

  @override
  Future<List<MigrationRecovery>> recover() async {
    recoveries++;
    if (recoveryError != null) throw recoveryError!;
    pending = false;
    final result = unfinished
        .map(
          (d) => MigrationRecovery(
            d.plan.id,
            d.committed ? 'committed' : 'sourceRetained',
          ),
        )
        .toList();
    if (unfinished.any((d) => d.committed)) {
      current = unfinished.last.plan.destination;
    }
    return result;
  }
}

void main() {
  Future<void> launch(
    WidgetTester t,
    FakeGateway api, {
    bool recovery = false,
    VoidCallback? ready,
    VoidCallback? quit,
    Locale locale = const Locale('fr', 'FR'),
  }) async {
    t.view.physicalSize = const Size(1400, 1100);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: Scaffold(
          body: recovery
              ? DocumentMigrationDialog(
                  gateway: api,
                  recoveryOnly: true,
                  onReady: ready,
                  onQuit: quit,
                )
              : DocumentStorageTile(gateway: api),
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  Future<void> tap(WidgetTester t, String key) async {
    final finder = find.byKey(ValueKey(key));
    await t.ensureVisible(finder);
    await t.tap(finder);
    await t.pumpAndSettle();
  }

  Future<void> review(WidgetTester t, FakeGateway api) async {
    await launch(t, api);
    await tap(t, 'storage-move');
    await tap(t, 'migration-continue');
    if (api.enabled) await tap(t, 'migration-continue');
  }

  testWidgets(
    'Technical total, manifest details and localized size in review and success',
    (t) async {
      final api = FakeGateway();
      api.next = DocumentMigrationPlan({
        ...fixture().data,
        'bytes': 12624,
        'manifest': [
          {'path': 'PAT', 'directory': true},
          {'path': 'PAT/Bilan/a.docx', 'directory': false, 'size': 6090},
          {'path': 'PAT/Rapport/b.docx', 'directory': false, 'size': 6000},
          {'path': 'PAT/.DS_Store', 'directory': false, 'size': 534},
        ],
      });
      await review(t, api);
      expect(find.textContaining('Total des fichiers : 3'), findsOneWidget);
      expect(find.textContaining('Volume : 12,3 Kio'), findsOneWidget);
      expect(
        find.text(S.current.migration_fileCountExplanation),
        findsOneWidget,
      );
      await tap(t, 'migration-file-details');
      expect(find.text('PAT/.DS_Store'), findsOneWidget);
      expect(find.text('PAT'), findsNothing);
      expect(find.text('534 octets'), findsOneWidget);
      await tap(t, 'migration-file-details');
      await tap(t, 'migration-confirm');
      expect(find.textContaining('Volume : 12,3 Kio'), findsOneWidget);
      expect(api.next.data['bytes'], 12624);
    },
  );
  testWidgets(
    'Configured root, open folder and cancellation never mutate root',
    (t) async {
      final api = FakeGateway();
      await launch(t, api);
      expect(find.text('/synthetic/old'), findsOneWidget);
      await tap(t, 'storage-open');
      expect(api.opened, api.current);
      await tap(t, 'storage-move');
      await tap(t, 'migration-cancel');
      expect(api.choices, 0);
      expect(api.executions, 0);
      expect(api.current, '/synthetic/old');
      await tap(t, 'storage-move');
      await tap(t, 'migration-continue');
      await tap(t, 'migration-cancel');
      expect(api.plans, 1);
      expect(api.executions, 0);
    },
  );
  testWidgets('DMP warning precedes picker and can be cancelled', (t) async {
    final api = FakeGateway()..enabled = true;
    await launch(t, api);
    await tap(t, 'storage-move');
    await tap(t, 'migration-continue');
    expect(find.text(S.current.migration_dmpMessage), findsOneWidget);
    expect(api.choices, 0);
    await tap(t, 'migration-cancel');
    expect(api.executions, 0);
  });
  testWidgets(
    'Disabled DMP still diagnoses historical dependencies and distinct counts',
    (t) async {
      final api = FakeGateway()..next = fixture(impact: true);
      await review(t, api);
      expect(api.plans, 1);
      expect(find.text(S.current.migration_historical), findsOneWidget);
      expect(find.text(S.current.migration_impact(1, 1, 2)), findsOneWidget);
      expect(find.text(S.current.migration_accepted(1)), findsOneWidget);
      expect(find.text(S.current.migration_preparing(1)), findsOneWidget);
      expect(find.text(S.current.migration_dmpMessage), findsNothing);
      expect(
        t
            .widget<FilledButton>(
              find.byKey(const ValueKey('migration-confirm')),
            )
            .onPressed,
        isNull,
      );
      expect(
        t
            .widget<CheckboxListTile>(
              find.byKey(const ValueKey('migration-invalidations')),
            )
            .value,
        isFalse,
      );
    },
  );
  testWidgets('Both explicit consents bind to the displayed immutable plan', (
    t,
  ) async {
    final api = FakeGateway()..next = fixture(impact: true, unknown: true);
    await review(t, api);
    expect(
      t
          .widget<CheckboxListTile>(
            find.byKey(const ValueKey('migration-space')),
          )
          .value,
      isFalse,
    );
    await tap(t, 'migration-invalidations');
    expect(
      t
          .widget<FilledButton>(find.byKey(const ValueKey('migration-confirm')))
          .onPressed,
      isNull,
    );
    await tap(t, 'migration-space');
    await tap(t, 'migration-confirm');
    expect(api.consent!.planHash, api.next.hash);
    expect(api.consent!.invalidations, isTrue);
    expect(api.consent!.unknownSpace, isTrue);
    expect(find.text(S.current.migration_success), findsOneWidget);
    expect(find.text(S.current.migration_renew), findsOneWidget);
  });
  testWidgets(
    'Changed plan resets all checkboxes and requires a new confirmation',
    (t) async {
      final api = FakeGateway()..next = fixture(impact: true, unknown: true);
      await review(t, api);
      await tap(t, 'migration-invalidations');
      await tap(t, 'migration-space');
      api.next = fixture(impact: true, unknown: true, id: 'two');
      api.executeError = const MigrationBlocked('plan_changed');
      await tap(t, 'migration-confirm');
      expect(api.plans, 2);
      expect(find.byKey(const ValueKey('migration-changed')), findsOneWidget);
      expect(
        t
            .widget<CheckboxListTile>(
              find.byKey(const ValueKey('migration-space')),
            )
            .value,
        isFalse,
      );
      expect(
        t
            .widget<CheckboxListTile>(
              find.byKey(const ValueKey('migration-invalidations')),
            )
            .value,
        isFalse,
      );
      expect(
        t
            .widget<FilledButton>(
              find.byKey(const ValueKey('migration-confirm')),
            )
            .onPressed,
        isNull,
      );
      api.executeError = null;
      await tap(t, 'migration-invalidations');
      await tap(t, 'migration-space');
      await tap(t, 'migration-confirm');
      expect(api.consent!.planHash, api.next.hash);
      expect(api.executions, 2);
    },
  );
  for (final code in [
    'transmission_uncertain',
    'dv1_retry_continuity',
    'historical_evidence_unverifiable',
    'clinical_source_path',
    'insufficient_space',
  ]) {
    testWidgets('Block $code cannot be bypassed by consent', (t) async {
      final api = FakeGateway()..planError = MigrationBlocked(code);
      await review(t, api);
      expect(find.byKey(const ValueKey('migration-confirm')), findsNothing);
      expect(find.byType(CheckboxListTile), findsNothing);
      expect(api.current, '/synthetic/old');
      expect(api.executions, 0);
      expect(find.text(S.current.migration_technical), findsOneWidget);
      await tap(t, 'migration-close');
    });
  }
  testWidgets(
    'Real counters, indeterminate verification, no cancellation during activation',
    (t) async {
      final api = FakeGateway()..wait = Completer<void>();
      await review(t, api);
      await t.tap(find.byKey(const ValueKey('migration-confirm')));
      await t.pump();
      expect(find.text(S.current.migration_preflight), findsOneWidget);
      expect(
        t
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        isNull,
      );
      api.progress!('copy', 2, 5);
      await t.pump();
      expect(find.text(S.current.migration_counter(2, 5)), findsOneWidget);
      expect(
        t
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        .4,
      );
      api.progress!('verifying', 0, 0);
      await t.pump();
      expect(
        find.byKey(const ValueKey('migration-cancel-copy')),
        findsOneWidget,
      );
      expect(
        t
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        isNull,
      );
      api.progress!('activating', 0, 0);
      await t.pump();
      expect(find.byKey(const ValueKey('migration-cancel-copy')), findsNothing);
      expect(find.text(S.current.migration_success), findsNothing);
      expect(api.current, '/synthetic/old');
      api.progress!('cleaning', 1, 2);
      await t.pump();
      expect(find.text(S.current.migration_cleaning), findsOneWidget);
      expect(find.byKey(const ValueKey('migration-cancel-copy')), findsNothing);
      expect(find.text(S.current.migration_success), findsNothing);
      api.sourcesRetained = true;
      api.wait!.complete();
      await t.pumpAndSettle();
      expect(find.text(S.current.migration_success), findsOneWidget);
      expect(find.text(S.current.migration_cleanupWarning), findsOneWidget);
      await tap(t, 'migration-open');
      expect(api.opened, '/synthetic/new');
      await tap(t, 'migration-close');
      expect(find.text('/synthetic/new'), findsOneWidget);
      expect(find.text('/synthetic/old'), findsNothing);
    },
  );
  testWidgets('Safe cancellation before commit leaves old root active', (
    t,
  ) async {
    final api = FakeGateway()..wait = Completer<void>();
    await review(t, api);
    await t.tap(find.byKey(const ValueKey('migration-confirm')));
    await t.pump();
    api.progress!('copy', 1, 5);
    await t.pump();
    await t.tap(find.byKey(const ValueKey('migration-cancel-copy')));
    await t.pump();
    expect(api.cancellation!.cancelled, isTrue);
    api.wait!.complete();
    await t.pumpAndSettle();
    expect(api.current, '/synthetic/old');
    expect(find.text(S.current.migration_cancelled), findsOneWidget);
    expect(find.text(S.current.migration_success), findsNothing);
  });
  testWidgets('Failure never displays success or refreshes to new root', (
    t,
  ) async {
    final api = FakeGateway()
      ..executeError = const FileSystemException('synthetic failure');
    final revision = documentRootRevision.value;
    await review(t, api);
    await tap(t, 'migration-confirm');
    expect(api.current, '/synthetic/old');
    expect(documentRootRevision.value, revision);
    expect(find.text(S.current.migration_access), findsOneWidget);
    expect(find.text(S.current.migration_success), findsNothing);
  });
  for (final committed in [false, true]) {
    testWidgets(
      'Startup recovery describes ${committed ? 'committed' : 'uncommitted'} state before changing journal',
      (t) async {
        final api = FakeGateway()
          ..pending = true
          ..unfinished = [MigrationRecoveryDetails(fixture(), committed)];
        var ready = false, quit = false;
        await launch(
          t,
          api,
          recovery: true,
          ready: () => ready = true,
          quit: () => quit = true,
        );
        expect(api.recoveries, 0);
        expect(
          find.text(
            committed
                ? S.current.migration_afterCommit
                : S.current.migration_beforeCommit,
          ),
          findsOneWidget,
        );
        expect(ready, isFalse);
        await tap(t, 'migration-recover');
        expect(api.recoveries, 1);
        expect(ready, isFalse);
        expect(api.current, committed ? '/synthetic/new' : '/synthetic/old');
        expect(
          find.text(
            committed
                ? S.current.migration_success
                : S.current.migration_recovered,
          ),
          findsOneWidget,
        );
        await tap(t, committed ? 'migration-close' : 'migration-ready');
        expect(ready, isTrue);
        expect(quit, isFalse);
      },
    );
  }
  testWidgets(
    'Missing exact authorization can be restored before committed recovery',
    (t) async {
      final api = FakeGateway()
        ..pending = true
        ..unfinished = [MigrationRecoveryDetails(fixture(), true)]
        ..recoveryError = const DirectoryAuthorizationRequired(
          '/synthetic/new',
        );
      await launch(t, api, recovery: true);
      await tap(t, 'migration-recover');
      expect(
        find.text(S.current.migration_authorizationMissing),
        findsOneWidget,
      );
      await tap(t, 'migration-authorize');
      expect(api.authorized, '/synthetic/new');
      expect(api.current, '/synthetic/new');
    },
  );
  testWidgets(
    'Corrupt journal is explained, permits retry and quit, never continuation',
    (t) async {
      final api = FakeGateway()
        ..pending = true
        ..detailsError = const MigrationBlocked('journal_corrupt')
        ..recoveryError = const MigrationBlocked('journal_corrupt');
      var quit = false;
      await launch(t, api, recovery: true, quit: () => quit = true);
      expect(find.text(S.current.migration_corrupt), findsOneWidget);
      expect(find.byKey(const ValueKey('migration-ready')), findsNothing);
      await tap(t, 'migration-retry');
      expect(api.recoveries, 1);
      await tap(t, 'migration-quit');
      expect(quit, isTrue);
      expect(api.current, '/synthetic/old');
      expect(find.byKey(const ValueKey('migration-authorize')), findsNothing);
    },
  );
  testWidgets(
    'Open action can reauthorize same configured root without migration',
    (t) async {
      final api = FakeGateway()
        ..openError = const DirectoryAuthorizationRequired('/synthetic/old');
      await launch(t, api);
      await tap(t, 'storage-open');
      await tap(t, 'storage-authorize');
      await tap(t, 'storage-open');
      expect(api.authorized, '/synthetic/old');
      expect(api.opened, '/synthetic/old');
      expect(api.executions, 0);
      expect(api.plans, 0);
    },
  );
  testWidgets(
    'No DMP consequence keeps review uncluttered and cancellation of picker is safe',
    (t) async {
      final api = FakeGateway()..selection = null;
      await launch(t, api);
      await tap(t, 'storage-move');
      await tap(t, 'migration-continue');
      expect(api.plans, 0);
      expect(api.current, '/synthetic/old');
      api.selection = '/synthetic/new';
      await tap(t, 'migration-continue');
      expect(find.byType(CheckboxListTile), findsNothing);
      expect(find.text(S.current.migration_historical), findsNothing);
    },
  );
  testWidgets(
    'Committed journal failure recovers to success without a second execute',
    (t) async {
      final api = FakeGateway();
      await review(t, api);
      api.pending = true;
      api.unfinished = [MigrationRecoveryDetails(api.next, true)];
      api.current = '/synthetic/new';
      api.executeError = const FileSystemException(
        'synthetic journal write failure',
      );
      await tap(t, 'migration-confirm');
      expect(find.text(S.current.migration_success), findsNothing);
      await tap(t, 'migration-retry');
      expect(find.text(S.current.migration_success), findsOneWidget);
      expect(api.executions, 1);
      expect(api.recoveries, 1);
    },
  );
  testWidgets(
    'Inaccessible committed destination offers retry without switching back',
    (t) async {
      final api = FakeGateway()
        ..pending = true
        ..current = '/synthetic/new'
        ..unfinished = [MigrationRecoveryDetails(fixture(), true)]
        ..recoveryError = const FileSystemException(
          'synthetic offline',
          '/synthetic/new',
        );
      await launch(t, api, recovery: true);
      await tap(t, 'migration-recover');
      expect(find.text(S.current.migration_access), findsOneWidget);
      expect(api.current, '/synthetic/new');
      expect(find.byKey(const ValueKey('migration-ready')), findsNothing);
      api.recoveryError = null;
      await tap(t, 'migration-retry');
      expect(find.text(S.current.migration_success), findsOneWidget);
    },
  );
  testWidgets(
    'Open failure after success can retry opening without another migration',
    (t) async {
      final api = FakeGateway();
      await review(t, api);
      await tap(t, 'migration-confirm');
      api.openError = const FileSystemException(
        'synthetic offline',
        '/synthetic/new',
      );
      await tap(t, 'migration-open');
      api.openError = null;
      await tap(t, 'migration-retry');
      expect(api.opened, '/synthetic/new');
      expect(find.text(S.current.migration_success), findsOneWidget);
      expect(api.executions, 1);
    },
  );
  for (final language in [
    'fr_FR',
    'en_GB',
    'de_DE',
    'es_ES',
    'it_IT',
    'pt_PT',
    'nl_NL',
  ]) {
    testWidgets('Review and actions render without overflow in $language', (
      t,
    ) async {
      final parts = language.split('_');
      final api = FakeGateway()..next = fixture(impact: true, unknown: true);
      await launch(t, api, locale: Locale(parts[0], parts[1]));
      await tap(t, 'storage-move');
      await tap(t, 'migration-continue');
      expect(find.text(S.current.migration_review), findsOneWidget);
      expect(t.takeException(), isNull);
      await tap(t, 'migration-invalidations');
      await tap(t, 'migration-space');
      await tap(t, 'migration-confirm');
      expect(find.text(S.current.migration_success), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  }
}
