import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/main.dart' as application;
import 'package:abak_desktop_companion/core/maintenance/maintenance_session.dart';
import 'package:abak_desktop_companion/core/maintenance/maintenance_screen.dart';
import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:abak_desktop_companion/core/settings/macos_launch_history_service.dart';
import 'package:abak_desktop_companion/generated/l10n.dart';

class BenchBinding extends WidgetsFlutterBinding
    with TestDefaultBinaryMessengerBinding {}

class NoUserPaths extends PathProviderPlatform {
  int calls = 0;
  String? permitted;
  @override
  Future<String?> getApplicationSupportPath() async {
    calls++;
    if (permitted == null) throw StateError('User storage forbidden');
    return permitted;
  }
}

class MigrationFailure implements DatabaseFactory {
  @override
  Future<Database> openDatabase(String path, {OpenDatabaseOptions? options}) =>
      databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: options!.version,
          onUpgrade: (db, old, next) async {
            await options.onUpgrade!(db, old, next);
            throw StateError('Interruption synthétique avant commit');
          },
          singleInstance: false,
        ),
      );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> main() async {
  final binding = BenchBinding();
  await S.load(const Locale('fr', 'FR'));
  final root = Directory(Platform.environment['DEPLOY_ROOT']!);
  final repo = Platform.environment['DEPLOY_REPO']!;
  final phase = Platform.environment['DEPLOY_PHASE']!;
  final dbPath = '${root.path}/active/support/database/abak_desktop.db';
  final request = StartupRequest.parse([
    '--abak-maintenance',
    '--abak-maintenance-root=${root.path}',
  ]);
  final checks = <String>[], platformCalls = <String>[];
  final errors = <String>[];
  FlutterError.onError = (e) {
    errors.add(e.toString());
    stderr.writeln(e.toString());
  };
  void check(bool value, String name) {
    if (!value) throw StateError(name);
    checks.add(name);
    stdout.writeln('PASS $name');
  }

  Future<void> refuses(Future<dynamic> Function() fn, String name) async {
    var rejected = false;
    try {
      await fn();
    } catch (_) {
      rejected = true;
    }
    check(rejected, name);
  }

  final paths = NoUserPaths();
  PathProviderPlatform.instance = paths;
  final messenger = binding.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(const MethodChannel('window_manager'), (
    call,
  ) async {
    platformCalls.add(call.method);
    if (call.method == 'isFullScreen' ||
        call.method == 'isMaximized' ||
        call.method == 'isMinimized' ||
        call.method == 'isPreventClose') {
      return false;
    }
    if (call.method == 'getBounds') {
      return {'x': 0.0, 'y': 0.0, 'width': 820.0, 'height': 620.0};
    }
    return null;
  });
  final forbidden = <String>[];
  messenger.setMockMethodCallHandler(
    const MethodChannel('dev.leanflutter.plugins/screen_retriever'),
    (call) async {
      final display = {
        'id': 'synthetic',
        'size': {'width': 1280.0, 'height': 900.0},
        'visibleSize': {'width': 1280.0, 'height': 900.0},
        'visiblePosition': {'dx': 0.0, 'dy': 0.0},
        'scaleFactor': 1.0,
      };
      if (call.method == 'getPrimaryDisplay') {
        return display;
      }
      if (call.method == 'getAllDisplays') {
        return {
          'displays': [display],
        };
      }
      if (call.method == 'getCursorScreenPoint') {
        return {'dx': 100.0, 'dy': 100.0};
      }
      throw StateError('Unexpected screen method: ${call.method}');
    },
  );
  for (final channel in [
    'abak_dmp_fr',
    'abak_insi_fr',
    'plugins.flutter.io/shared_preferences',
  ]) {
    messenger.setMockMethodCallHandler(MethodChannel(channel), (call) async {
      forbidden.add('$channel:${call.method}');
      throw StateError('Forbidden capability');
    });
  }
  sqfliteFfiInit();
  try {
    if (phase == 'seed') {
      await Directory(
        '${root.path}/active/support/database',
      ).create(recursive: true);
      final db = await DatabaseService.openDatabaseFile(
        dbPath,
        factory: databaseFactoryFfi,
      );
      await db.execute("PRAGMA journal_mode=DELETE");
      await db.insert('patients', {
        'patient_id': 'SYN-P',
        'last_name': 'SYNTHETIQUE',
        'first_name': 'Patient',
        'birth_date': '1980-01-01',
        'created_at': 1,
      });
      await db.insert('care_episodes', {
        'care_episode_id': 'SYN-E',
        'patient_id': 'SYN-P',
        'title': 'Synthétique',
        'pathology_label': 'Fictif',
        'created_at': 1,
      });
      await db.insert('patient_fr_health_identity', {
        'patient_id': 'SYN-P',
        'identity_status': 'qualified',
        'identity_doubtful': 0,
      });
      final pdfDir = Directory(
        '${root.path}/active/support/episode_document_versions',
      )..createSync(recursive: true);
      final bytes = File(
        '$repo/tool/dmp_pdf_cda_isolated/fixtures/temoin-pdfa1b.pdf',
      ).readAsBytesSync();
      File('${pdfDir.path}/frozen.pdf').writeAsBytesSync(bytes);
      File(
        '${pdfDir.path}/proof.json',
      ).writeAsStringSync('{"synthetic":true,"outcome":"indeterminate"}');
      await db.insert('episode_documents', {
        'document_id': 'SYN-D',
        'case_id': 'SYN-E',
        'title': 'PDF synthétique',
        'file_path': 'episode_document_versions/frozen.pdf',
        'mime_type': 'application/pdf',
        'source': 'local_copy',
        'created_at': 1,
      });
      final hash = sha256.convert(bytes).toString();
      await db.insert('episode_document_versions', {
        'version_id': 'SYN-V',
        'document_id': 'SYN-D',
        'patient_id': 'SYN-P',
        'episode_id': 'SYN-E',
        'sequence_number': 1,
        'relative_path': 'frozen.pdf',
        'sha256': hash,
        'byte_size': bytes.length,
        'mime_type': 'application/pdf',
        'page_count': 1,
        'source_kind': 'external',
        'captured_at': 1,
      });
      await db.insert('document_holds', {
        'version_id': 'SYN-V',
        'held': 1,
        'revision': 1,
        'changed_at': 1,
      });
      await db.insert('document_attempts', {
        'attempt_id': 'SYN-T',
        'document_id': 'SYN-D',
        'version_id': 'SYN-V',
        'patient_id': 'SYN-P',
        'pdf_hash': hash,
        'approval_id': 'SYN-A',
        'control_run_id': 'SYN-C',
        'snapshot_hash': 'a' * 64,
        'payload_hash': 'b' * 64,
        'mode': 'simulation',
        'started_at': 1,
      });
      await db.insert('document_attempt_results', {
        'attempt_id': 'SYN-T',
        'outcome': 'indeterminate',
        'detail': 'Résultat fictif',
        'evidence_json': '{}',
        'evidence_hash': 'c' * 64,
        'completed_at': 2,
      });
      await db.execute('DROP TABLE document_reconciliations');
      await db.setVersion(36);
      await db.close();
      check(
        true,
        'Base synthétique 36 créée avec patient, identité, PDF, preuve, retenue et tentative indéterminée',
      );
    } else if (phase == 'inspect' || phase == 'reopen' || phase == 'restored') {
      final original = sha256
          .convert(File(dbPath).readAsBytesSync())
          .toString();
      await application.main([
        '--abak-maintenance',
        '--abak-maintenance-root=${root.path}',
      ]);
      final controller = LiveWidgetController(binding);
      for (var i = 0; i < 10; i++) {
        await controller.pump(const Duration(milliseconds: 25));
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      check(
        find.byType(CompanionMaintenanceApp).evaluate().length == 1,
        'Vrai main : écran maintenance distinct atteint',
      );
      final app = controller.widget<CompanionMaintenanceApp>(
        find.byType(CompanionMaintenanceApp),
      );
      final session = app.session;
      check(
        session.integrity && session.synthetic,
        'Intégrité SQLite correcte en lecture seule',
      );
      check(
        session.version == (phase == 'reopen' ? 37 : 36),
        'Version lue sans migration implicite',
      );
      check(
        paths.calls == 0 && forbidden.isEmpty,
        'Aucun stockage utilisateur, préférence réelle, CPS ou INSi sollicité',
      );
      check(
        find.byType(FilledButton).evaluate().length == 1 &&
            find.text('Fermer Companion').evaluate().length == 1,
        'Aucune commande métier ou migration dans cet écran',
      );
      await refuses(
        () => session.database.execute(
          'CREATE TABLE forbidden_write (id INTEGER)',
        ),
        'Écriture SQLite refusée par la connexion de maintenance',
      );
      await refuses(
        () => MaintenanceSession.open(request),
        'Deuxième session du même processus bloquée',
      );
      final python = await Process.run('/usr/bin/python3', [
        '-c',
        'import fcntl,sys\nf=open(sys.argv[1],"a+b")\ntry: fcntl.lockf(f,fcntl.LOCK_EX|fcntl.LOCK_NB)\nexcept BlockingIOError: sys.exit(55)\nsys.exit(0)',
        session.lock.path,
      ]);
      check(
        python.exitCode == 55,
        'Verrou Dart bloque aussi un autre processus/outillage Python',
      );
      final boundary = GlobalKey();
      runApp(RepaintBoundary(key: boundary, child: app));
      for (var i = 0; i < 5; i++) {
        await controller.pump(const Duration(milliseconds: 25));
      }
      final render =
          boundary.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await render.toImage();
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      File(
        '${root.path}/$phase.png',
      ).writeAsBytesSync(png!.buffer.asUint8List());
      image.dispose();
      final button = controller.widget<FilledButton>(find.byType(FilledButton));
      button.onPressed!();
      await Future<void>.delayed(const Duration(milliseconds: 150));
      check(
        platformCalls.contains('close'),
        'Fermeture ne redémarre pas le métier',
      );
      final second = await MaintenanceSession.open(request);
      await second.close();
      final authorizedRequest = StartupRequest.parse([
        '--abak-maintenance',
        '--abak-maintenance-root=${root.path}',
        '--abak-maintenance-authorize',
      ]);
      check(
        StartupRequest.parse([
          '--abak-maintenance',
          '--abak-maintenance-root=${root.path}',
          '--abak-maintenance-authorize',
          '--abak-bundle-resources',
        ]).bundleResourcesRecipe,
        'Recette ressources exige les trois gardes de maintenance',
      );
      for (final arguments in <List<String>>[
        ['--abak-bundle-resources'],
        ['--abak-maintenance', '--abak-bundle-resources'],
        ['--abak-maintenance', '--abak-maintenance-root=${root.path}', '--abak-bundle-resources'],
        ['--abak-maintenance', '--abak-maintenance-root=${root.path}', '--abak-maintenance-authorize', '--abak-bundle-resources', '--abak-bundle-resources'],
      ]) {
        await refuses(
          () async => StartupRequest.parse(arguments),
          'Options ressources incomplètes ou répétées refusées : ${arguments.length}',
        );
      }
      var authorizeResult = false;
      var releases = 0;
      messenger.setMockMethodCallHandler(
        const MethodChannel('abak/maintenance_access'),
        (call) async {
          if (call.method == 'release') {
            releases++;
            return null;
          }
          if (call.method == 'authorize')
            return authorizeResult ? root.path : null;
          throw StateError('Unexpected maintenance method');
        },
      );
      await refuses(
        () => MaintenanceSession.open(authorizedRequest),
        'Annulation du sélecteur natif bloque l’ouverture sans repli',
      );
      authorizeResult = true;
      final authorized = await MaintenanceSession.open(authorizedRequest);
      await authorized.close();
      check(releases == 1, 'Autorisation de dossier libérée après fermeture');
      await refuses(
        () async => StartupRequest.parse([
          '--abak-maintenance',
          '--abak-maintenance-authorize',
        ]),
        'Autorisation sans racine synthétique refusée',
      );
      check(
        sha256.convert(File(dbPath).readAsBytesSync()).toString() == original,
        'Base strictement identique après fermeture et réouverture',
      );
      await refuses(
        () async =>
            StartupRequest.parse(['--abak-maintenance-root=${root.path}']),
        'Root sans maintenance refusé',
      );
      await refuses(
        () async =>
            StartupRequest.parse(['--abak-maintenance', '--abak-maintenance']),
        'Option répétée refusée',
      );
      await refuses(
        () async =>
            StartupRequest.parse(['--abak-maintenance', '--abak-unsafe']),
        'Option inconnue refusée',
      );
      final marker = File('${root.path}/SYNTHETIC-ONLY');
      final saved = marker.readAsStringSync();
      marker.writeAsStringSync('WRONG');
      await refuses(
        () => MaintenanceSession.open(authorizedRequest),
        'Marqueur invalide après autorisation refusé',
      );
      check(
        releases == 2,
        'Autorisation libérée aussi après échec d’ouverture',
      );
      await refuses(
        () => MaintenanceSession.open(request),
        'Marqueur invalide refusé sans repli utilisateur',
      );
      marker.writeAsStringSync(saved);
      final sidecar = File('$dbPath-wal');
      sidecar.writeAsStringSync('UNCERTAIN');
      await refuses(
        () => MaintenanceSession.open(request),
        'WAL incertain conservé et ouverture refusée',
      );
      check(
        sidecar.readAsStringSync() == 'UNCERTAIN',
        'WAL non supprimé pour forcer une ouverture',
      );
      sidecar.deleteSync();
      // Test the normal main's guard before any DB/background service: another
      // holder owns the same support directory, so no business startup is possible.
      paths.permitted = '${root.path}/active/support';
      final owned = await CompanionInstanceLock.acquire(
        File('${paths.permitted}/.companion-instance.lock'),
      );
      await application.main([]);
      for (var i = 0; i < 5; i++) {
        await controller.pump(const Duration(milliseconds: 25));
      }
      check(
        find.text(S.current.main_alreadyRunningTitle).evaluate().length == 1,
        'Message de session concurrente affiché sans erreur de traduction',
      );
      check(
        sha256.convert(File(dbPath).readAsBytesSync()).toString() == original,
        'Démarrage normal concurrent bloqué avant ouverture/migration de la base',
      );
      await owned.close();
      // This empty lock is a kernel rendezvous, not part of saved business state.
      File('${paths.permitted}/.companion-instance.lock').deleteSync();
    } else if (phase == 'migration-failure') {
      await refuses(
        () => DatabaseService.openDatabaseFile(
          dbPath,
          factory: MigrationFailure(),
        ),
        'Migration produit interrompue avant commit',
      );
      final db = await databaseFactoryFfi.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(readOnly: true, singleInstance: false),
      );
      check(
        await db.getVersion() == 36,
        'Annulation transactionnelle conserve le schéma 36',
      );
      check(
        (await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE name='document_reconciliations'",
        )).isEmpty,
        'Aucune table partielle après échec',
      );
      await db.close();
    } else if (phase == 'migrate' || phase == 'journal') {
      final lock = await CompanionInstanceLock.acquire(
        File('${root.path}/.companion-instance.lock'),
      );
      final db = phase == 'migrate'
          ? await DatabaseService.openDatabaseFile(
              dbPath,
              factory: databaseFactoryFfi,
            )
          : await databaseFactoryFfi.openDatabase(
              dbPath,
              options: OpenDatabaseOptions(singleInstance: false),
            );
      check(
        await db.getVersion() == (phase == 'migrate' ? 37 : 36),
        'Schéma attendu et aucune rétrogradation SQL',
      );
      check(
        (await db.query('document_attempts')).length == 1 &&
            (await db.query('document_attempt_results')).single['outcome'] ==
                'indeterminate',
        'Tentative et résultat indéterminé conservés',
      );
      check(
        (await db.query('document_holds')).single['held'] == 1,
        'Retenue conservée',
      );
      final row = (await db.query('document_attempts')).single;
      await refuses(
        () => db.insert('document_attempts', {
          ...row,
          'attempt_id': 'SYN-RESEND',
        }),
        'Renvoi toujours bloqué par le journal produit',
      );
      final prefs = jsonDecode(
        File(
          '${root.path}/active/preferences/preferences.json',
        ).readAsStringSync(),
      );
      final old = CompanionVersion(prefs['version'], prefs['build']);
      check(
        !const CompanionVersion('1.1.0', '9').isOlderThan(old),
        'Préférences et ancienne version cohérentes',
      );
      await db.close();
      await lock.close();
    } else if (phase == 'hold') {
      final lock = await CompanionInstanceLock.acquire(
        File('${root.path}/.companion-instance.lock'),
      );
      stdout.writeln('LOCK_READY');
      await stdin.first;
      await lock.close();
    } else {
      throw StateError('Unknown phase');
    }
    check(forbidden.isEmpty, 'Zéro appel CPS/INSi/préférences natives');
    check(errors.isEmpty, 'Aucune erreur Flutter inattendue');
    File('${root.path}/$phase.json').writeAsStringSync(
      jsonEncode({
        'passed': true,
        'phase': phase,
        'checks': checks,
        'platformCalls': platformCalls,
        'forbiddenCalls': forbidden,
      }),
    );
    exit(0);
  } catch (e, s) {
    stderr.writeln('$e\n$s');
    exit(1);
  }
}
