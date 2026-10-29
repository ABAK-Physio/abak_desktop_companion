import 'dart:convert';
import '../../dmp_setup/bundled_pdf_tools.dart';
import '../../dmp_setup/dmp_setup_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/episode_document_version.dart';
import '../services/document_controls_service.dart';
import '../services/document_tools_access.dart';
import '../services/final_pdf_document_service.dart';

Future<bool> configureDocumentControls(
  BuildContext context,
  DocumentControlsService service,
) async {
  final cfg = await service.configuration();
  if (!context.mounted) return false;
  final old = cfg == null
      ? <String, String>{}
      : Map<String, String>.from(
          jsonDecode(cfg['data_json'] as String)['paths'],
        );
  if (await DmpSetupService(
    database: service.medical.pdf.database,
  ).managedEnabled()) {
    final tools = await BundledPdfTools.load();
    old['java'] = tools.java;
    old['vera'] = tools.vera;
  }
  if (!context.mounted) return false;
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _ControlConfig(
          initial: old,
          service: service,
          expectedRevision: cfg?['revision'] as int? ?? 0,
        ),
      ) ??
      false;
}

class DocumentControlsPanel extends StatefulWidget {
  const DocumentControlsPanel({
    super.key,
    required this.service,
    required this.version,
    required this.enabled,
  });
  final DocumentControlsService service;
  final EpisodeDocumentVersion version;
  final bool enabled;
  @override
  State<DocumentControlsPanel> createState() => _DocumentControlsPanelState();
}

class _DocumentControlsPanelState extends State<DocumentControlsPanel>
    with WidgetsBindingObserver {
  bool busy = false;
  DocumentControlStatus? status;
  PdfConversionStatus? conversion;
  String label = '', error = '';
  int refreshSequence = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(DocumentControlsPanel old) {
    super.didUpdateWidget(old);
    if (old.version.id != widget.version.id) {
      conversion = null;
      status = null;
      error = '';
      label = '';
    }
    if (old.enabled != widget.enabled || old.version.id != widget.version.id) {
      refresh();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !busy) refresh();
  }

  Future<void> refresh() async {
    final sequence = ++refreshSequence;
    final version = widget.version;
    final converted = await widget.service.medical.pdf.conversionStatus(
      version,
    );
    if (!mounted ||
        sequence != refreshSequence ||
        widget.version.id != version.id) {
      return;
    }
    setState(() => conversion = converted);
    try {
      final result = await widget.service.status(version);
      final cfg = await widget.service.configuration();
      final title = cfg == null
          ? 'Outils locaux non configurés'
          : jsonDecode(cfg['data_json'] as String)['paths']['label'];
      if (mounted &&
          sequence == refreshSequence &&
          widget.version.id == version.id) {
        setState(() {
          status = result;
          label = title;
          error = '';
        });
      }
    } catch (e) {
      if (mounted && sequence == refreshSequence) {
        setState(() {
          status = null;
          error = 'Contrôles après validation indisponibles : $e';
        });
      }
    }
  }

  String get controlsLabel {
    final current = status;
    if (current == null) {
      return error.isNotEmpty
          ? 'PDF/A et CDA : état indisponible.'
          : 'PDF/A et CDA : lecture des preuves conservées…';
    }
    if (!widget.enabled && current.run == null) {
      return 'PDF/A et CDA : en attente de validation médicale.';
    }
    final prefix = widget.enabled ? '' : 'Derniers contrôles enregistrés — ';
    return '${prefix}PDF/A : ${DocumentControlStatus.label(current.pdfa)} · CDA : ${DocumentControlStatus.label(current.cda)}';
  }

  Future<void> action(Future<void> Function() fn) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = '';
    });
    try {
      await fn();
      await refresh();
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> configure() => action(() async {
    await configureDocumentControls(context, widget.service);
  });
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Contrôles techniques locaux',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'PDF/A à la conversion du DOCX',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Text(
            conversion?.message ?? 'Lecture de la preuve de conversion…',
            key: const Key('conversion-pdfa-status'),
          ),
          if (conversion?.convertedAt != null)
            Text(
              'PDF version ${widget.version.number} · conversion du ${DateTime.fromMillisecondsSinceEpoch(conversion!.convertedAt!).toLocal()}',
            ),
          const Text(
            'Ce résultat porte sur la conversion du PDF. Il ne vaut ni validation médicale ni contrôle du CDA.',
          ),
          const Divider(),
          Text(
            'Contrôles PDF/A et CDA après validation médicale',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Text(label),
          const Text(
            'PDF/A-1b · CDA : schéma et cinq profils locaux. Aucun envoi ni accès CPS. Le classement documentaire reste déclaré.',
          ),
          Text(controlsLabel, key: const Key('native-control-status')),
          if (!widget.enabled)
            const Text(
              'Ces contrôles nécessitent un contexte enregistré et une validation médicale courante. Les résultats antérieurs ne couvrent pas des modifications non enregistrées.',
            ),
          if (status != null) Text(status!.message),
          if (status?.run != null)
            Text('Preuve locale : ${status!.run!['run_id']}'),
          if (error.isNotEmpty)
            Text(error, key: const Key('native-control-error')),
          if (busy) const LinearProgressIndicator(),
          OutlinedButton(
            key: const Key('configure-native-controls'),
            onPressed: busy ? null : configure,
            child: const Text('Configurer les outils et références locaux'),
          ),
          FilledButton(
            key: const Key('run-native-controls'),
            onPressed: busy || !widget.enabled
                ? null
                : () => action(() async {
                    final result = await widget.service.run(widget.version);
                    if (mounted) setState(() => status = result);
                  }),
            child: const Text('Contrôler ce PDF et son CDA hors réseau'),
          ),
          OutlinedButton(
            key: const Key('refresh-native-controls'),
            onPressed: busy ? null : () => action(refresh),
            child: const Text('Vérifier les preuves conservées'),
          ),
          if (status?.result != null)
            ExpansionTile(
              title: const Text('Rapports de contrôle PDF/A et CDA conservés'),
              children: [
                for (final entry in (status!.result!['files'] as Map).entries)
                  ListTile(
                    dense: true,
                    title: Text(entry.key),
                    subtitle: Text('Empreinte : ${entry.value}'),
                  ),
              ],
            ),
        ],
      ),
    ),
  );
}

