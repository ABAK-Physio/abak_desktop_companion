/// Isolated DMP configuration. No default transport, CPS or INSi dependency.
library;

import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:xml/xml.dart';

class ResourceReply {
  const ResourceReply(this.status, {this.body = '', this.location, this.etag});
  final int status;
  final String body;
  final String? location, etag;
}

abstract interface class ResourceTransport {
  Future<ResourceReply> get(Uri uri, String? etag);
}

abstract interface class ResourceStore {
  String? read();
  void commit(String value);
}

/// Caller must supply a dedicated directory; never uses application databases.
class FileResourceStore implements ResourceStore {
  FileResourceStore(this.directory);
  final Directory directory;
  File get _file => File('${directory.path}/dmp-resources.json');
  @override
  String? read() => _file.existsSync() ? _file.readAsStringSync() : null;
  @override
  void commit(String value) {
    directory.createSync(recursive: true);
    final temporary = File('${_file.path}.pending');
    temporary.writeAsStringSync(value, flush: true);
    temporary.renameSync(_file.path);
  }
}

class DmpParameters {
  DmpParameters(this.minors, this.majority, this.cumulative, this.unknown);
  final bool minors, cumulative;
  final int majority;
  final List<String> unknown;
  static DmpParameters parse(String text) {
    if (text.length > 1024 * 1024 ||
        RegExp(r'<!DOCTYPE|<!ENTITY', caseSensitive: false).hasMatch(text)) {
      throw const FormatException('Déclaration XML externe interdite.');
    }
    final root = XmlDocument.parse(text).rootElement;
    if (root.name.local != 'dmp-parameters' ||
        root.getAttribute('version') != '1.0') {
      throw const FormatException('Format de paramètres non reconnu.');
    }
    final lists = root
        .findElements('parameter-list')
        .where((e) => e.getAttribute('code') == 'param-si-dmp')
        .toList();
    if (lists.length != 1) {
      throw const FormatException('Liste de paramètres absente ou dupliquée.');
    }
    final values = <String, String>{};
    for (final e in lists.single.findElements('parameter')) {
      final code = e.getAttribute('code'), value = e.getAttribute('value');
      if (code == null || value == null || values.containsKey(code)) {
        throw const FormatException('Paramètre absent ou dupliqué.');
      }
      values[code] = value;
    }
    bool flag(String key) {
      final v = values[key];
      if (v != 'true' && v != 'false') {
        throw FormatException('Booléen invalide : $key');
      }
      return v == 'true';
    }

    final age = int.tryParse(values['age-majorite'] ?? '');
    if (age == null || age < 1 || age > 120) {
      throw const FormatException('Âge de majorité invalide.');
    }
    final months = int.tryParse(values['hr-periode-max-mois'] ?? '');
    if (months == null || months < 1) {
      throw const FormatException('Période invalide.');
    }
    return DmpParameters(
      flag('fonctions-gestion-mineurs'),
      age,
      flag('cumul-invisible_patient-masque_ps'),
      values.keys
          .where(
            (k) => !{
              'fonctions-gestion-mineurs',
              'age-majorite',
              'cumul-invisible_patient-masque_ps',
              'hr-periode-max-mois',
            }.contains(k),
          )
          .toList(),
    );
  }

  bool isMinor(DateTime birth, DateTime today) {
    if (birth.isAfter(today)) throw const FormatException('Naissance future.');
    var age = today.year - birth.year;
    if (today.month < birth.month ||
        (today.month == birth.month && today.day < birth.day)) {
      age--;
    }
    return minors && age < majority;
  }

  bool visibilityAllowed({required bool invisible, required bool masked}) =>
      cumulative || !(invisible && masked);
}

