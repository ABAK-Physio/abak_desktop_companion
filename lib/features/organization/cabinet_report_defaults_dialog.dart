import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../core/settings/report_prefill_settings.dart';

class CabinetReportDefaultsDialog extends StatefulWidget {
  const CabinetReportDefaultsDialog({
    super.key,
    required this.database,
    required this.cabinetId,
  });
  final Future<Database> Function() database;
  final String cabinetId;
  @override
  State<CabinetReportDefaultsDialog> createState() =>
      _CabinetReportDefaultsDialogState();
}

class _CabinetReportDefaultsDialogState
    extends State<CabinetReportDefaultsDialog> {
  final fields = {
    for (final key in ReportPrefillSettings.cabinetFields)
      key: TextEditingController(),
  };
  Map<String, String>? previous;
  bool busy = true, custom = false, customLanguage = false;
  String error = '';
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    for (final c in fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> load() async {
    try {
      final result = await ReportPrefillSettings.read(
        await widget.database(),
        'cabinet',
        widget.cabinetId,
      );
      if (!mounted) return;
      for (final e in result.entries) {
        fields[e.key]!.text = e.value;
      }
      setState(() {
        previous = result;
        custom = result['typeCode']!.isNotEmpty && !isFollowUp;
        customLanguage =
            result['language']!.isNotEmpty && result['language'] != 'fr-FR';
      });
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  bool get isFollowUp => ReportPrefillSettings.followUpReport.entries.every(
    (e) => fields[e.key]!.text == e.value,
  );
  Future<void> save() async {
    setState(() {
      busy = true;
      error = '';
    });
    try {
      await ReportPrefillSettings.save(
        await widget.database(),
        'cabinet',
        widget.cabinetId,
        {for (final e in fields.entries) e.key: e.value.text},
        previous!,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Widget field(String key, String label) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: fields[key],
      enabled: !busy,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: (_) {
        if (key != 'language') setState(() => custom = true);
      },
    ),
  );
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Préremplissage des rapports du cabinet'),
    content: SizedBox(
      width: 650,
      height: 500,
      child: Column(
        children: [
          if (busy) const LinearProgressIndicator(),
          Expanded(
            child: ListView(
              children: [
                const Text(
                  'Ces préférences sont communes aux rapports de ce cabinet, quel que soit le kiné rédacteur ou signataire. Choisissez une fois le classement habituel : ses codes et sa référence seront repris ensemble, sans ressaisie dans chaque rapport. Les contextes déjà enregistrés restent inchangés. La date clinique, la visibilité et la validation restent propres à chaque document.',
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  key: ValueKey(
                    'language-$customLanguage-${fields['language']!.text}',
                  ),
                  initialValue: customLanguage
                      ? 'other'
                      : fields['language']!.text.isEmpty
                      ? ''
                      : 'fr-FR',
                  decoration: const InputDecoration(
                    labelText: 'Langue habituelle des rapports',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: '',
                      child: Text('À choisir dans chaque rapport'),
                    ),
                    DropdownMenuItem(value: 'fr-FR', child: Text('Français')),
                    DropdownMenuItem(
                      value: 'other',
                      child: Text('Autre langue'),
                    ),
                  ],
                  onChanged: busy
                      ? null
                      : (v) => setState(() {
                          customLanguage = v == 'other';
                          fields['language']!.text = customLanguage
                              ? ''
                              : v ?? '';
                        }),
                ),
                if (customLanguage) field('language', 'Code de langue'),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  key: ValueKey('classification-$custom-$isFollowUp'),
                  initialValue: custom
                      ? 'other'
                      : isFollowUp
                      ? 'followup'
                      : '',
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Classement habituel des rapports',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: '',
                      child: Text('À choisir dans chaque rapport'),
                    ),
                    DropdownMenuItem(
                      value: 'followup',
                      child: Text(
                        'Compte rendu de suivi de soins par auxiliaire médical',
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'other',
                      child: Text('Autre classement à renseigner'),
                    ),
                  ],
                  onChanged: busy
                      ? null
                      : (v) => setState(() {
                          custom = v == 'other';
                          for (final key
                              in ReportPrefillSettings.classificationFields) {
                            fields[key]!.text = v == 'followup'
                                ? ReportPrefillSettings.followUpReport[key]!
                                : '';
                          }
                        }),
                ),
                if (isFollowUp) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Type : CR ou fiche de suivi de soins par auxiliaire médical. Classe : Compte rendu.',
                  ),
                  const Text(
                    'Proposition issue des références ANS archivées. À utiliser si elle décrit le rapport ; les contrôles DMP restent nécessaires.',
                  ),
                  ExpansionTile(
                    title: const Text('Identification ANS des référentiels'),
                    children: [
                      for (final resource
                          in ReportPrefillSettings.followUpCatalogs)
                        ListTile(
                          title: Text(resource['name']!),
                          subtitle: SelectableText(
                            'OID : ${resource['oid']}\nMise à jour indiquée par l’ANS : ${resource['updatedAt']}\nSource : ${resource['source']}\nEmpreinte SHA-256 : ${resource['sha256']}',
                          ),
                        ),
                      const Text(
                        'Ces identifications seront conservées avec les nouveaux contextes utilisant ce classement. Les préparations et validations anciennes gardent leurs propres références.',
                      ),
                    ],
                  ),
                ],
                if (custom || isFollowUp)
                  ExpansionTile(
                    title: const Text('Codes et référence du classement'),
                    initiallyExpanded: custom,
                    children: [
                      field('typeLabel', 'Libellé du type'),
                      field('typeCode', 'Code du type'),
                      field('typeSystem', 'Système de codage du type'),
                      field('classLabel', 'Libellé de la classe'),
                      field('classCode', 'Code de la classe'),
                      field('classSystem', 'Système de codage de la classe'),
                      field(
                        'catalogReference',
                        'Référence et version du référentiel',
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (error.isNotEmpty)
            Text(
              error,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: busy ? null : () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
      FilledButton(
        onPressed: busy || previous == null ? null : save,
        child: const Text('Enregistrer ces préférences'),
      ),
    ],
  );
}
