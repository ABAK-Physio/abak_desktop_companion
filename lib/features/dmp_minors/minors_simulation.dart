import 'dart:convert';
import 'dart:io';
import '../dmp_resources/dmp_resources.dart';

/// Closed set of fictitious identities: no INS, CPS or transport dependency.
enum SimPatient { child, threshold, adult, unknown, future }

class MinorContext {
  const MinorContext({
    this.patient = SimPatient.child,
    this.professional = 'PS fictif A',
    required this.today,
    this.majority = 18,
    this.enabled = true,
    this.cumulative = false,
    this.parametersValid = true,
  });
  factory MinorContext.fromParameters({
    required DateTime today,
    required DmpParameters? parameters,
    SimPatient patient = SimPatient.child,
    String professional = 'PS fictif A',
  }) => MinorContext(
    today: today,
    patient: patient,
    professional: professional,
    majority: parameters?.majority ?? 0,
    enabled: parameters?.minors ?? false,
    cumulative: parameters?.cumulative ?? false,
    parametersValid: parameters != null,
  );
  final SimPatient patient;
  final String professional;
  final DateTime today;
  final int majority;
  final bool enabled, cumulative, parametersValid;
  DateTime? get birth => switch (patient) {
    SimPatient.child => DateTime.utc(2014, 10, 16),
    SimPatient.threshold => DateTime.utc(2008, 10, 16),
    SimPatient.adult => DateTime.utc(2006, 10, 16),
    SimPatient.unknown => null,
    SimPatient.future => DateTime.utc(2027),
  };
  int? get age {
    final b = birth, d = DateTime.utc(today.year, today.month, today.day);
    if (b == null || b.isAfter(d)) return null;
    return d.year -
        b.year -
        ((d.month < b.month || (d.month == b.month && d.day < b.day)) ? 1 : 0);
  }

  bool get valid =>
      parametersValid && majority > 0 && majority <= 120 && age != null;
  bool get minor => valid && age! < majority;
  bool get secretAvailable => minor && enabled;
  String get message {
    if (!parametersValid || majority < 1 || majority > 120) {
      return 'Aucun paramètre validé. Actions dépendantes indisponibles.';
    }
    if (birth == null) {
      return 'Âge inconnu : corrigez la naissance fictive. Actions suspendues.';
    }
    if (age == null) {
      return 'Date de naissance incohérente. Actions suspendues.';
    }
    if (!enabled) {
      return 'Âge : $age ans. Fonctions mineurs désactivées ; aucune connexion secrète proposée.';
    }
    return 'Âge : $age ans. ${minor ? "Mineur" : "Majeur"} au seuil simulé de $majority ans.';
  }
}

class SimDocument {
  const SimDocument({
    required this.id,
    required this.patient,
    this.rlVisible = false,
    this.patientVisible = false,
    this.maskedPs = false,
  });
  final String id;
  final SimPatient patient;
  final bool rlVisible, patientVisible, maskedPs;
  Map<String, Object> toJson() => {
    'id': id,
    'patient': patient.name,
    'rlVisible': rlVisible,
    'patientVisible': patientVisible,
    'maskedPs': maskedPs,
  };
  factory SimDocument.fromJson(Map<String, dynamic> j) {
    if (j['id'] is! String ||
        !(j['id'] as String).startsWith('SIM-') ||
        j['rlVisible'] is! bool ||
        j['patientVisible'] is! bool ||
        j['maskedPs'] is! bool) {
      throw const FormatException('Document fictif invalide');
    }
    return SimDocument(
      id: j['id'],
      patient: SimPatient.values.byName(j['patient']),
      rlVisible: j['rlVisible'],
      patientVisible: j['patientVisible'],
      maskedPs: j['maskedPs'],
    );
  }
}

/// Only a dedicated simulation file. No access to other ABAK stores.
class MinorSimulationStore {
  MinorSimulationStore(this.directory);
  final Directory directory;
  File get file => File('${directory.path}/documents-fictifs.json');
  List<SimDocument> read() {
    if (!file.existsSync()) return [];
    final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    if (data['scope'] != 'ABAK-MINEURS-SIMULATION-1') {
      throw const FormatException('Stockage incompatible');
    }
    final docs = (data['documents'] as List)
        .map((v) => SimDocument.fromJson(Map<String, dynamic>.from(v)))
        .toList();
    if (docs.map((d) => d.id).toSet().length != docs.length) {
      throw const FormatException('Doublon');
    }
    return docs;
  }

  void save(SimDocument doc) {
    if (!doc.id.startsWith('SIM-')) {
      throw StateError('Identifiant fictif requis.');
    }
    final docs = read();
    final previous = docs.where((d) => d.id == doc.id).firstOrNull;
    if (previous != null &&
        (previous.patient != doc.patient ||
            (previous.rlVisible && !doc.rlVisible) ||
            (previous.patientVisible && !doc.patientVisible))) {
      throw StateError('Visibilité acquise conservée. Remasquage refusé.');
    }
    docs.removeWhere((d) => d.id == doc.id);
    docs.add(doc);
    directory.createSync(recursive: true);
    final pending = File('${file.path}.pending');
    pending.writeAsStringSync(
      jsonEncode({
        'scope': 'ABAK-MINEURS-SIMULATION-1',
        'documents': docs.map((d) => d.toJson()).toList(),
      }),
      flush: true,
    );
    pending.renameSync(file.path);
  }
}