class ValueCatalog {
  ValueCatalog._(this.version, this.entries, this.associations);
  final String version;
  final Map<String, Map<String, dynamic>> entries;
  final Map<String, List<List<String>>> associations;
  static String key(String system, String code) => '$system\u0000$code';
  factory ValueCatalog.parse(String text) {
    final j = jsonDecode(text) as Map<String, dynamic>;
    final version = j['version'];
    if (version is! String ||
        version.isEmpty ||
        j['entries'] is! List ||
        (j['entries'] as List).isEmpty) {
      throw const FormatException('Catalogue incomplet.');
    }
    final entries = <String, Map<String, dynamic>>{};
    for (final raw in j['entries'] as List) {
      final e = Map<String, dynamic>.from(raw as Map);
      if ([
            'system',
            'code',
            'label',
          ].any((k) => e[k] is! String || (e[k] as String).isEmpty) ||
          e['active'] is! bool) {
        throw const FormatException('Valeur invalide.');
      }
      final k = key(e['system'], e['code']);
      if (entries.containsKey(k)) throw const FormatException('Code dupliqué.');
      entries[k] = Map.unmodifiable(e);
    }
    final associations = <String, List<List<String>>>{};
    for (final e in (j['associations'] as Map? ?? {}).entries) {
      associations[e.key as String] = (e.value as List).map((v) {
        final pair = List<String>.from(v as List);
        if (pair.length != 2 ||
            !entries.containsKey(pair[0]) ||
            !entries.containsKey(pair[1])) {
          throw const FormatException('Association invalide.');
        }
        return List<String>.unmodifiable(pair);
      }).toList();
    }
    return ValueCatalog._(
      version,
      Map.unmodifiable(entries),
      Map.unmodifiable(associations),
    );
  }
  bool canEmit(String system, String code) =>
      entries[key(system, code)]?['active'] == true;
  String display(String system, String code, {String? historicalLabel}) =>
      historicalLabel ??
      entries[key(system, code)]?['label'] as String? ??
      code;
  String triplet(String system, String code) {
    if (!canEmit(system, code)) {
      throw const FormatException('Code non autorisé à l’émission.');
    }
    return '$code^${display(system, code)}^$system';
  }

  bool matchesTriplet(String system, String code, String value) =>
      canEmit(system, code) && triplet(system, code) == value;
  bool related(String table, String left, String right) =>
      associations[table]?.any((p) => p[0] == left && p[1] == right) ?? false;
}

class DmpResources {
  DmpResources({
    required this.transport,
    required this.store,
    required this.now,
    required this.source,
    required Set<String> allowedHosts,
  }) : allowedHosts = Set.unmodifiable(allowedHosts) {
    final text = store.read();
    if (text != null) {
      try {
        final restored = Map<String, dynamic>.from(jsonDecode(text));
        for (final name in ['parameters', 'catalog']) {
          final entry = restored[name];
          if (entry != null) {
            if (digest(entry['body']) != entry['sha256']) {
              throw const FormatException('Cache altéré.');
            }
            if (name == 'parameters') {
              DmpParameters.parse(entry['body']);
            } else {
              ValueCatalog.parse(entry['body']);
            }
            DateTime.parse(entry['checkedAt']);
          }
        }
        _state = restored;
      } catch (_) {
        message = 'Cache DMP invalide. Fonctions dépendantes indisponibles.';
      }
    }
  }
  final ResourceTransport transport;
  final ResourceStore store;
  final DateTime Function() now;
  final Set<String> allowedHosts;
  Uri source;
  Map<String, dynamic> _state = {};
  int _request = 0, _catalogRevision = 0;
  String message = 'Ressources DMP non chargées.';
  String? parametersDiagnostic, catalogDiagnostic;

  String _failureMessage(Object error, {required bool isCatalog}) {
    if (error is TimeoutException) {
      return 'Le service ne répond pas dans le délai prévu.';
    }
    if (error is HandshakeException) {
      return 'La connexion sécurisée n’a pas pu être vérifiée.';
    }
    if (error is FileSystemException) return 'L’enregistrement local a échoué.';
    if (error is StateError &&
        RegExp(r'^HTTP [0-9]{3}$').hasMatch(error.message.toString())) {
      return 'Le service est indisponible (${error.message}).';
    }
    return isCatalog
        ? 'Le fichier de nomenclatures est invalide ou n’a pas pu être vérifié.'
        : 'Les paramètres reçus sont invalides ou n’ont pas pu être vérifiés.';
  }

