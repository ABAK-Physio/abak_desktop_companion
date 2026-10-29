// Executed only by a signed recipe identity in explicit synthetic maintenance.
// UserDefaults is restored by the guarded native API, never by copying plists.
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../settings/exchange_directory_service.dart';
import '../settings/macos_directory_access_service.dart';
import '../settings/macos_launch_history_service.dart';
import '../settings/language_preference_service.dart';
import 'maintenance_session.dart';

class CoordinatedRecipePanel extends StatefulWidget {
  const CoordinatedRecipePanel({super.key, required this.request});
  final StartupRequest request;
  @override
  State<CoordinatedRecipePanel> createState() => _CoordinatedRecipePanelState();
}

class _CoordinatedRecipePanelState extends State<CoordinatedRecipePanel> {
  static const native = MethodChannel('abak/preferences_recipe');
  final checks = <String>[];
  String message = 'Recette coordonnée en cours…';
  String get root => widget.request.syntheticRoot!;
  String get phase => widget.request.coordinatedPhase!;
  late SharedPreferences prefs;
  File file(String relative) => File('$root/$relative');
  void check(bool value, String label) {
    if (!value) throw StateError(label);
    checks.add(label);
  }

  Future<Map<String, dynamic>> read(String path) async =>
      Map<String, dynamic>.from(
        jsonDecode(await file(path).readAsString()) as Map,
      );
  Future<Map<String, dynamic>> snapshot() async =>
      (await native.invokeMapMethod<String, dynamic>('snapshot'))!;
  Future<void> write(String name, Object value) async {
    final target = file('observations/$name.json');
    if (await target.exists()) throw StateError('Observation déjà présente.');
    await target.writeAsString(jsonEncode(value), flush: true);
  }

  Future<void> bookmark(String target) async {
    final access = await ExchangeDirectoryService().acquireExchangeDirectory();
    try {
      check(
        access.directory.path == target,
        'Dossier synthétique exact retrouvé',
      );
      check(
        await File('$target/SYNTHETIC-ONLY').readAsString() ==
            'ABAK-BOOKMARKS-SYNTHETIC-V1\n',
        'Signet natif utilisable après restauration',
      );
    } finally {
      await access.release();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => run());
  }