class SemanticPreview {
  const SemanticPreview(this.revision, this.secret, this.document);
  final int revision;
  final bool secret;
  final SimDocument document;
  String get text =>
      'SIMULATION — aperçu sémantique non signé, sans VIHF utilisable. '
      '${secret ? "Connexion secrète" : "Connexion normale"}. '
      'Patient fictif : ${document.patient.name}. '
      'Représentants légaux : ${document.rlVisible ? "visible" : "invisible"}. '
      'Patient : ${document.patientVisible ? "visible" : "invisible"}. '
      'Professionnels : ${document.maskedPs ? "masqué" : "non masqué"}.';
}

class MinorSession {
  MinorSession(MinorContext context) : _context = context;
  MinorContext _context;
  MinorContext get context => _context;
  bool? _secret;
  bool? get secretChoice => _secret;
  bool _opposition = false;
  bool get opposition => _opposition;
  int _revision = 0;
  SemanticPreview? preview;
  static const information =
      'La connexion secrète protège les traces de cette session vis-à-vis des représentants légaux et impose des documents invisibles pour eux. En connexion normale, un document peut aussi être invisible aux représentants légaux. Aucun droit de consultation supplémentaire n’est accordé.';
  void invalidate() {
    _revision++;
    preview = null;
  }

  void changeContext(MinorContext value) {
    _context = value;
    _secret = null;
    invalidate();
  }

  void setOpposition(bool value) {
    _opposition = value;
    invalidate();
  }

  void choose(bool secret) {
    if (!_context.valid || (secret && !_context.secretAvailable)) {
      throw StateError('Connexion secrète indisponible dans ce contexte.');
    }
    _secret = secret;
    invalidate();
  }

  bool get ready =>
      _context.valid && (!_context.secretAvailable || _secret != null);
  SemanticPreview prepare({
    required String id,
    bool rlVisible = false,
    bool patientVisible = false,
    bool maskedPs = false,
    SimDocument? replacing,
    bool confirmedVisibilityChange = false,
  }) {
    invalidate();
    if (!ready) {
      throw StateError(
        'Contexte incomplet : choisissez une connexion normale ou secrète.',
      );
    }
    if (_opposition && replacing == null) {
      throw StateError('Opposition : nouveau dépôt simulé bloqué.');
    }
    if (!id.startsWith('SIM-')) throw StateError('Document fictif requis.');
    if (replacing != null && replacing.id != id) {
      throw StateError('Identifiant de remplacement incohérent.');
    }
    if (replacing != null && replacing.patient != _context.patient) {
      throw StateError('Document lié à un autre patient fictif.');
    }
    if (_secret == true && replacing?.rlVisible == true) {
      throw StateError(
        'Conflit : document déjà visible aux représentants légaux. Remplacement bloqué en connexion secrète.',
      );
    }
    if (_secret == true && rlVisible) {
      throw StateError(
        'Connexion secrète : invisibilité aux représentants légaux obligatoire.',
      );
    }
    if (replacing != null &&
        ((replacing.rlVisible && !rlVisible) ||
            (replacing.patientVisible && !patientVisible))) {
      throw StateError(
        'Visibilité acquise conservée. Remasquage par remplacement refusé.',
      );
    }
    if (replacing != null &&
        !confirmedVisibilityChange &&
        ((!replacing.rlVisible && rlVisible) ||
            (!replacing.patientVisible && patientVisible))) {
      throw StateError(
        'Confirmation requise : rendre visible est irréversible.',
      );
    }
    if (!_context.cumulative && !patientVisible && maskedPs) {
      throw StateError(
        'Cumul invisible patient et masqué professionnels interdit par les paramètres simulés.',
      );
    }
    return preview = SemanticPreview(
      _revision,
      _secret == true,
      SimDocument(
        id: id,
        patient: _context.patient,
        rlVisible: rlVisible,
        patientVisible: patientVisible,
        maskedPs: maskedPs,
      ),
    );
  }

  bool current(SemanticPreview value) =>
      identical(preview, value) && value.revision == _revision;
  void retain(SemanticPreview value, MinorSimulationStore store) {
    if (!current(value)) {
      throw StateError('Aperçu périmé : préparez à nouveau.');
    }
    store.save(value.document);
  }

  SimDocument reveal(
    SimDocument doc, {
    required bool representatives,
    required bool confirmed,
  }) {
    if (!ready || doc.patient != context.patient) {
      throw StateError('Contexte du document indisponible.');
    }
    if (representatives && _secret == true) {
      throw StateError(
        'Connexion secrète : rendre visible aux représentants légaux est interdit.',
      );
    }
    if (!confirmed) return doc;
    invalidate();
    return SimDocument(
      id: doc.id,
      patient: doc.patient,
      rlVisible: representatives || doc.rlVisible,
      patientVisible: !representatives || doc.patientVisible,
      maskedPs: doc.maskedPs,
    );
  }
}
