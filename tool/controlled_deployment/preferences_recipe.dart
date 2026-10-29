// Native acceptance entry point, never used by lib/main.dart.
// The native channel exists only in a signed recipe copy with its own identity.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'package:abak_desktop_companion/core/settings/macos_directory_access_service.dart';
import 'package:abak_desktop_companion/core/settings/macos_launch_history_service.dart';
import 'package:abak_desktop_companion/core/settings/exchange_directory_service.dart';
import 'package:abak_desktop_companion/core/settings/language_preference_service.dart';

const native = MethodChannel('abak/preferences_recipe');
const historyKey = 'macos_last_successful_launch_v1';
String bookmarkKey(String path) =>
    'macos_directory_bookmark_v1_${base64Url.encode(utf8.encode(path))}';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  final phases = args.where((a) => a.startsWith('--abak-preferences-phase='));
  if (phases.length != 1) exit(78);
  final phase = phases.single.split('=').last;
  if (!{
    'seed',
    'mutated',
    'restored',
    'moved',
    'missing',
    'cancel',
    'reauthorized',
  }.contains(phase)) {
    exit(78);
  }
  final info = await native.invokeMapMethod<String, dynamic>('context');
  if (info == null ||
      !(info['identity'] as String).startsWith(
        'fr.abakphysio.maintenance.recipe.',
      )) {
    exit(78);
  }
  final support = await getApplicationSupportDirectory();
  final directory = Directory('${support.path}/native-preferences-recipe');
  await directory.create(recursive: true);
  final lock = await File(
    '${directory.path}/recipe.lock',
  ).open(mode: FileMode.append);
  await lock.lock(FileLock.exclusive);
  await windowManager.ensureInitialized();
  runApp(RecipeApp(phase: phase, info: info, directory: directory, lock: lock));
  await windowManager.waitUntilReadyToShow(
    const WindowOptions(
      size: Size(900, 720),
      center: true,
      title: 'ABAK — Préférences natives isolées',
    ),
    () async {
      await windowManager.show();
      await windowManager.focus();
    },
  );
}

class RecipeApp extends StatefulWidget {
  const RecipeApp({
    super.key,
    required this.phase,
    required this.info,
    required this.directory,
    required this.lock,
  });
  final String phase;
  final Map<String, dynamic> info;
  final Directory directory;
  final RandomAccessFile lock;
  @override
  State<RecipeApp> createState() => _RecipeAppState();
}

class _RecipeAppState extends State<RecipeApp> {
  final checks = <String>[];
  String message = 'Contrôles natifs en cours…';
  bool done = false;
  late SharedPreferences preferences;
  final directories = const MacosDirectoryAccessService();
  String get target => widget.info['target'] as String;
  File file(String name) => File('${widget.directory.path}/$name');
  void check(bool result, String label) {
    if (!result) throw StateError(label);
    checks.add(label);
    if (mounted) setState(() {});
  }

  Map<String, dynamic> values() => {
    for (final key in preferences.getKeys().toList()..sort())
      key: preferences.get(key),
  };
  Future<Map<String, dynamic>> snapshot() async =>
      (await native.invokeMapMethod<String, dynamic>('snapshot'))!;
  Future<void> restore(Map<String, dynamic> archive, {String? expected}) async {
    await native.invokeMethod<void>('restore', {
      'archive': archive,
      'expected': expected ?? (await snapshot())['sha256'],
    });
    await preferences.reload();
  }

  Future<void> blocked(Future<void> Function() operation, String label) async {
    var refused = false;
    try {
      await operation();
    } on DirectoryAuthorizationRequired {
      refused = true;
    }
    check(refused, label);
  }

  Future<void> refusedArchive(
    Map<String, dynamic> archive,
    String label, {
    String? expected,
  }) async {
    final before = (await snapshot())['sha256'];
    var refused = false;
    try {
      await restore(archive, expected: expected);
    } on PlatformException catch (e) {
      refused = e.code == 'PREFERENCES_RECIPE_REFUSED';
    }
    check(refused && (await snapshot())['sha256'] == before, label);
  }

  Future<void> checkBaseline() async {
    await preferences.reload();
    final baseline = jsonDecode(await file('baseline.json').readAsString());
    check(
      jsonEncode(values()) == jsonEncode(baseline),
      'Préférences et types identiques à la sauvegarde',
    );
    check(
      await const LanguagePreferenceService().getLanguageCode() == 'fr',
      'Langue relue par le service métier',
    );
    check(
      preferences.getBool('recipe_hold') == true &&
          preferences.getInt('recipe_counter') == 7 &&
          preferences.getDouble('recipe_scale') == 1.25 &&
          preferences.getStringList('recipe_list')!.join(',') == 'PDF,CDA',
      'Booléen, entier, décimal et liste conservés',
    );
    final history = await const MacosLaunchHistoryService()
        .inspectBeforeStartup();
    check(
      history.kind == MacosLaunchKind.olderVersion &&
          history.previous!.build == '999',
      'Historique restauré : une version antérieure reste bloquée',
    );
  }