  Future<void> run() async {
    var passed = false;
    try {
      final context = (await native.invokeMapMethod<String, dynamic>(
        'context',
      ))!;
      final identity = context['identity'] as String;
      final target = context['target'] as String;
      check(
        identity.startsWith('fr.abakphysio.maintenance.recipe.'),
        'Identité native de recette distincte',
      );
      check(
        target.contains('/abak-bookmarks-') && !target.startsWith('$root/'),
        'Dossier de signet distinct du dossier de maintenance autorisé',
      );
      prefs = await SharedPreferences.getInstance();
      final directories = const MacosDirectoryAccessService();
      if (phase == 'seed') {
        check(prefs.getKeys().isEmpty, 'Domaine natif initialement vide');
        final access = await directories.chooseDirectory(
          title: 'Recette : autoriser ${target.split('/').last}',
        );
        check(
          access?.path == target,
          'Sélection explicite du dossier synthétique',
        );
        await access!.release();
        await prefs.setString('exchange_directory_path', target);
        await const LanguagePreferenceService().setLanguageCode('fr');
        await prefs.setBool('recipe_hold', true);
        await prefs.setInt('recipe_counter', 7);
        await prefs.setDouble('recipe_scale', 1.25);
        await prefs.setStringList('recipe_list', ['PDF', 'CDA']);
        final history = await const MacosLaunchHistoryService()
            .inspectBeforeStartup();
        await const MacosLaunchHistoryService().markSuccessful(history);
        await bookmark(target);
        await write('seed-snapshot', await snapshot());
      } else if (phase == 'upgrade') {
        await const LanguagePreferenceService().setLanguageCode('en');
        await directories.forgetDirectory(target);
        await prefs.setBool('recipe_hold', false);
        await prefs.remove('recipe_list');
        await prefs.setString(
          'recipe_added',
          'nouvelle génération synthétique',
        );
        final history = await const MacosLaunchHistoryService()
            .inspectBeforeStartup();
        check(
          history.kind == MacosLaunchKind.updated,
          'Nouvelle génération détectée par le service produit',
        );
        await const MacosLaunchHistoryService().markSuccessful(history);
        await write('upgrade-snapshot', await snapshot());
      } else {
        final archive = await read('active/preferences/native.json');
        check(
          archive['identity'] == identity,
          'Sauvegarde native de la même identité',
        );
        Map<String, dynamic>? plan;
        if (phase != 'verify') {
          final bytes = await file('coordinated.pending.json').readAsBytes();
          check(
            sha256.convert(bytes).toString() == widget.request.rollbackPlanHash,
            'Plan de retour authentifié par son empreinte',
          );
          plan = Map<String, dynamic>.from(
            jsonDecode(utf8.decode(bytes)) as Map,
          );
          check(
            plan['identity'] == identity &&
                plan['targetPreferences'] == archive['sha256'] &&
                plan['targetArchiveHash'] ==
                    sha256
                        .convert(
                          await file(
                            'active/preferences/native.json',
                          ).readAsBytes(),
                        )
                        .toString(),
            'Préférences liées à la génération restaurée',
          );
        } else {
          check(
            !await file('coordinated.pending.json').exists(),
            'Aucun retour incomplet restant',
          );
        }
        final before = await snapshot();
        if (phase == 'blocked') {
          check(
            before['sha256'] == plan!['beforePreferences'],
            'Préférences de la génération récente encore présentes',
          );
          final history = await const MacosLaunchHistoryService()
              .inspectBeforeStartup();
          check(
            history.kind == MacosLaunchKind.olderVersion,
            'Ancienne application bloquée par son historique',
          );
          check(
            !prefs.containsKey('recipe_list') && !prefs.getBool('recipe_hold')!,
            'Génération mixte détectée',
          );
          check(
            (await snapshot())['sha256'] == before['sha256'],
            'Examen sans mutation des préférences',
          );
        } else {
          if (phase != 'verify') {
            check(
              before['sha256'] == plan!['beforePreferences'] ||
                  before['sha256'] == archive['sha256'],
              'Préférences dans un état prévu par le plan',
            );
            if (before['sha256'] != archive['sha256']) {
              await write('restore-intent', {
                'plan': widget.request.rollbackPlanHash,
                'before': before['sha256'],
              });
              await native.invokeMethod<void>('restore', {
                'archive': archive,
                'expected': before['sha256'],
              });
            } else {
              check(
                true,
                'Reprise idempotente : préférences déjà restaurées, aucune réécriture',
              );
            }
          }
          check(
            (await snapshot())['sha256'] == archive['sha256'],
            'Préférences natives identiques à la sauvegarde',
          );
          if (phase == 'restore-crash') {
            await write('interruption', {
              'passed': true,
              'checks': checks,
              'after': archive['sha256'],
            });
            exit(
              86,
            ); // Intentional abrupt process exit, after native synchronize.
          }
          await prefs.reload();
          check(
            await const LanguagePreferenceService().getLanguageCode() == 'fr' &&
                prefs.getBool('recipe_hold') == true &&
                prefs.getInt('recipe_counter') == 7 &&
                prefs.getDouble('recipe_scale') == 1.25 &&
                prefs.getStringList('recipe_list')!.join(',') == 'PDF,CDA' &&
                !prefs.containsKey('recipe_added'),
            'Valeurs et types de la génération précédente restaurés',
          );
          final history = await const MacosLaunchHistoryService()
              .inspectBeforeStartup();
          check(
            history.kind == MacosLaunchKind.unchanged,
            'Historique cohérent avec la version restaurée',
          );
          await bookmark(target);
          if (phase == 'recover') {
            await write('recovery-receipt', {
              'plan': widget.request.rollbackPlanHash,
              'identity': identity,
              'preferences': archive['sha256'],
              'bookmarkVerified': true,
              'history': history.kind.name,
              'passed': true,
            });
          }
        }
      }
      passed = true;
      message =
          'Recette $phase conforme. ${checks.length} contrôles. Aucun échange DMP.';
    } catch (error) {
      message = 'Reprise bloquée : $error';
    }
    await write(phase, {
      'passed': passed,
      'checks': checks,
      'message': message,
    });
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: SelectableText('$message\n${checks.join('\n')}'),
  );
}
