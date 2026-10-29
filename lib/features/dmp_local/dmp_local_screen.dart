import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../cps/cps_access_service.dart';
import '../cps/cps_profile.dart';
import '../cps/cps_signature_pin_dialog.dart';
import 'dmp_local_lot.dart';

class DmpLocalScreen extends StatefulWidget {
  const DmpLocalScreen({
    super.key,
    required this.profile,
    required this.situation,
    required this.certificateBase64,
  });
  final CpsProfile profile;
  final CpsSituation situation;
  final String certificateBase64;
  @override
  State<DmpLocalScreen> createState() => _DmpLocalScreenState();
}

class _DmpLocalScreenState extends State<DmpLocalScreen> {
  DmpLocalLot? _lot;
  String? _error, _exported;
  bool _busy = true;
  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare({bool replacement = false}) async {
    setState(() {
      _busy = true;
      _error = null;
      _exported = null;
      _lot = null;
    });
    try {
      final templates = await Future.wait([
        rootBundle.loadString('assets/dmp_local/cda-example.xml'),
        rootBundle.loadString('assets/dmp_local/registry-example.xml'),
      ]);
      final lot = DmpLocalLot.prepare(
        replacement: replacement,
        profile: widget.profile,
        situation: widget.situation,
        certificateBase64: widget.certificateBase64,
        cdaTemplate: templates[0],
        registryTemplate: templates[1],
      );
      if (mounted) setState(() => _lot = lot);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sign() async {
    if (_busy || _lot == null || _lot!.verified) return;
    var pin = await showDialog<String>(
      context: context,
      builder: (_) =>
          CpsSignaturePinDialog(profile: widget.profile, localLot: true),
    );
    if (pin == null || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      _lot!.verifyDigests();
      final result = await const CpsAccessService().signDmpLotLocal(
        pin,
        widget.profile.nationalId,
        _lot!.signedInfo,
        widget.certificateBase64,
      );
      _lot!.attachVerifiedSignature(result);
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        setState(() => _error = e is PlatformException ? e.message : '$e');
      }
    } finally {
      pin = null;
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _export() async {
    final lot = _lot;
    if (lot == null || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      lot.verifyDigests();
      final archive = Archive();
      lot.files.forEach((name, text) {
        final bytes = utf8.encode(text);
        archive.addFile(ArchiveFile(name, bytes.length, bytes));
      });
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Exporter le lot de test DV1 (aucun envoi)',
        fileName:
            'ABAK-${lot.isReplacement ? 'TD21B' : 'TD21'}-DV1-${lot.verified ? 'SIGNE' : 'NON-SIGNE'}.zip',
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );
      if (path != null) {
        await File(
          path,
        ).writeAsBytes(ZipEncoder().encode(archive), flush: true);
        if (mounted) setState(() => _exported = path);
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Export impossible : $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lot = _lot;
    return Scaffold(
      appBar: AppBar(
        title: const Text('CDA et lot TD2.1 — vérification locale'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Préparation du lot de test DV1 — aucun envoi depuis cet écran.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Auteur : ${widget.profile.givenName} ${widget.profile.familyName}\nStructure : ${widget.situation.structureName}',
              ),
              const Text(
                'Patient du jeu d’essai : SYLVAIN BONNEL (Cas12), né le 01/01/1987. '
                'Lieu de naissance retenu pour cet essai : Marcillac-Saint-Quentin (24252). '
                'Valeur déduite du matricule et approuvée pour le test DV1, non confirmée. Aucun INS n’est qualifié par cet essai.',
              ),
              const SizedBox(height: 12),
              const Text(
                'CDA à corps texte non structuré. Contenu technique sans valeur clinique. '
                'Signature XAdES / IHE DSG selon le guide fourni : RSA-SHA1 et canonisation avec commentaires. '
                'Le dépôt sur DV1 reste une étape séparée après vérification du lot signé.',
              ),
              OutlinedButton(
                onPressed: _busy ? null : () => _prepare(replacement: true),
                child: const Text(
                  'Préparer le remplacement TD2.1b du bilan déposé',
                ),
              ),
              if (lot?.isReplacement == true)
                const Text(
                  'REMPLACEMENT — version 2 du bilan de SYLVAIN BONNEL. Aucun envoi. La référence DV1 devra être vérifiée à nouveau avant le remplacement.',
                ),
              if (_busy) const LinearProgressIndicator(),
              if (_error != null)
                SelectableText(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              if (lot != null) ...[
                const SizedBox(height: 16),
                Text(
                  lot.verified
                      ? 'Signature CPS vérifiée localement ; message altéré rejeté ; condensats du lot contrôlés.'
                      : 'CDA, métadonnées et condensats préparés. Signature CPS non encore apposée.',
                ),
                SelectableText(
                  'Document : ${lot.documentOid}\nLot : ${lot.lotOid}\nSignature : ${lot.signatureOid}',
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _busy || lot.verified ? null : _sign,
                  child: const Text('Signer le lot DV1 avec la CPS de Michel'),
                ),
                OutlinedButton(
                  onPressed: _busy ? null : _export,
                  child: const Text(
                    'Exporter les fichiers et le rapport local',
                  ),
                ),
                if (_exported != null)
                  SelectableText('Export enregistré : $_exported'),
                for (final entry in lot.files.entries.where(
                  (e) => !e.key.endsWith('.pem'),
                ))
                  ExpansionTile(
                    title: Text(entry.key),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: SelectableText(entry.value),
                      ),
                    ],
                  ),
              ],
              const SizedBox(height: 12),
              const Text(
                'Cet écran ne contrôle pas les schémas CI-SIS, les nomenclatures, la chaîne de confiance ni la révocation. '
                'Ce test ne vaut pas homologation DMP. Aucun résultat INSi n’est utilisé.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