  Future<void> readTarget(String expected) async {
    final access = await ExchangeDirectoryService().acquireExchangeDirectory();
    try {
      check(
        access.directory.path == expected,
        'Dossier exact retrouvé par le service produit',
      );
      check(
        await File('${access.directory.path}/SYNTHETIC-ONLY').readAsString() ==
            'ABAK-BOOKMARKS-SYNTHETIC-V1\n',
        'Lecture autorisée du témoin synthétique',
      );
      await File(
        '${access.directory.path}/probe-${widget.phase}.txt',
      ).writeAsString('RECETTE UNIQUEMENT\n', flush: true);
      check(
        await File(
              '${access.directory.path}/probe-${widget.phase}.txt',
            ).readAsString() ==
            'RECETTE UNIQUEMENT\n',
        'Écriture et relecture autorisées dans le seul dossier synthétique',
      );
    } finally {
      await access.release();
      await access.release();
    }
    check(true, 'Libération idempotente de l’accès produit');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => run());
  }

  Future<void> run() async {
    var passed = false;
    try {
      preferences = await SharedPreferences.getInstance();
      check(
        target.contains('/abak-bookmarks-') && !target.contains('/Containers/'),
        'Cible synthétique externe au conteneur',
      );
      check(
        !await Directory(
          '${(await getApplicationSupportDirectory()).path}/database',
        ).exists(),
        'Aucune base métier ouverte ou créée',
      );
      if (widget.phase == 'seed') {
        check(preferences.getKeys().isEmpty, 'Domaine de préférences neuf');
        final access = await directories.chooseDirectory(
          title:
              'Recette isolée : autoriser uniquement ${target.split('/').last}',
        );
        check(
          access != null && access.path == target,
          'Sélection native du dossier synthétique exact',
        );
        try {
          check(
            await File('$target/SYNTHETIC-ONLY').readAsString() ==
                'ABAK-BOOKMARKS-SYNTHETIC-V1\n',
            'Marqueur synthétique vérifié',
          );
        } finally {
          await access!.release();
        }
        await preferences.setString('exchange_directory_path', target);
        await const LanguagePreferenceService().setLanguageCode('fr');
        await preferences.setString(
          historyKey,
          jsonEncode({'version': '9.0.0', 'build': '999'}),
        );
        await preferences.setBool('recipe_hold', true);
        await preferences.setInt('recipe_counter', 7);
        await preferences.setDouble('recipe_scale', 1.25);
        await preferences.setStringList('recipe_list', ['PDF', 'CDA']);
        check(
          await native.invokeMethod<bool>('synchronize') == true,
          'Écriture native synchronisée',
        );
        final archive = await snapshot();
        await file(
          'backup.json',
        ).writeAsString(jsonEncode(archive), flush: true);
        await file(
          'baseline.json',
        ).writeAsString(jsonEncode(values()), flush: true);
        await checkBaseline();
        check(
          preferences.getString(bookmarkKey(target))!.isNotEmpty,
          'Véritable signet macOS inclus dans la sauvegarde',
        );
        await const LanguagePreferenceService().setLanguageCode('en');
        await directories.forgetDirectory(target);
        await preferences.setString(
          historyKey,
          jsonEncode({'version': '10.0.0', 'build': '1000'}),
        );
        await preferences.setBool('recipe_hold', false);
        await preferences.setString(
          'recipe_added_after_backup',
          'à retirer lors du retour',
        );
        await preferences.remove('recipe_list');
        check(
          await native.invokeMethod<bool>('synchronize') == true,
          'État modifié synchronisé avant arrêt',
        );
      } else if (widget.phase == 'mutated') {
        check(
          preferences.getString('language_code') == 'en' &&
              !preferences.containsKey(bookmarkKey(target)) &&
              preferences.getBool('recipe_hold') == false &&
              !preferences.containsKey('recipe_list'),
          'Modifications et retrait du signet conservés après arrêt',
        );
        await blocked(() async {
          await directories.acquireDirectory(target);
        }, 'Signet absent : nouvelle autorisation exigée');
        final archive = Map<String, dynamic>.from(
          jsonDecode(await file('backup.json').readAsString()) as Map,
        );
        await refusedArchive({
          ...archive,
          'identity': 'fr.abakphysio.abakdesktopcompanion.local',
        }, 'Autre identité refusée sans mutation');
        await refusedArchive({
          ...archive,
          'sha256': '0' * 64,
        }, 'Archive altérée refusée sans mutation');
        await refusedArchive({
          ...archive,
          'format': 'INCONNU',
        }, 'Format inconnu refusé sans mutation');
        await refusedArchive({
          ...archive,
          'keys': <String>[],
        }, 'Inventaire incohérent refusé sans mutation');
        await refusedArchive(
          archive,
          'Préférences modifiées depuis examen : refus sans mutation',
          expected: '1' * 64,
        );
        final before = await snapshot();
        await file(
          'before-restore.json',
        ).writeAsString(jsonEncode(before), flush: true);
        await restore(archive);
        await checkBaseline();
        check(
          !preferences.containsKey('recipe_added_after_backup'),
          'Clé postérieure à la sauvegarde retirée',
        );
      } else if (widget.phase == 'restored') {
        await checkBaseline();
        var denied = false;
        try {
          await File('$target/SYNTHETIC-ONLY').readAsString();
        } on FileSystemException {
          denied = true;
        }
        check(
          denied,
          'Après redémarrage : accès externe refusé avant restauration du signet',
        );
        await readTarget(target);
        final valid = preferences.getString(bookmarkKey(target))!;
        await preferences.setString(bookmarkKey(target), 'signet-invalide');
        await blocked(() async {
          await directories.acquireDirectory(target);
        }, 'Signet corrompu : accès bloqué et réautorisation demandée');
        await preferences.setString(bookmarkKey(target), valid);
        final a = await directories.acquireDirectory(target);
        final b = await directories.acquireDirectory(target);
        await a.release();
        check(
          await File('${b.path}/SYNTHETIC-ONLY').exists(),
          'Deux accès indépendants : libérer le premier préserve le second',
        );
        await b.release();
        await directories.forgetDirectory(target);
        await blocked(() async {
          await ExchangeDirectoryService().acquireExchangeDirectory();
        }, 'Autorisation oubliée : pas de repli silencieux du dossier métier');
        final archive = Map<String, dynamic>.from(
          jsonDecode(await file('backup.json').readAsString()) as Map,
        );
        await restore(archive);
      } else if (widget.phase == 'moved') {
        await readTarget('$target-moved');
        check(
          preferences.containsKey(bookmarkKey(target)) &&
              preferences.containsKey(bookmarkKey('$target-moved')),
          'Dossier déplacé : signet actualisé et association historique conservée',
        );
      } else if (widget.phase == 'missing') {
        final before = (await snapshot())['sha256'];
        await blocked(() async {
          await ExchangeDirectoryService().acquireExchangeDirectory();
        }, 'Dossier supprimé : accès métier bloqué sans dossier de repli');
        check(
          (await snapshot())['sha256'] == before,
          'Dossier absent : préférences préservées',
        );
        check(
          !await Directory(
            '${(await getApplicationSupportDirectory()).path}/ABAK_Echanges',
          ).exists(),
          'Aucun dossier de remplacement créé automatiquement',
        );
      } else if (widget.phase == 'cancel') {
        final before = (await snapshot())['sha256'];
        final access = await directories.chooseDirectory(
          title: 'Recette isolée : annuler cette sélection',
        );
        check(
          access == null && (await snapshot())['sha256'] == before,
          'Annulation native : aucune préférence ni autorisation remplacée',
        );
      } else if (widget.phase == 'reauthorized') {
        final access = await directories.chooseDirectory(
          title: 'Recette isolée : réautoriser ${target.split('/').last}',
        );
        check(
          access != null && access.path == target,
          'Nouvelle autorisation explicite du dossier recréé',
        );
        await access!.release();
        await preferences.setString('exchange_directory_path', target);
        await readTarget(target);
      }
      check(
        await native.invokeMethod<bool>('synchronize') == true,
        'Préférences synchronisées avant fermeture',
      );
      passed = true;
      message =
          'Phase ${widget.phase} conforme — ${checks.length} contrôles réussis.';
    } catch (error, stack) {
      message = 'Phase ${widget.phase} non validée : $error';
      await file(
        '${widget.phase}-failure.txt',
      ).writeAsString('$error\n$stack', flush: true);
    }
    await file('${widget.phase}-result.json').writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'phase': widget.phase,
        'passed': passed,
        'checks': checks,
        'identity': widget.info['identity'],
        'pid': pid,
        'atUTC': DateTime.now().toUtc().toIso8601String(),
        'networkUsed': false,
        'cpsUsed': false,
        'businessDatabaseOpened': false,
      }),
      flush: true,
    );
    if (mounted) setState(() => done = true);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: Colors.teal),
    home: Scaffold(
      appBar: AppBar(title: const Text('ABAK — Préférences natives isolées')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recette synthétique — aucune fonction métier démarrée.',
            ),
            const Text(
              'Préférences macOS et autorisations de dossiers de cette copie uniquement.',
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Expanded(
              child: ListView(
                children: checks.map((c) => Text('✓ $c')).toList(),
              ),
            ),
            FilledButton(
              onPressed: !done
                  ? null
                  : () async {
                      await const MethodChannel(
                        'abak/directory_access',
                      ).invokeMethod<void>('releaseAll');
                      await widget.lock.close();
                      await windowManager.close();
                    },
              child: const Text('Fermer la recette'),
            ),
          ],
        ),
      ),
    ),
  );
}
