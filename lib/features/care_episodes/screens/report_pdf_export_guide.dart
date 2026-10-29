import 'package:flutter/material.dart';

/// Documentary capabilities are deliberately separate from product acceptance.
class ReportPdfExportGuide extends StatelessWidget {
  const ReportPdfExportGuide({super.key});

  static const _routes = [
    (
      name: 'LibreOffice — macOS et Windows',
      status: 'Capacité documentée — parcours à vérifier',
      instruction:
          'Exporter au format PDF en choisissant explicitement PDF/A-1b. '
          'Un export PDF standard ne suffit pas. La version du logiciel et les réglages doivent être vérifiés dans ABAK.',
      source:
          'https://help.libreoffice.org/latest/fr/text/shared/guide/pdf_params.html',
    ),
    (
      name: 'Word — Windows',
      status: 'Capacité documentée — parcours à vérifier',
      instruction:
          'Dans les options d’export PDF, activer « Compatible ISO 19005-1 (PDF/A) ». '
          'Le fichier obtenu doit encore réussir le contrôle PDF/A-1b dans ABAK.',
      source:
          'https://support.microsoft.com/en-us/office/collab-files/save-or-convert-to-pdf-or-xps-in-office-desktop-apps',
    ),
    (
      name: 'Word — macOS',
      status: 'PDF/A non confirmé — non testé',
      instruction:
          'L’export PDF est documenté, mais la procédure consultée ne précise pas d’option PDF/A. '
          'La capacité de Word Windows ne vaut pas confirmation pour Word Mac. Une conversion supplémentaire peut être nécessaire.',
      source:
          'https://support.microsoft.com/en-us/word/save-or-convert-to-pdf-on-your-mac',
    ),
    (
      name: 'Pages 14.4 — macOS',
      status: 'Export testé — non conforme à PDF/A-1b',
      instruction:
          'Pages ne propose pas d’option PDF/A-1b dans les réglages d’export documentés par Apple '
          '(documentation vérifiée le 22 octobre 2026). La qualité optimale ne garantit pas la conformité PDF/A. '
          'Prévoyez une conversion en PDF/A-1b avec un outil adapté, puis un contrôle dans ABAK. '
          'Le 21 octobre 2026, un rapport synthétique exporté en PDF, qualité optimale et sans mot de passe, '
          'a été importé avec succès par le sélecteur macOS dans la copie signée d’ABAK. '
          'veraPDF l’a déclaré non conforme à PDF/A-1b : cet export nécessite une conversion. '
          'Ce résultat concerne ce fichier et ces réglages, pas tous les exports possibles de Pages.',
      source: 'https://support.apple.com/fr-fr/guide/pages/tance1161f26/mac',
    ),
    (
      name: 'PDF existant → Adobe Acrobat Pro — macOS et Windows',
      status: 'Conversion documentée — parcours à vérifier',
      instruction:
          'Après l’export depuis votre logiciel, utiliser la conversion PDF/A d’Acrobat Pro '
          'avec un profil PDF/A-1b, puis importer le résultat dans ABAK. '
          'Vérifier aussi que la présentation du rapport est conservée.',
      source: 'https://helpx.adobe.com/au/acrobat/using/pdf-x-pdf-a-pdf.html',
    ),
  ];

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Parcours PDF/A-1b et vérifications'),
    content: SizedBox(
      width: 680,
      child: SingleChildScrollView(
        key: const Key('report-pdf-guide-scroll'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'État au 22 octobre 2026. Une capacité documentée n’est pas un parcours validé dans ABAK. '
              'Aucun des parcours d’export ci-dessous n’est encore qualifié de bout en bout comme conforme dans ABAK. '
              'Chaque PDF importé reste contrôlé, quel que soit son logiciel d’origine.',
            ),
            for (final route in _routes) ...[
              const Divider(height: 28),
              Text(route.name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                route.status,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(route.instruction),
              const SizedBox(height: 8),
              const Text('Documentation éditeur :'),
              SelectableText(route.source),
            ],
            const Divider(height: 28),
            const Text(
              'Si votre logiciel produit seulement un PDF ordinaire, convertissez-le en PDF/A-1b '
              'avec un outil adapté avant de réimporter la nouvelle version. '
              'ABAK contrôle le fichier importé ; cet import ne le convertit pas automatiquement. '
              'Une conformité PDF/A ne remplace ni la validation médicale ni les contrôles CDA et DMP. '
              'Cette aide ne déclenche aucune conversion, signature ou transmission.',
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Fermer'),
      ),
    ],
  );
}