class _ControlConfig extends StatefulWidget {
  const _ControlConfig({
    required this.initial,
    required this.service,
    required this.expectedRevision,
  });
  final Map<String, String> initial;
  final DocumentControlsService service;
  final int expectedRevision;
  @override
  State<_ControlConfig> createState() => _ControlConfigState();
}

class _ControlConfigState extends State<_ControlConfig> {
  late Map<String, TextEditingController> fields;
  bool busy = false;
  String error = '', progress = '';
  static const labels = {
    'office': 'LibreOffice.app — conversion DOCX (facultatif)',
    'java': 'Exécutable Java 17 ou supérieur',
    'vera': 'Fichier CLI .jar de veraPDF',
    'references': 'Dossier des références CDA locales',
    'label': 'Nom et version des références locales',
  };
  @override
  void initState() {
    super.initState();
    fields = {
      for (final k in labels.keys)
        k: TextEditingController(text: widget.initial[k] ?? ''),
    };
  }

  @override
  void dispose() {
    for (final c in fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> pick(String key) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = '';
      progress = 'Choix et autorisation de lecture…';
    });
    try {
      final path = await DocumentToolsAccess.choose(
        key,
        fields[key]!.text.trim(),
      );
      if (path != null && mounted) fields[key]!.text = path;
    } catch (e) {
      if (mounted) setState(() => error = _errorMessage(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  String _errorMessage(Object e) {
    if (e is PlatformException) {
      return '${e.message ?? 'Accès local refusé.'}'
          '${e.details is String ? '\n${e.details}' : ''}';
    }
    if (e is StateError) return e.message;
    return '$e';
  }

  Future<void> save() async {
    if (busy) return;
    final paths = {for (final e in fields.entries) e.key: e.value.text.trim()};
    setState(() {
      busy = true;
      error = '';
      progress = 'Préparation des autorisations de lecture…';
    });
    try {
      final authorized = await DocumentToolsAccess.authorize(
        paths,
        onStep: (message) {
          if (mounted) setState(() => progress = message);
        },
      );
      if (!authorized) {
        if (mounted) {
          setState(
            () => error =
                'Autorisation annulée. Vos saisies sont conservées ; la configuration n’a pas été enregistrée.',
          );
        }
        return;
      }
      if (mounted) {
        setState(
          () =>
              progress = 'Vérification des fichiers locaux et enregistrement…',
        );
      }
      await widget.service.configure(
        paths,
        expectedRevision: widget.expectedRevision,
      );
      if (!mounted) return;
      // Close only after the configuration transaction has committed.
      setState(() => busy = false);
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(
          () => error =
              'Enregistrement non effectué. ${_errorMessage(e)}\nVos saisies sont conservées.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: AlertDialog(
      title: const Text('Outils de contrôle locaux'),
      content: SizedBox(
        width: 650,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Indiquez les outils installés et les références archivées. Lors de l’enregistrement, macOS vous demandera d’autoriser la lecture des dossiers nécessaires. Aucun téléchargement. Un changement impose de nouveaux contrôles. Aucun résultat ne valide à lui seul l’envoi au DMP.',
              ),
              for (final item in labels.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextField(
                    controller: fields[item.key],
                    readOnly: busy,
                    decoration: InputDecoration(
                      labelText: item.value,
                      helperText: switch (item.key) {
                        'java' =>
                          'Le bouton dossier permet de choisir le dossier Home du JDK.',
                        'vera' =>
                          'Le bouton dossier permet de choisir le dossier contenant le CLI de veraPDF.',
                        _ => null,
                      },
                      suffixIcon: item.key == 'label'
                          ? null
                          : IconButton(
                              onPressed: busy ? null : () => pick(item.key),
                              tooltip: 'Choisir et autoriser en lecture seule',
                              icon: const Icon(Icons.folder_open),
                            ),
                    ),
                  ),
                ),
              if (busy) ...[
                const LinearProgressIndicator(),
                const SizedBox(height: 8),
                Text(progress),
              ],
              if (error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SelectableText(
                    error,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.pop(context, false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: busy ? null : save,
          child: Text(busy ? 'Veuillez patienter…' : 'Vérifier et enregistrer'),
        ),
      ],
    ),
  );
}