  static String digest(String body) =>
      sha256.convert(utf8.encode(body)).toString();
  DmpParameters? get parameters => _state['parameters'] == null
      ? null
      : DmpParameters.parse(_state['parameters']['body']);
  ValueCatalog? get catalog => _state['catalog'] == null
      ? null
      : ValueCatalog.parse(_state['catalog']['body']);
  DateTime? get lastSuccess => _state['parameters'] == null
      ? null
      : DateTime.parse(_state['parameters']['checkedAt']);
  bool get due =>
      lastSuccess == null ||
      _state['parameters']['source'] != source.toString() ||
      now().toUtc().isBefore(lastSuccess!) ||
      now().toUtc().difference(lastSuccess!) >= const Duration(days: 7);
  bool get hasUsableParameters => parameters != null;
  bool _approved(Uri uri) =>
      uri.scheme == 'https' &&
      allowedHosts.contains(uri.host) &&
      uri.userInfo.isEmpty &&
      uri.fragment.isEmpty &&
      (uri.port == 443);
  void _commit(String kind, Map<String, dynamic> value) {
    final next = {..._state, kind: value};
    store.commit(
      jsonEncode(next),
    ); // state changes only after successful atomic save
    _state = next;
  }

  void cancelPendingRefresh() {
    _request++;
  }

  Future<void> refreshIfDue() async {
    if (due) await refresh();
  }

  Future<void> refresh() async {
    final ticket = ++_request;
    final original = source;
    var uri = original;
    final seen = <String>{};
    try {
      for (var i = 0; i < 6; i++) {
        if (!_approved(uri) || !seen.add(uri.toString())) {
          throw const FormatException('Redirection non autorisée ou répétée.');
        }
        final old = _state['parameters'];
        final same = old != null && old['finalUrl'] == uri.toString();
        final reply = await transport.get(uri, same ? old['etag'] : null);
        if (ticket != _request || source != original) return;
        if ({301, 302, 303, 307, 308}.contains(reply.status)) {
          if (reply.location == null) {
            throw const FormatException('Redirection sans destination.');
          }
          uri = uri.resolve(reply.location!);
          continue;
        }
        if (reply.status == 304) {
          if (!same || old['etag'] == null) {
            throw const FormatException(
              'Réponse 304 sans cache correspondant.',
            );
          }
          _commit('parameters', {
            ...Map<String, dynamic>.from(old),
            'checkedAt': now().toUtc().toIso8601String(),
          });
        } else {
          if (reply.status != 200) throw StateError('HTTP ${reply.status}');
          final p = DmpParameters.parse(reply.body);
          _commit('parameters', {
            'body': reply.body,
            'sha256': digest(reply.body),
            'source': original.toString(),
            'finalUrl': uri.toString(),
            'etag': reply.etag,
            'checkedAt': now().toUtc().toIso8601String(),
          });
          message = p.unknown.isEmpty
              ? 'Paramètres DMP actualisés.'
              : 'Paramètres DMP actualisés. Paramètre inconnu conservé sans effet.';
        }
        if (reply.status == 304) {
          message = 'Paramètres DMP vérifiés, inchangés.';
        }
        parametersDiagnostic = null;
        return;
      }
      throw const FormatException('Trop de redirections.');
    } catch (e) {
      if (ticket != _request) return;
      parametersDiagnostic = e.toString();
      message =
          'Dernière tentative de mise à jour des paramètres : échec. ${_failureMessage(e, isCatalog: false)} ${parameters == null ? "Aucun cache valide disponible. Fonctions dépendantes indisponibles." : "Dernière configuration valide conservée."}';
    }
  }

  int beginCatalogUpdate() => ++_catalogRevision;
  bool installCatalog(
    String body, {
    required int ticket,
    required String expectedHash,
    required String provenance,
  }) {
    if (ticket != _catalogRevision) return false;
    try {
      if (provenance.isEmpty || digest(body) != expectedHash) {
        throw const FormatException('Intégrité ou provenance invalide.');
      }
      ValueCatalog.parse(body);
      _commit('catalog', {
        'body': body,
        'sha256': expectedHash,
        'source': provenance,
        'checkedAt': now().toUtc().toIso8601String(),
      });
      catalogDiagnostic = null;
      message = 'Dernière mise à jour des nomenclatures : réussie.';
      return true;
    } catch (e) {
      catalogDiagnostic = e.toString();
      message =
          'Dernière mise à jour des nomenclatures : refusée. ${_failureMessage(e, isCatalog: true)} ${catalog == null ? "Aucune version valide disponible." : "Version précédente conservée."}';
      return false;
    }
  }
}
