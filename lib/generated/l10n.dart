// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `ABAK Dictée vocale`
  String get abakWhisperSpeechProvider_name {
    return Intl.message(
      'ABAK Dictée vocale',
      name: 'abakWhisperSpeechProvider_name',
      desc: '',
      args: [],
    );
  }

  /// `Cette vue regroupe les bilans et les rapports archivés de la prise en charge. Chaque ligne indique le type de document, son titre et sa date d’archivage.\n\nL’action de restauration permet de remettre le document dans l’historique des bilans ou des rapports.\n\nL’action de suppression définitive retire le document de Companion. Lisez attentivement le message de confirmation avant de valider : le document ne pourra plus être restauré depuis cette liste.\n\nCliquez sur la croix pour fermer la vue agrandie et revenir à l’espace Bilans/Rapports.`
  String get archivedDocuments_help {
    return Intl.message(
      'Cette vue regroupe les bilans et les rapports archivés de la prise en charge. Chaque ligne indique le type de document, son titre et sa date d’archivage.\n\nL’action de restauration permet de remettre le document dans l’historique des bilans ou des rapports.\n\nL’action de suppression définitive retire le document de Companion. Lisez attentivement le message de confirmation avant de valider : le document ne pourra plus être restauré depuis cette liste.\n\nCliquez sur la croix pour fermer la vue agrandie et revenir à l’espace Bilans/Rapports.',
      name: 'archivedDocuments_help',
      desc: '',
      args: [],
    );
  }

  /// `Une série graphique doit contenir au moins deux points.`
  String get assessmentChartImageService_insufficientPoints {
    return Intl.message(
      'Une série graphique doit contenir au moins deux points.',
      name: 'assessmentChartImageService_insufficientPoints',
      desc: '',
      args: [],
    );
  }

  /// `Impossible de convertir le graphique en image PNG.`
  String get assessmentChartImageService_pngConversionError {
    return Intl.message(
      'Impossible de convertir le graphique en image PNG.',
      name: 'assessmentChartImageService_pngConversionError',
      desc: '',
      args: [],
    );
  }

  /// `Féminin`
  String get assessmentDocumentDataBuilder_female {
    return Intl.message(
      'Féminin',
      name: 'assessmentDocumentDataBuilder_female',
      desc: '',
      args: [],
    );
  }

  /// `Masculin`
  String get assessmentDocumentDataBuilder_male {
    return Intl.message(
      'Masculin',
      name: 'assessmentDocumentDataBuilder_male',
      desc: '',
      args: [],
    );
  }

  /// `Patient introuvable pour la prise en charge {careEpisodeId}.`
  String assessmentDocumentDataBuilder_patient(Object careEpisodeId) {
    return Intl.message(
      'Patient introuvable pour la prise en charge $careEpisodeId.',
      name: 'assessmentDocumentDataBuilder_patient',
      desc: '',
      args: [careEpisodeId],
    );
  }

  /// `Âge`
  String get assessmentDocxService_age {
    return Intl.message(
      'Âge',
      name: 'assessmentDocxService_age',
      desc: '',
      args: [],
    );
  }

  /// `Bilan`
  String get assessmentDocxService_assessment {
    return Intl.message(
      'Bilan',
      name: 'assessmentDocxService_assessment',
      desc: '',
      args: [],
    );
  }

  /// `Pathologie lors du rattachement`
  String get assessmentDocxService_attachment {
    return Intl.message(
      'Pathologie lors du rattachement',
      name: 'assessmentDocxService_attachment',
      desc: '',
      args: [],
    );
  }

  /// `Rédacteur`
  String get assessmentDocxService_author {
    return Intl.message(
      'Rédacteur',
      name: 'assessmentDocxService_author',
      desc: '',
      args: [],
    );
  }

  /// `{height} cm`
  String assessmentDocxService_centimetres(Object height) {
    return Intl.message(
      '$height cm',
      name: 'assessmentDocxService_centimetres',
      desc: '',
      args: [height],
    );
  }

  /// `Graphique`
  String get assessmentDocxService_chart {
    return Intl.message(
      'Graphique',
      name: 'assessmentDocxService_chart',
      desc: '',
      args: [],
    );
  }

  /// `Âge déclaré lors du test`
  String get assessmentDocxService_declared {
    return Intl.message(
      'Âge déclaré lors du test',
      name: 'assessmentDocxService_declared',
      desc: '',
      args: [],
    );
  }

  /// `Pathologie lors du test`
  String get assessmentDocxService_diagnosis {
    return Intl.message(
      'Pathologie lors du test',
      name: 'assessmentDocxService_diagnosis',
      desc: '',
      args: [],
    );
  }

  /// `Côté dominant`
  String get assessmentDocxService_dominance {
    return Intl.message(
      'Côté dominant',
      name: 'assessmentDocxService_dominance',
      desc: '',
      args: [],
    );
  }

  /// `Établissement`
  String get assessmentDocxService_establishment {
    return Intl.message(
      'Établissement',
      name: 'assessmentDocxService_establishment',
      desc: '',
      args: [],
    );
  }

  /// `Prénom`
  String get assessmentDocxService_firstname {
    return Intl.message(
      'Prénom',
      name: 'assessmentDocxService_firstname',
      desc: '',
      args: [],
    );
  }

  /// `Taille`
  String get assessmentDocxService_height {
    return Intl.message(
      'Taille',
      name: 'assessmentDocxService_height',
      desc: '',
      args: [],
    );
  }

  /// `Informations sur le patient`
  String get assessmentDocxService_information {
    return Intl.message(
      'Informations sur le patient',
      name: 'assessmentDocxService_information',
      desc: '',
      args: [],
    );
  }

  /// `{weight} kg`
  String assessmentDocxService_kilograms(Object weight) {
    return Intl.message(
      '$weight kg',
      name: 'assessmentDocxService_kilograms',
      desc: '',
      args: [weight],
    );
  }

  /// `Notes de suivi sélectionnées`
  String get assessmentDocxService_notes {
    return Intl.message(
      'Notes de suivi sélectionnées',
      name: 'assessmentDocxService_notes',
      desc: '',
      args: [],
    );
  }

  /// `Prise en charge ouverte le`
  String get assessmentDocxService_opened {
    return Intl.message(
      'Prise en charge ouverte le',
      name: 'assessmentDocxService_opened',
      desc: '',
      args: [],
    );
  }

  /// `Pathologie`
  String get assessmentDocxService_pathology {
    return Intl.message(
      'Pathologie',
      name: 'assessmentDocxService_pathology',
      desc: '',
      args: [],
    );
  }

  /// `Patient`
  String get assessmentDocxService_patient {
    return Intl.message(
      'Patient',
      name: 'assessmentDocxService_patient',
      desc: '',
      args: [],
    );
  }

  /// `Réalisé le`
  String get assessmentDocxService_performed {
    return Intl.message(
      'Réalisé le',
      name: 'assessmentDocxService_performed',
      desc: '',
      args: [],
    );
  }

  /// `Kiné référent`
  String get assessmentDocxService_practitioner {
    return Intl.message(
      'Kiné référent',
      name: 'assessmentDocxService_practitioner',
      desc: '',
      args: [],
    );
  }

  /// `Imprimé le`
  String get assessmentDocxService_printed {
    return Intl.message(
      'Imprimé le',
      name: 'assessmentDocxService_printed',
      desc: '',
      args: [],
    );
  }

  /// `Profession`
  String get assessmentDocxService_profession {
    return Intl.message(
      'Profession',
      name: 'assessmentDocxService_profession',
      desc: '',
      args: [],
    );
  }

  /// `Destinataire(s)`
  String get assessmentDocxService_recipients {
    return Intl.message(
      'Destinataire(s)',
      name: 'assessmentDocxService_recipients',
      desc: '',
      args: [],
    );
  }

  /// `Résultats des tests sélectionnés`
  String get assessmentDocxService_results {
    return Intl.message(
      'Résultats des tests sélectionnés',
      name: 'assessmentDocxService_results',
      desc: '',
      args: [],
    );
  }

  /// `Sexe`
  String get assessmentDocxService_sex {
    return Intl.message(
      'Sexe',
      name: 'assessmentDocxService_sex',
      desc: '',
      args: [],
    );
  }

  /// `Activité sportive`
  String get assessmentDocxService_sport {
    return Intl.message(
      'Activité sportive',
      name: 'assessmentDocxService_sport',
      desc: '',
      args: [],
    );
  }

  /// `Nom`
  String get assessmentDocxService_surname {
    return Intl.message(
      'Nom',
      name: 'assessmentDocxService_surname',
      desc: '',
      args: [],
    );
  }

  /// `BILAN`
  String get assessmentDocxService_title {
    return Intl.message(
      'BILAN',
      name: 'assessmentDocxService_title',
      desc: '',
      args: [],
    );
  }

  /// `Poids`
  String get assessmentDocxService_weight {
    return Intl.message(
      'Poids',
      name: 'assessmentDocxService_weight',
      desc: '',
      args: [],
    );
  }

  /// `{age} ans`
  String assessmentDocxService_years(Object age) {
    return Intl.message(
      '$age ans',
      name: 'assessmentDocxService_years',
      desc: '',
      args: [age],
    );
  }

  /// `Le texte affiché correspond à un travail en cours sauvegardé automatiquement. Vous pouvez le conserver, le modifier ou le supprimer avant d’enregistrer votre bilan.`
  String get assessmentDraft_help {
    return Intl.message(
      'Le texte affiché correspond à un travail en cours sauvegardé automatiquement. Vous pouvez le conserver, le modifier ou le supprimer avant d’enregistrer votre bilan.',
      name: 'assessmentDraft_help',
      desc: '',
      args: [],
    );
  }

  /// `Comprendre le brouillon du bilan`
  String get assessmentDraft_helpTitle {
    return Intl.message(
      'Comprendre le brouillon du bilan',
      name: 'assessmentDraft_helpTitle',
      desc: '',
      args: [],
    );
  }

  /// `Cette vue présente les bilans enregistrés pour la prise en charge, avec leur titre et leur date.\n\nLes actions de chaque ligne permettent de modifier un bilan, de le dupliquer ou de le déplacer vers les documents archivés.\n\nLorsqu’un bilan est ouvert en modification, utilisez l’action de mise à jour pour enregistrer vos changements. Les commandes disponibles permettent également d’annuler les modifications ou de revenir au brouillon.\n\nLe déplacement vers les documents archivés n’est pas une suppression définitive.\n\nCliquez sur la croix pour fermer la vue agrandie et revenir à l’espace Bilans/Rapports.`
  String get assessmentHistory_help {
    return Intl.message(
      'Cette vue présente les bilans enregistrés pour la prise en charge, avec leur titre et leur date.\n\nLes actions de chaque ligne permettent de modifier un bilan, de le dupliquer ou de le déplacer vers les documents archivés.\n\nLorsqu’un bilan est ouvert en modification, utilisez l’action de mise à jour pour enregistrer vos changements. Les commandes disponibles permettent également d’annuler les modifications ou de revenir au brouillon.\n\nLe déplacement vers les documents archivés n’est pas une suppression définitive.\n\nCliquez sur la croix pour fermer la vue agrandie et revenir à l’espace Bilans/Rapports.',
      name: 'assessmentHistory_help',
      desc: '',
      args: [],
    );
  }

  /// `Annuler`
  String get backupHistory_cancel {
    return Intl.message(
      'Annuler',
      name: 'backupHistory_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Aucune sauvegarde enregistrée.`
  String get backupHistory_empty {
    return Intl.message(
      'Aucune sauvegarde enregistrée.',
      name: 'backupHistory_empty',
      desc: '',
      args: [],
    );
  }

  /// `{size}`
  String backupHistory_fileSize(Object size) {
    return Intl.message(
      '$size',
      name: 'backupHistory_fileSize',
      desc: '',
      args: [size],
    );
  }

  /// `Cet écran présente les sauvegardes enregistrées dans Companion. Chaque ligne indique le nom du fichier, sa date de création, sa taille et son emplacement.\n\nLe bouton « Restaurer » permet de remplacer la base actuelle par celle de la sauvegarde choisie. Les données ajoutées ou modifiées après cette sauvegarde ne seront donc pas présentes dans la base restaurée.\n\nVérifiez la date de la sauvegarde et lisez le message de confirmation avant de poursuivre. Une copie de sécurité de la base actuelle est créée avant son remplacement.\n\nLe fichier de sauvegarde doit toujours être accessible à l’emplacement indiqué. S’il a été déplacé ou supprimé, la restauration ne pourra pas être effectuée.\n\nPour créer une nouvelle sauvegarde, utilisez l’action « Créer une sauvegarde » sur la page d’accueil.`
  String get backupHistory_help {
    return Intl.message(
      'Cet écran présente les sauvegardes enregistrées dans Companion. Chaque ligne indique le nom du fichier, sa date de création, sa taille et son emplacement.\n\nLe bouton « Restaurer » permet de remplacer la base actuelle par celle de la sauvegarde choisie. Les données ajoutées ou modifiées après cette sauvegarde ne seront donc pas présentes dans la base restaurée.\n\nVérifiez la date de la sauvegarde et lisez le message de confirmation avant de poursuivre. Une copie de sécurité de la base actuelle est créée avant son remplacement.\n\nLe fichier de sauvegarde doit toujours être accessible à l’emplacement indiqué. S’il a été déplacé ou supprimé, la restauration ne pourra pas être effectuée.\n\nPour créer une nouvelle sauvegarde, utilisez l’action « Créer une sauvegarde » sur la page d’accueil.',
      name: 'backupHistory_help',
      desc: '',
      args: [],
    );
  }

  /// `Restaurer`
  String get backupHistory_restore {
    return Intl.message(
      'Restaurer',
      name: 'backupHistory_restore',
      desc: '',
      args: [],
    );
  }

  /// `Restaurer cette sauvegarde ?`
  String get backupHistory_restoreTitle {
    return Intl.message(
      'Restaurer cette sauvegarde ?',
      name: 'backupHistory_restoreTitle',
      desc: '',
      args: [],
    );
  }

  /// `Cette opération remplacera totalement la base actuelle.\n\nUne sauvegarde automatique de sécurité sera créée avant restauration.\n\nContinuer ?`
  String get backupHistory_restoreWarning {
    return Intl.message(
      'Cette opération remplacera totalement la base actuelle.\n\nUne sauvegarde automatique de sécurité sera créée avant restauration.\n\nContinuer ?',
      name: 'backupHistory_restoreWarning',
      desc: '',
      args: [],
    );
  }

  /// `Historique des sauvegardes`
  String get backupHistory_title {
    return Intl.message(
      'Historique des sauvegardes',
      name: 'backupHistory_title',
      desc: '',
      args: [],
    );
  }

  /// `La carte des douleurs permet de repérer les zones douloureuses du patient pour l’épisode de soins en cours.\n\nChoisissez une vue, puis cliquez sur une zone de la silhouette ou sélectionnez-la dans la liste. Vous pouvez ajouter une observation et, si nécessaire, une intensité de 0 à 10. Utilisez la corbeille pour retirer une zone du relevé.\n\nCliquez sur « Enregistrer » pour conserver votre relevé dans Companion. Lorsque vous quittez l’écran avec des modifications non enregistrées, un choix vous permet de les enregistrer ou de les abandonner.\n\n« Exporter les deux cartes » crée une image PNG à l’emplacement choisi sur votre ordinateur. Cet export ne remplace pas l’enregistrement du relevé.\n\nCe module est une première proposition, destinée à évoluer selon vos retours. Testez-le dans votre pratique et indiquez les possibilités que vous souhaiteriez voir ajoutées ou améliorées.`
  String get bodymap_help {
    return Intl.message(
      'La carte des douleurs permet de repérer les zones douloureuses du patient pour l’épisode de soins en cours.\n\nChoisissez une vue, puis cliquez sur une zone de la silhouette ou sélectionnez-la dans la liste. Vous pouvez ajouter une observation et, si nécessaire, une intensité de 0 à 10. Utilisez la corbeille pour retirer une zone du relevé.\n\nCliquez sur « Enregistrer » pour conserver votre relevé dans Companion. Lorsque vous quittez l’écran avec des modifications non enregistrées, un choix vous permet de les enregistrer ou de les abandonner.\n\n« Exporter les deux cartes » crée une image PNG à l’emplacement choisi sur votre ordinateur. Cet export ne remplace pas l’enregistrement du relevé.\n\nCe module est une première proposition, destinée à évoluer selon vos retours. Testez-le dans votre pratique et indiquez les possibilités que vous souhaiteriez voir ajoutées ou améliorées.',
      name: 'bodymap_help',
      desc: '',
      args: [],
    );
  }

  /// `Carte des douleurs`
  String get bodymap_title {
    return Intl.message(
      'Carte des douleurs',
      name: 'bodymap_title',
      desc: '',
      args: [],
    );
  }

  /// `Aucune analyse clinique.`
  String get careEpisode_assessment {
    return Intl.message(
      'Aucune analyse clinique.',
      name: 'careEpisode_assessment',
      desc: '',
      args: [],
    );
  }

  /// `Aucune évaluation clinique.`
  String get careEpisode_evaluation {
    return Intl.message(
      'Aucune évaluation clinique.',
      name: 'careEpisode_evaluation',
      desc: '',
      args: [],
    );
  }

  /// `Aucun compte rendu initial.`
  String get careEpisode_report {
    return Intl.message(
      'Aucun compte rendu initial.',
      name: 'careEpisode_report',
      desc: '',
      args: [],
    );
  }

  /// `Prise en charge`
  String get careEpisode_title {
    return Intl.message(
      'Prise en charge',
      name: 'careEpisode_title',
      desc: '',
      args: [],
    );
  }

  /// `Aucun plan de traitement.`
  String get careEpisode_treatment {
    return Intl.message(
      'Aucun plan de traitement.',
      name: 'careEpisode_treatment',
      desc: '',
      args: [],
    );
  }

  /// `Origine ABAK`
  String get careEpisodeDetail_abakOrigin {
    return Intl.message(
      'Origine ABAK',
      name: 'careEpisodeDetail_abakOrigin',
      desc: '',
      args: [],
    );
  }

  /// `Évolution`
  String get careEpisodeDetail_evolution {
    return Intl.message(
      'Évolution',
      name: 'careEpisodeDetail_evolution',
      desc: '',
      args: [],
    );
  }

  /// `Détail de la prise en charge`
  String get careEpisodeDetail_detail_de_la_prise_en_charge {
    return Intl.message(
      'Détail de la prise en charge',
      name: 'careEpisodeDetail_detail_de_la_prise_en_charge',
      desc: '',
      args: [],
    );
  }

  /// `Aucun résultat rattaché pour le moment.`
  String get careEpisodeDetail_noResult {
    return Intl.message(
      'Aucun résultat rattaché pour le moment.',
      name: 'careEpisodeDetail_noResult',
      desc: '',
      args: [],
    );
  }

  /// `Pathologie`
  String get careEpisodeDetail_pathology {
    return Intl.message(
      'Pathologie',
      name: 'careEpisodeDetail_pathology',
      desc: '',
      args: [],
    );
  }

  /// `Nouvelle interface bilans et rapports`
  String get careEpisodeDetail_reportsWorkspaceTooltip {
    return Intl.message(
      'Nouvelle interface bilans et rapports',
      name: 'careEpisodeDetail_reportsWorkspaceTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Résultats ABAK`
  String get careEpisodeDetail_results {
    return Intl.message(
      'Résultats ABAK',
      name: 'careEpisodeDetail_results',
      desc: '',
      args: [],
    );
  }

  /// `Score`
  String get careEpisodeDetail_score {
    return Intl.message(
      'Score',
      name: 'careEpisodeDetail_score',
      desc: '',
      args: [],
    );
  }

  /// `Médecin prescripteur`
  String get careEpisodePanel_prescribingDoctor {
    return Intl.message(
      'Médecin prescripteur',
      name: 'careEpisodePanel_prescribingDoctor',
      desc: '',
      args: [],
    );
  }

  /// `Archiver cette prise en charge ?`
  String get careEpisodePanel_archiveCareEpisodeTitle {
    return Intl.message(
      'Archiver cette prise en charge ?',
      name: 'careEpisodePanel_archiveCareEpisodeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Cette prise en charge sera retirée de la liste. Ses données seront conservées par archivage.`
  String get careEpisodePanel_archiveCareEpisodeMessage {
    return Intl.message(
      'Cette prise en charge sera retirée de la liste. Ses données seront conservées par archivage.',
      name: 'careEpisodePanel_archiveCareEpisodeMessage',
      desc: '',
      args: [],
    );
  }

  /// `Archiver`
  String get careEpisodePanel_archive {
    return Intl.message(
      'Archiver',
      name: 'careEpisodePanel_archive',
      desc: '',
      args: [],
    );
  }

  /// `Prise en charge archivée.`
  String get careEpisodePanel_careEpisodeArchived {
    return Intl.message(
      'Prise en charge archivée.',
      name: 'careEpisodePanel_careEpisodeArchived',
      desc: '',
      args: [],
    );
  }

  /// `Impossible d’archiver la prise en charge. Veuillez réessayer.`
  String get careEpisodePanel_archiveCareEpisodeError {
    return Intl.message(
      'Impossible d’archiver la prise en charge. Veuillez réessayer.',
      name: 'careEpisodePanel_archiveCareEpisodeError',
      desc: '',
      args: [],
    );
  }

  /// `Vous trouvez ici vos épisodes de soins archivés.`
  String get careEpisodePanel_archivedCareEpisodesHelp {
    return Intl.message(
      'Vous trouvez ici vos épisodes de soins archivés.',
      name: 'careEpisodePanel_archivedCareEpisodesHelp',
      desc: '',
      args: [],
    );
  }

  /// `Prise en charge restaurée.`
  String get careEpisodePanel_careEpisodeRestored {
    return Intl.message(
      'Prise en charge restaurée.',
      name: 'careEpisodePanel_careEpisodeRestored',
      desc: '',
      args: [],
    );
  }

  /// `Impossible de restaurer la prise en charge. Veuillez réessayer.`
  String get careEpisodePanel_restoreCareEpisodeError {
    return Intl.message(
      'Impossible de restaurer la prise en charge. Veuillez réessayer.',
      name: 'careEpisodePanel_restoreCareEpisodeError',
      desc: '',
      args: [],
    );
  }

  /// `Prises en charge`
  String get careEpisodePanel_careEpisodes {
    return Intl.message(
      'Prises en charge',
      name: 'careEpisodePanel_careEpisodes',
      desc: '',
      args: [],
    );
  }

  /// `Prises en charge archivées`
  String get careEpisodePanel_archivedCareEpisodes {
    return Intl.message(
      'Prises en charge archivées',
      name: 'careEpisodePanel_archivedCareEpisodes',
      desc: '',
      args: [],
    );
  }

  /// `Nouvelle prise en charge`
  String get careEpisodePanel_newCareEpisode {
    return Intl.message(
      'Nouvelle prise en charge',
      name: 'careEpisodePanel_newCareEpisode',
      desc: '',
      args: [],
    );
  }

  /// `Impossible de charger les prises en charge.`
  String get careEpisodePanel_loadCareEpisodesError {
    return Intl.message(
      'Impossible de charger les prises en charge.',
      name: 'careEpisodePanel_loadCareEpisodesError',
      desc: '',
      args: [],
    );
  }

  /// `Aucune prise en charge archivée pour ce patient.`
  String get careEpisodePanel_noArchivedCareEpisodes {
    return Intl.message(
      'Aucune prise en charge archivée pour ce patient.',
      name: 'careEpisodePanel_noArchivedCareEpisodes',
      desc: '',
      args: [],
    );
  }

  /// `Aucune prise en charge créée pour ce patient.`
  String get careEpisodePanel_noCareEpisodes {
    return Intl.message(
      'Aucune prise en charge créée pour ce patient.',
      name: 'careEpisodePanel_noCareEpisodes',
      desc: '',
      args: [],
    );
  }

  /// `Prise en charge ouverte en {monthYear}`
  String careEpisodePanel_careEpisodeOpenedIn(Object monthYear) {
    return Intl.message(
      'Prise en charge ouverte en $monthYear',
      name: 'careEpisodePanel_careEpisodeOpenedIn',
      desc: '',
      args: [monthYear],
    );
  }

  /// `Archivée le {date}`
  String careEpisodePanel_archivedOn(Object date) {
    return Intl.message(
      'Archivée le $date',
      name: 'careEpisodePanel_archivedOn',
      desc: '',
      args: [date],
    );
  }

  /// `Restaurer`
  String get careEpisodePanel_restore {
    return Intl.message(
      'Restaurer',
      name: 'careEpisodePanel_restore',
      desc: '',
      args: [],
    );
  }

  /// `Choisir`
  String get careEpisodePanel_choose {
    return Intl.message(
      'Choisir',
      name: 'careEpisodePanel_choose',
      desc: '',
      args: [],
    );
  }

  /// `Modifier`
  String get careEpisodePanel_edit {
    return Intl.message(
      'Modifier',
      name: 'careEpisodePanel_edit',
      desc: '',
      args: [],
    );
  }

  /// `Archiver la prise en charge`
  String get careEpisodePanel_archiveCareEpisode {
    return Intl.message(
      'Archiver la prise en charge',
      name: 'careEpisodePanel_archiveCareEpisode',
      desc: '',
      args: [],
    );
  }

  /// `Ajouter une note de suivi`
  String get careEpisodeReportsWorkspace_addFollowUpNote {
    return Intl.message(
      'Ajouter une note de suivi',
      name: 'careEpisodeReportsWorkspace_addFollowUpNote',
      desc: '',
      args: [],
    );
  }

  /// `archivé`
  String get careEpisodeReportsWorkspace_archived {
    return Intl.message(
      'archivé',
      name: 'careEpisodeReportsWorkspace_archived',
      desc: '',
      args: [],
    );
  }

  /// `Documents archivés`
  String get careEpisodeReportsWorkspace_archivedDocuments {
    return Intl.message(
      'Documents archivés',
      name: 'careEpisodeReportsWorkspace_archivedDocuments',
      desc: '',
      args: [],
    );
  }

  /// `Documents archivés`
  String get careEpisodeReportsWorkspace_archivedDocumentsCount {
    return Intl.message(
      'Documents archivés',
      name: 'careEpisodeReportsWorkspace_archivedDocumentsCount',
      desc: '',
      args: [],
    );
  }

  /// `Bilan`
  String get careEpisodeReportsWorkspace_assessment {
    return Intl.message(
      'Bilan',
      name: 'careEpisodeReportsWorkspace_assessment',
      desc: '',
      args: [],
    );
  }

  /// `Nombre de bilans`
  String get careEpisodeReportsWorkspace_assessmentCount {
    return Intl.message(
      'Nombre de bilans',
      name: 'careEpisodeReportsWorkspace_assessmentCount',
      desc: '',
      args: [],
    );
  }

  /// `Historique des bilans`
  String get careEpisodeReportsWorkspace_assessmentHistory {
    return Intl.message(
      'Historique des bilans',
      name: 'careEpisodeReportsWorkspace_assessmentHistory',
      desc: '',
      args: [],
    );
  }

  /// `Impossible de charger les bilans.`
  String get careEpisodeReportsWorkspace_assessmentsLoadError {
    return Intl.message(
      'Impossible de charger les bilans.',
      name: 'careEpisodeReportsWorkspace_assessmentsLoadError',
      desc: '',
      args: [],
    );
  }

  /// `Annuler`
  String get careEpisodeReportsWorkspace_cancel {
    return Intl.message(
      'Annuler',
      name: 'careEpisodeReportsWorkspace_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Annuler les modifications`
  String get careEpisodeReportsWorkspace_cancelChanges {
    return Intl.message(
      'Annuler les modifications',
      name: 'careEpisodeReportsWorkspace_cancelChanges',
      desc: '',
      args: [],
    );
  }

  /// `Créer ou reprendre un bilan`
  String get careEpisodeReportsWorkspace_createOrResumeAssessment {
    return Intl.message(
      'Créer ou reprendre un bilan',
      name: 'careEpisodeReportsWorkspace_createOrResumeAssessment',
      desc: '',
      args: [],
    );
  }

  /// `Créer ou reprendre un rapport`
  String get careEpisodeReportsWorkspace_createOrResumeReport {
    return Intl.message(
      'Créer ou reprendre un rapport',
      name: 'careEpisodeReportsWorkspace_createOrResumeReport',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get careEpisodeReportsWorkspace_date {
    return Intl.message(
      'Date',
      name: 'careEpisodeReportsWorkspace_date',
      desc: '',
      args: [],
    );
  }

  /// `Supprimer définitivement`
  String get careEpisodeReportsWorkspace_deletePermanently {
    return Intl.message(
      'Supprimer définitivement',
      name: 'careEpisodeReportsWorkspace_deletePermanently',
      desc: '',
      args: [],
    );
  }

  /// `Dupliquer`
  String get careEpisodeReportsWorkspace_duplicate {
    return Intl.message(
      'Dupliquer',
      name: 'careEpisodeReportsWorkspace_duplicate',
      desc: '',
      args: [],
    );
  }

  /// `Modifier`
  String get careEpisodeReportsWorkspace_edit {
    return Intl.message(
      'Modifier',
      name: 'careEpisodeReportsWorkspace_edit',
      desc: '',
      args: [],
    );
  }

  /// `Modifier le kiné référent`
  String get careEpisodeReportsWorkspace_editReferringPractitioner {
    return Intl.message(
      'Modifier le kiné référent',
      name: 'careEpisodeReportsWorkspace_editReferringPractitioner',
      desc: '',
      args: [],
    );
  }

  /// `Documents de la prise en charge`
  String get careEpisodeReportsWorkspace_episodeDocuments {
    return Intl.message(
      'Documents de la prise en charge',
      name: 'careEpisodeReportsWorkspace_episodeDocuments',
      desc: '',
      args: [],
    );
  }

  /// `Résumé de l’épisode`
  String get careEpisodeReportsWorkspace_episodeSummary {
    return Intl.message(
      'Résumé de l’épisode',
      name: 'careEpisodeReportsWorkspace_episodeSummary',
      desc: '',
      args: [],
    );
  }

  /// `Agrandir`
  String get careEpisodeReportsWorkspace_expand {
    return Intl.message(
      'Agrandir',
      name: 'careEpisodeReportsWorkspace_expand',
      desc: '',
      args: [],
    );
  }

  /// `Agrandir la zone de rédaction`
  String get careEpisodeReportsWorkspace_expandEditor {
    return Intl.message(
      'Agrandir la zone de rédaction',
      name: 'careEpisodeReportsWorkspace_expandEditor',
      desc: '',
      args: [],
    );
  }

  /// `Note de suivi`
  String get careEpisodeReportsWorkspace_followUpNoteDefaultTitle {
    return Intl.message(
      'Note de suivi',
      name: 'careEpisodeReportsWorkspace_followUpNoteDefaultTitle',
      desc: '',
      args: [],
    );
  }

  /// `Notes de suivi`
  String get careEpisodeReportsWorkspace_followUpNotes {
    return Intl.message(
      'Notes de suivi',
      name: 'careEpisodeReportsWorkspace_followUpNotes',
      desc: '',
      args: [],
    );
  }

  /// `Impossible de charger les notes de suivi.`
  String get careEpisodeReportsWorkspace_followUpNotesLoadError {
    return Intl.message(
      'Impossible de charger les notes de suivi.',
      name: 'careEpisodeReportsWorkspace_followUpNotesLoadError',
      desc: '',
      args: [],
    );
  }

  /// `Inclure`
  String get careEpisodeReportsWorkspace_include {
    return Intl.message(
      'Inclure',
      name: 'careEpisodeReportsWorkspace_include',
      desc: '',
      args: [],
    );
  }

  /// `Tests réalisés (dernier résultat)`
  String get careEpisodeReportsWorkspace_latestTests {
    return Intl.message(
      'Tests réalisés (dernier résultat)',
      name: 'careEpisodeReportsWorkspace_latestTests',
      desc: '',
      args: [],
    );
  }

  /// `Chargement…`
  String get careEpisodeReportsWorkspace_loading {
    return Intl.message(
      'Chargement…',
      name: 'careEpisodeReportsWorkspace_loading',
      desc: '',
      args: [],
    );
  }

  /// `Mettre à la corbeille`
  String get careEpisodeReportsWorkspace_moveToTrash {
    return Intl.message(
      'Mettre à la corbeille',
      name: 'careEpisodeReportsWorkspace_moveToTrash',
      desc: '',
      args: [],
    );
  }

  /// `Nom`
  String get careEpisodeReportsWorkspace_name {
    return Intl.message(
      'Nom',
      name: 'careEpisodeReportsWorkspace_name',
      desc: '',
      args: [],
    );
  }

  /// `Bilan (nouveau)`
  String get careEpisodeReportsWorkspace_newAssessment {
    return Intl.message(
      'Bilan (nouveau)',
      name: 'careEpisodeReportsWorkspace_newAssessment',
      desc: '',
      args: [],
    );
  }

  /// `Aucun bilan enregistré.`
  String get careEpisodeReportsWorkspace_noAssessments {
    return Intl.message(
      'Aucun bilan enregistré.',
      name: 'careEpisodeReportsWorkspace_noAssessments',
      desc: '',
      args: [],
    );
  }

  /// `Aucun document`
  String get careEpisodeReportsWorkspace_noDocument {
    return Intl.message(
      'Aucun document',
      name: 'careEpisodeReportsWorkspace_noDocument',
      desc: '',
      args: [],
    );
  }

  /// `Aucune note de suivi.`
  String get careEpisodeReportsWorkspace_noFollowUpNotes {
    return Intl.message(
      'Aucune note de suivi.',
      name: 'careEpisodeReportsWorkspace_noFollowUpNotes',
      desc: '',
      args: [],
    );
  }

  /// `Aucun rapport enregistré.`
  String get careEpisodeReportsWorkspace_noReports {
    return Intl.message(
      'Aucun rapport enregistré.',
      name: 'careEpisodeReportsWorkspace_noReports',
      desc: '',
      args: [],
    );
  }

  /// `Note`
  String get careEpisodeReportsWorkspace_note {
    return Intl.message(
      'Note',
      name: 'careEpisodeReportsWorkspace_note',
      desc: '',
      args: [],
    );
  }

  /// `Aucun test réalisé pour cet épisode.`
  String get careEpisodeReportsWorkspace_noTests {
    return Intl.message(
      'Aucun test réalisé pour cet épisode.',
      name: 'careEpisodeReportsWorkspace_noTests',
      desc: '',
      args: [],
    );
  }

  /// `Non renseigné`
  String get careEpisodeReportsWorkspace_notProvided {
    return Intl.message(
      'Non renseigné',
      name: 'careEpisodeReportsWorkspace_notProvided',
      desc: '',
      args: [],
    );
  }

  /// `Pathologie`
  String get careEpisodeReportsWorkspace_pathology {
    return Intl.message(
      'Pathologie',
      name: 'careEpisodeReportsWorkspace_pathology',
      desc: '',
      args: [],
    );
  }

  /// `Kiné référent`
  String get careEpisodeReportsWorkspace_referringPractitioner {
    return Intl.message(
      'Kiné référent',
      name: 'careEpisodeReportsWorkspace_referringPractitioner',
      desc: '',
      args: [],
    );
  }

  /// `Historique des kinés référents`
  String get careEpisodeReportsWorkspace_referringPractitionerHistory {
    return Intl.message(
      'Historique des kinés référents',
      name: 'careEpisodeReportsWorkspace_referringPractitionerHistory',
      desc: '',
      args: [],
    );
  }

  /// `Rapport`
  String get careEpisodeReportsWorkspace_report {
    return Intl.message(
      'Rapport',
      name: 'careEpisodeReportsWorkspace_report',
      desc: '',
      args: [],
    );
  }

  /// `Nombre de rapports`
  String get careEpisodeReportsWorkspace_reportCount {
    return Intl.message(
      'Nombre de rapports',
      name: 'careEpisodeReportsWorkspace_reportCount',
      desc: '',
      args: [],
    );
  }

  /// `Historique des rapports`
  String get careEpisodeReportsWorkspace_reportHistory {
    return Intl.message(
      'Historique des rapports',
      name: 'careEpisodeReportsWorkspace_reportHistory',
      desc: '',
      args: [],
    );
  }

  /// `Impossible de charger les rapports.`
  String get careEpisodeReportsWorkspace_reportsLoadError {
    return Intl.message(
      'Impossible de charger les rapports.',
      name: 'careEpisodeReportsWorkspace_reportsLoadError',
      desc: '',
      args: [],
    );
  }

  /// `Restaurer`
  String get careEpisodeReportsWorkspace_restore {
    return Intl.message(
      'Restaurer',
      name: 'careEpisodeReportsWorkspace_restore',
      desc: '',
      args: [],
    );
  }

  /// `Résultat`
  String get careEpisodeReportsWorkspace_result {
    return Intl.message(
      'Résultat',
      name: 'careEpisodeReportsWorkspace_result',
      desc: '',
      args: [],
    );
  }

  /// `Retour au brouillon`
  String get careEpisodeReportsWorkspace_returnToDraft {
    return Intl.message(
      'Retour au brouillon',
      name: 'careEpisodeReportsWorkspace_returnToDraft',
      desc: '',
      args: [],
    );
  }

  /// `Retour au brouillon du rapport`
  String get careEpisodeReportsWorkspace_returnToReportDraft {
    return Intl.message(
      'Retour au brouillon du rapport',
      name: 'careEpisodeReportsWorkspace_returnToReportDraft',
      desc: '',
      args: [],
    );
  }

  /// `Enregistrer le bilan`
  String get careEpisodeReportsWorkspace_saveAssessment {
    return Intl.message(
      'Enregistrer le bilan',
      name: 'careEpisodeReportsWorkspace_saveAssessment',
      desc: '',
      args: [],
    );
  }

  /// `Enregistrer le rapport`
  String get careEpisodeReportsWorkspace_saveReport {
    return Intl.message(
      'Enregistrer le rapport',
      name: 'careEpisodeReportsWorkspace_saveReport',
      desc: '',
      args: [],
    );
  }

  /// `Zone de rédaction du bilan SOAP.\n\nS — Subjectif\n\nO — Objectif\n\nA — Analyse\n\nP — Plan`
  String get careEpisodeReportsWorkspace_soapEditorHint {
    return Intl.message(
      'Zone de rédaction du bilan SOAP.\n\nS — Subjectif\n\nO — Objectif\n\nA — Analyse\n\nP — Plan',
      name: 'careEpisodeReportsWorkspace_soapEditorHint',
      desc: '',
      args: [],
    );
  }

  /// `Test`
  String get careEpisodeReportsWorkspace_test {
    return Intl.message(
      'Test',
      name: 'careEpisodeReportsWorkspace_test',
      desc: '',
      args: [],
    );
  }

  /// `Nombre de tests`
  String get careEpisodeReportsWorkspace_testCount {
    return Intl.message(
      'Nombre de tests',
      name: 'careEpisodeReportsWorkspace_testCount',
      desc: '',
      args: [],
    );
  }

  /// `Impossible de charger les tests.`
  String get careEpisodeReportsWorkspace_testsLoadError {
    return Intl.message(
      'Impossible de charger les tests.',
      name: 'careEpisodeReportsWorkspace_testsLoadError',
      desc: '',
      args: [],
    );
  }

  /// `Titre`
  String get careEpisodeReportsWorkspace_title {
    return Intl.message(
      'Titre',
      name: 'careEpisodeReportsWorkspace_title',
      desc: '',
      args: [],
    );
  }

  /// `Impossible de charger la corbeille.`
  String get careEpisodeReportsWorkspace_trashLoadError {
    return Intl.message(
      'Impossible de charger la corbeille.',
      name: 'careEpisodeReportsWorkspace_trashLoadError',
      desc: '',
      args: [],
    );
  }

  /// `Mettre à jour le bilan`
  String get careEpisodeReportsWorkspace_updateAssessment {
    return Intl.message(
      'Mettre à jour le bilan',
      name: 'careEpisodeReportsWorkspace_updateAssessment',
      desc: '',
      args: [],
    );
  }

  /// `Mettre à jour le rapport`
  String get careEpisodeReportsWorkspace_updateReport {
    return Intl.message(
      'Mettre à jour le rapport',
      name: 'careEpisodeReportsWorkspace_updateReport',
      desc: '',
      args: [],
    );
  }

  /// `Annuler`
  String get careEpisodeReportsWorkspaceScreen_cancel {
    return Intl.message(
      'Annuler',
      name: 'careEpisodeReportsWorkspaceScreen_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Autoriser un dossier`
  String get careEpisodeReportsWorkspaceScreen_authorizeDirectory {
    return Intl.message(
      'Autoriser un dossier',
      name: 'careEpisodeReportsWorkspaceScreen_authorizeDirectory',
      desc: '',
      args: [],
    );
  }

  /// `Un DOCX est déjà associé à ce bilan. Voulez-vous remplacer le fichier existant ou créer un nouveau fichier ?`
  String get careEpisodeReportsWorkspaceScreen_existingAssessmentDocx {
    return Intl.message(
      'Un DOCX est déjà associé à ce bilan. Voulez-vous remplacer le fichier existant ou créer un nouveau fichier ?',
      name: 'careEpisodeReportsWorkspaceScreen_existingAssessmentDocx',
      desc: '',
      args: [],
    );
  }

  /// `Un DOCX est déjà associé à ce rapport. Voulez-vous remplacer le fichier existant ou créer un nouveau fichier ?`
  String get careEpisodeReportsWorkspaceScreen_existingReportDocx {
    return Intl.message(
      'Un DOCX est déjà associé à ce rapport. Voulez-vous remplacer le fichier existant ou créer un nouveau fichier ?',
      name: 'careEpisodeReportsWorkspaceScreen_existingReportDocx',
      desc: '',
      args: [],
    );
  }

  /// `Créer un nouveau`
  String get careEpisodeReportsWorkspaceScreen_createNew {
    return Intl.message(
      'Créer un nouveau',
      name: 'careEpisodeReportsWorkspaceScreen_createNew',
      desc: '',
      args: [],
    );
  }

  /// `Remplacer`
  String get careEpisodeReportsWorkspaceScreen_replace {
    return Intl.message(
      'Remplacer',
      name: 'careEpisodeReportsWorkspaceScreen_replace',
      desc: '',
      args: [],
    );
  }

  /// `Rédacteur`
  String get careEpisodeReportsWorkspaceScreen_author {
    return Intl.message(
      'Rédacteur',
      name: 'careEpisodeReportsWorkspaceScreen_author',
      desc: '',
      args: [],
    );
  }

  /// `Valider`
  String get careEpisodeReportsWorkspaceScreen_confirm {
    return Intl.message(
      'Valider',
      name: 'careEpisodeReportsWorkspaceScreen_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Destinataire(s)`
  String get careEpisodeReportsWorkspaceScreen_recipients {
    return Intl.message(
      'Destinataire(s)',
      name: 'careEpisodeReportsWorkspaceScreen_recipients',
      desc: '',
      args: [],
    );
  }

  /// `Un travail en cours a déjà été sauvegardé automatiquement.<br><br>Souhaitez-vous reprendre ce brouillon ou commencer un nouveau rapport ?`
  String get careEpisodeReportsWorkspaceScreen_resumeReportDraftMessage {
    return Intl.message(
      'Un travail en cours a déjà été sauvegardé automatiquement.<br><br>Souhaitez-vous reprendre ce brouillon ou commencer un nouveau rapport ?',
      name: 'careEpisodeReportsWorkspaceScreen_resumeReportDraftMessage',
      desc: '',
      args: [],
    );
  }

  /// `Un travail en cours a déjà été sauvegardé automatiquement.<br><br>Souhaitez-vous reprendre ce brouillon ou commencer un nouveau bilan ?`
  String get careEpisodeReportsWorkspaceScreen_resumeAssessmentDraftMessage {
    return Intl.message(
      'Un travail en cours a déjà été sauvegardé automatiquement.<br><br>Souhaitez-vous reprendre ce brouillon ou commencer un nouveau bilan ?',
      name: 'careEpisodeReportsWorkspaceScreen_resumeAssessmentDraftMessage',
      desc: '',
      args: [],
    );
  }

  /// `Reprendre le brouillon`
  String get careEpisodeReportsWorkspaceScreen_resumeDraft {
    return Intl.message(
      'Reprendre le brouillon',
      name: 'careEpisodeReportsWorkspaceScreen_resumeDraft',
      desc: '',
      args: [],
    );
  }

  /// `Nouveau rapport`
  String get careEpisodeReportsWorkspaceScreen_newReport {
    return Intl.message(
      'Nouveau rapport',
      name: 'careEpisodeReportsWorkspaceScreen_newReport',
      desc: '',
      args: [],
    );
  }

  /// `Nouveau bilan`
  String get careEpisodeReportsWorkspaceScreen_newAssessment {
    return Intl.message(
      'Nouveau bilan',
      name: 'careEpisodeReportsWorkspaceScreen_newAssessment',
      desc: '',
      args: [],
    );
  }

  /// `Impossible d’ouvrir le brouillon du rapport.`
  String get careEpisodeReportsWorkspaceScreen_openReportDraftError {
    return Intl.message(
      'Impossible d’ouvrir le brouillon du rapport.',
      name: 'careEpisodeReportsWorkspaceScreen_openReportDraftError',
      desc: '',
      args: [],
    );
  }

  /// `Le rapport est introuvable.`
  String get careEpisodeReportsWorkspaceScreen_reportNotFound {
    return Intl.message(
      'Le rapport est introuvable.',
      name: 'careEpisodeReportsWorkspaceScreen_reportNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Impossible d’ouvrir le rapport.`
  String get careEpisodeReportsWorkspaceScreen_openReportError {
    return Intl.message(
      'Impossible d’ouvrir le rapport.',
      name: 'careEpisodeReportsWorkspaceScreen_openReportError',
      desc: '',
      args: [],
    );
  }

  /// `Impossible de revenir au brouillon du rapport.`
  String get careEpisodeReportsWorkspaceScreen_returnToReportDraftError {
    return Intl.message(
      'Impossible de revenir au brouillon du rapport.',
      name: 'careEpisodeReportsWorkspaceScreen_returnToReportDraftError',
      desc: '',
      args: [],
    );
  }

  /// `Impossible d’annuler les modifications du rapport.`
  String get careEpisodeReportsWorkspaceScreen_cancelReportChangesError {
    return Intl.message(
      'Impossible d’annuler les modifications du rapport.',
      name: 'careEpisodeReportsWorkspaceScreen_cancelReportChangesError',
      desc: '',
      args: [],
    );
  }

  /// `Le bilan est introuvable.`
  String get careEpisodeReportsWorkspaceScreen_assessmentNotFound {
    return Intl.message(
      'Le bilan est introuvable.',
      name: 'careEpisodeReportsWorkspaceScreen_assessmentNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Dupliquer le bilan`
  String get careEpisodeReportsWorkspaceScreen_duplicateAssessment {
    return Intl.message(
      'Dupliquer le bilan',
      name: 'careEpisodeReportsWorkspaceScreen_duplicateAssessment',
      desc: '',
      args: [],
    );
  }

  /// `Titre du nouveau bilan`
  String get careEpisodeReportsWorkspaceScreen_newAssessmentTitle {
    return Intl.message(
      'Titre du nouveau bilan',
      name: 'careEpisodeReportsWorkspaceScreen_newAssessmentTitle',
      desc: '',
      args: [],
    );
  }

  /// `Dupliquer`
  String get careEpisodeReportsWorkspaceScreen_duplicate {
    return Intl.message(
      'Dupliquer',
      name: 'careEpisodeReportsWorkspaceScreen_duplicate',
      desc: '',
      args: [],
    );
  }

  /// `Impossible de dupliquer le bilan.`
  String get careEpisodeReportsWorkspaceScreen_duplicateAssessmentError {
    return Intl.message(
      'Impossible de dupliquer le bilan.',
      name: 'careEpisodeReportsWorkspaceScreen_duplicateAssessmentError',
      desc: '',
      args: [],
    );
  }

  /// `Dupliquer le rapport`
  String get careEpisodeReportsWorkspaceScreen_duplicateReport {
    return Intl.message(
      'Dupliquer le rapport',
      name: 'careEpisodeReportsWorkspaceScreen_duplicateReport',
      desc: '',
      args: [],
    );
  }

  /// `Titre du nouveau rapport`
  String get careEpisodeReportsWorkspaceScreen_newReportTitle {
    return Intl.message(
      'Titre du nouveau rapport',
      name: 'careEpisodeReportsWorkspaceScreen_newReportTitle',
      desc: '',
      args: [],
    );
  }

  /// `Impossible de dupliquer le rapport.`
  String get careEpisodeReportsWorkspaceScreen_duplicateReportError {
    return Intl.message(
      'Impossible de dupliquer le rapport.',
      name: 'careEpisodeReportsWorkspaceScreen_duplicateReportError',
      desc: '',
      args: [],
    );
  }

  /// `Impossible d’enregistrer la sélection du test.`
  String get careEpisodeReportsWorkspaceScreen_saveTestSelectionError {
    return Intl.message(
      'Impossible d’enregistrer la sélection du test.',
      name: 'careEpisodeReportsWorkspaceScreen_saveTestSelectionError',
      desc: '',
      args: [],
    );
  }

  /// `Impossible d’enregistrer la sélection de la note.`
  String get careEpisodeReportsWorkspaceScreen_saveNoteSelectionError {
    return Intl.message(
      'Impossible d’enregistrer la sélection de la note.',
      name: 'careEpisodeReportsWorkspaceScreen_saveNoteSelectionError',
      desc: '',
      args: [],
    );
  }

  /// `Impossible de revenir au brouillon.`
  String get careEpisodeReportsWorkspaceScreen_returnToDraftError {
    return Intl.message(
      'Impossible de revenir au brouillon.',
      name: 'careEpisodeReportsWorkspaceScreen_returnToDraftError',
      desc: '',
      args: [],
    );
  }

  /// `Impossible d’annuler les modifications.`
  String get careEpisodeReportsWorkspaceScreen_cancelChangesError {
    return Intl.message(
      'Impossible d’annuler les modifications.',
      name: 'careEpisodeReportsWorkspaceScreen_cancelChangesError',
      desc: '',
      args: [],
    );
  }

  /// `Mettre à la corbeille`
  String get careEpisodeReportsWorkspaceScreen_moveToTrash {
    return Intl.message(
      'Mettre à la corbeille',
      name: 'careEpisodeReportsWorkspaceScreen_moveToTrash',
      desc: '',
      args: [],
    );
  }

  /// `Impossible de mettre le bilan à la corbeille.`
  String get careEpisodeReportsWorkspaceScreen_archiveAssessmentError {
    return Intl.message(
      'Impossible de mettre le bilan à la corbeille.',
      name: 'careEpisodeReportsWorkspaceScreen_archiveAssessmentError',
      desc: '',
      args: [],
    );
  }

  /// `Impossible de mettre le rapport à la corbeille.`
  String get careEpisodeReportsWorkspaceScreen_archiveReportError {
    return Intl.message(
      'Impossible de mettre le rapport à la corbeille.',
      name: 'careEpisodeReportsWorkspaceScreen_archiveReportError',
      desc: '',
      args: [],
    );
  }

  /// `Impossible de restaurer le bilan`
  String get careEpisodeReportsWorkspaceScreen_restoreAssessmentError {
    return Intl.message(
      'Impossible de restaurer le bilan',
      name: 'careEpisodeReportsWorkspaceScreen_restoreAssessmentError',
      desc: '',
      args: [],
    );
  }

  /// `Impossible de restaurer le rapport.`
  String get careEpisodeReportsWorkspaceScreen_restoreReportError {
    return Intl.message(
      'Impossible de restaurer le rapport.',
      name: 'careEpisodeReportsWorkspaceScreen_restoreReportError',
      desc: '',
      args: [],
    );
  }

  /// `Supprimer définitivement le bilan ?`
  String get careEpisodeReportsWorkspaceScreen_deleteAssessmentTitle {
    return Intl.message(
      'Supprimer définitivement le bilan ?',
      name: 'careEpisodeReportsWorkspaceScreen_deleteAssessmentTitle',
      desc: '',
      args: [],
    );
  }

  /// `Supprimer définitivement`
  String get careEpisodeReportsWorkspaceScreen_deletePermanently {
    return Intl.message(
      'Supprimer définitivement',
      name: 'careEpisodeReportsWorkspaceScreen_deletePermanently',
      desc: '',
      args: [],
    );
  }

  /// `Impossible de supprimer définitivement le bilan.`
  String get careEpisodeReportsWorkspaceScreen_deleteAssessmentError {
    return Intl.message(
      'Impossible de supprimer définitivement le bilan.',
      name: 'careEpisodeReportsWorkspaceScreen_deleteAssessmentError',
      desc: '',
      args: [],
    );
  }

  /// `Supprimer définitivement le rapport ?`
  String get careEpisodeReportsWorkspaceScreen_deleteReportTitle {
    return Intl.message(
      'Supprimer définitivement le rapport ?',
      name: 'careEpisodeReportsWorkspaceScreen_deleteReportTitle',
      desc: '',
      args: [],
    );
  }

  /// `Impossible de supprimer définitivement le rapport.`
  String get careEpisodeReportsWorkspaceScreen_deleteReportError {
    return Intl.message(
      'Impossible de supprimer définitivement le rapport.',
      name: 'careEpisodeReportsWorkspaceScreen_deleteReportError',
      desc: '',
      args: [],
    );
  }

  /// `Mettre à jour le bilan`
  String get careEpisodeReportsWorkspaceScreen_updateAssessment {
    return Intl.message(
      'Mettre à jour le bilan',
      name: 'careEpisodeReportsWorkspaceScreen_updateAssessment',
      desc: '',
      args: [],
    );
  }

  /// `Enregistrer le bilan`
  String get careEpisodeReportsWorkspaceScreen_saveAssessment {
    return Intl.message(
      'Enregistrer le bilan',
      name: 'careEpisodeReportsWorkspaceScreen_saveAssessment',
      desc: '',
      args: [],
    );
  }

  /// `Titre du bilan`
  String get careEpisodeReportsWorkspaceScreen_assessmentTitle {
    return Intl.message(
      'Titre du bilan',
      name: 'careEpisodeReportsWorkspaceScreen_assessmentTitle',
      desc: '',
      args: [],
    );
  }

  /// `Mettre à jour`
  String get careEpisodeReportsWorkspaceScreen_update {
    return Intl.message(
      'Mettre à jour',
      name: 'careEpisodeReportsWorkspaceScreen_update',
      desc: '',
      args: [],
    );
  }

  /// `Enregistrer`
  String get careEpisodeReportsWorkspaceScreen_save {
    return Intl.message(
      'Enregistrer',
      name: 'careEpisodeReportsWorkspaceScreen_save',
      desc: '',
      args: [],
    );
  }

  /// `Impossible de mettre à jour le bilan.`
  String get careEpisodeReportsWorkspaceScreen_updateAssessmentError {
    return Intl.message(
      'Impossible de mettre à jour le bilan.',
      name: 'careEpisodeReportsWorkspaceScreen_updateAssessmentError',
      desc: '',
      args: [],
    );
  }

  /// `Impossible d’enregistrer le bilan.`
  String get careEpisodeReportsWorkspaceScreen_saveAssessmentError {
    return Intl.message(
      'Impossible d’enregistrer le bilan.',
      name: 'careEpisodeReportsWorkspaceScreen_saveAssessmentError',
      desc: '',
      args: [],
    );
  }

  /// `Mettre à jour le rapport`
  String get careEpisodeReportsWorkspaceScreen_updateReport {
    return Intl.message(
      'Mettre à jour le rapport',
      name: 'careEpisodeReportsWorkspaceScreen_updateReport',
      desc: '',
      args: [],
    );
  }

  /// `Enregistrer le rapport`
  String get careEpisodeReportsWorkspaceScreen_saveReport {
    return Intl.message(
      'Enregistrer le rapport',
      name: 'careEpisodeReportsWorkspaceScreen_saveReport',
      desc: '',
      args: [],
    );
  }

  /// `Titre du rapport`
  String get careEpisodeReportsWorkspaceScreen_reportTitle {
    return Intl.message(
      'Titre du rapport',
      name: 'careEpisodeReportsWorkspaceScreen_reportTitle',
      desc: '',
      args: [],
    );
  }

  /// `Impossible de mettre à jour le rapport.`
  String get careEpisodeReportsWorkspaceScreen_updateReportError {
    return Intl.message(
      'Impossible de mettre à jour le rapport.',
      name: 'careEpisodeReportsWorkspaceScreen_updateReportError',
      desc: '',
      args: [],
    );
  }

  /// `Impossible d’enregistrer le rapport.`
  String get careEpisodeReportsWorkspaceScreen_saveReportError {
    return Intl.message(
      'Impossible d’enregistrer le rapport.',
      name: 'careEpisodeReportsWorkspaceScreen_saveReportError',
      desc: '',
      args: [],
    );
  }

  /// `Titre`
  String get careEpisodeReportsWorkspaceScreen_title {
    return Intl.message(
      'Titre',
      name: 'careEpisodeReportsWorkspaceScreen_title',
      desc: '',
      args: [],
    );
  }

  /// `Note`
  String get careEpisodeReportsWorkspaceScreen_note {
    return Intl.message(
      'Note',
      name: 'careEpisodeReportsWorkspaceScreen_note',
      desc: '',
      args: [],
    );
  }

  /// `Ajouter`
  String get careEpisodeReportsWorkspaceScreen_add {
    return Intl.message(
      'Ajouter',
      name: 'careEpisodeReportsWorkspaceScreen_add',
      desc: '',
      args: [],
    );
  }

  /// `Fermer`
  String get careEpisodeReportsWorkspaceScreen_close {
    return Intl.message(
      'Fermer',
      name: 'careEpisodeReportsWorkspaceScreen_close',
      desc: '',
      args: [],
    );
  }

  /// `Zone de rédaction du bilan SOAP.<br><br>S — Subjectif<br><br>O — Objectif<br><br>A — Analyse<br><br>P — Plan`
  String get careEpisodeReportsWorkspaceScreen_soapEditorHint {
    return Intl.message(
      'Zone de rédaction du bilan SOAP.<br><br>S — Subjectif<br><br>O — Objectif<br><br>A — Analyse<br><br>P — Plan',
      name: 'careEpisodeReportsWorkspaceScreen_soapEditorHint',
      desc: '',
      args: [],
    );
  }

  /// `Ajouter à la suite`
  String get careEpisodeReportsWorkspaceScreen_append {
    return Intl.message(
      'Ajouter à la suite',
      name: 'careEpisodeReportsWorkspaceScreen_append',
      desc: '',
      args: [],
    );
  }

  /// `rapport`
  String get careEpisodeReportsWorkspaceScreen_reportLabel {
    return Intl.message(
      'rapport',
      name: 'careEpisodeReportsWorkspaceScreen_reportLabel',
      desc: '',
      args: [],
    );
  }

  /// `bilan`
  String get careEpisodeReportsWorkspaceScreen_assessmentLabel {
    return Intl.message(
      'bilan',
      name: 'careEpisodeReportsWorkspaceScreen_assessmentLabel',
      desc: '',
      args: [],
    );
  }

  /// `Kiné référent`
  String get careEpisodeReportsWorkspaceScreen_referringPractitioner {
    return Intl.message(
      'Kiné référent',
      name: 'careEpisodeReportsWorkspaceScreen_referringPractitioner',
      desc: '',
      args: [],
    );
  }

  /// `Gérer les kinés`
  String get careEpisodeReportsWorkspaceScreen_managePractitioners {
    return Intl.message(
      'Gérer les kinés',
      name: 'careEpisodeReportsWorkspaceScreen_managePractitioners',
      desc: '',
      args: [],
    );
  }

  /// `Médecin prescripteur`
  String get careEpisodeReportsWorkspaceScreen_prescribingDoctor {
    return Intl.message(
      'Médecin prescripteur',
      name: 'careEpisodeReportsWorkspaceScreen_prescribingDoctor',
      desc: '',
      args: [],
    );
  }

  /// `Gérer les médecins prescripteurs`
  String get careEpisodeReportsWorkspaceScreen_managePrescribingDoctors {
    return Intl.message(
      'Gérer les médecins prescripteurs',
      name: 'careEpisodeReportsWorkspaceScreen_managePrescribingDoctors',
      desc: '',
      args: [],
    );
  }

  /// `Bilans et rapports`
  String get careEpisodeReportsWorkspaceScreen_assessmentsAndReports {
    return Intl.message(
      'Bilans et rapports',
      name: 'careEpisodeReportsWorkspaceScreen_assessmentsAndReports',
      desc: '',
      args: [],
    );
  }

  /// `Votre bilan est prêt. Le DOCX regroupera les informations saisies et les éléments sélectionnés.`
  String get careEpisodeReportsWorkspaceScreen_assessmentReadyMessage {
    return Intl.message(
      'Votre bilan est prêt. Le DOCX regroupera les informations saisies et les éléments sélectionnés.',
      name: 'careEpisodeReportsWorkspaceScreen_assessmentReadyMessage',
      desc: '',
      args: [],
    );
  }

  /// `Votre rapport est prêt. Le DOCX regroupera les informations du patient, du rédacteur et du correspondant.`
  String get careEpisodeReportsWorkspaceScreen_reportReadyMessage {
    return Intl.message(
      'Votre rapport est prêt. Le DOCX regroupera les informations du patient, du rédacteur et du correspondant.',
      name: 'careEpisodeReportsWorkspaceScreen_reportReadyMessage',
      desc: '',
      args: [],
    );
  }

  /// `Générer le DOCX`
  String get careEpisodeReportsWorkspaceScreen_generateDocx {
    return Intl.message(
      'Générer le DOCX',
      name: 'careEpisodeReportsWorkspaceScreen_generateDocx',
      desc: '',
      args: [],
    );
  }

  /// `Document Word créé : {path}`
  String careEpisodeReportsWorkspaceScreen_wordDocumentCreated(Object path) {
    return Intl.message(
      'Document Word créé : $path',
      name: 'careEpisodeReportsWorkspaceScreen_wordDocumentCreated',
      desc: '',
      args: [path],
    );
  }

  /// `Erreur lors de la création du document Word : {error}`
  String careEpisodeReportsWorkspaceScreen_wordDocumentCreationError(
      Object error) {
    return Intl.message(
      'Erreur lors de la création du document Word : $error',
      name: 'careEpisodeReportsWorkspaceScreen_wordDocumentCreationError',
      desc: '',
      args: [error],
    );
  }

  /// `Bilan_{patientName}_{title}`
  String careEpisodeReportsWorkspaceScreen_assessmentFileName(
      Object patientName, Object title) {
    return Intl.message(
      'Bilan_${patientName}_$title',
      name: 'careEpisodeReportsWorkspaceScreen_assessmentFileName',
      desc: '',
      args: [patientName, title],
    );
  }

  /// `Rapport_{patientName}_{title}`
  String careEpisodeReportsWorkspaceScreen_reportFileName(
      Object patientName, Object title) {
    return Intl.message(
      'Rapport_${patientName}_$title',
      name: 'careEpisodeReportsWorkspaceScreen_reportFileName',
      desc: '',
      args: [patientName, title],
    );
  }

  /// `Copie de {title}`
  String careEpisodeReportsWorkspaceScreen_copyTitle(Object title) {
    return Intl.message(
      'Copie de $title',
      name: 'careEpisodeReportsWorkspaceScreen_copyTitle',
      desc: '',
      args: [title],
    );
  }

  /// `Le bilan « {title} » ne sera plus affiché dans l’historique.`
  String careEpisodeReportsWorkspaceScreen_archiveAssessmentMessage(
      Object title) {
    return Intl.message(
      'Le bilan « $title » ne sera plus affiché dans l’historique.',
      name: 'careEpisodeReportsWorkspaceScreen_archiveAssessmentMessage',
      desc: '',
      args: [title],
    );
  }

  /// `"careEpisodeReportsWorkspaceScreen_directoryAccessMessage": "Le dossier configuré n’est pas accessible ou son autorisation doit être renouvelée.\n\n{path}\n\nReconnectez son volume si nécessaire, puis sélectionnez ce dossier pour autoriser son accès. Le dossier sélectionné sera enregistré dans vos préférences.",\n"@careEpisodeReportsWorkspaceScreen_directoryAccessMessage": {\n  "placeholders": {\n    "path": {\n      "type": "String"\n    }\n  }\n}`
  String careEpisodeReportsWorkspaceScreen_directoryAccessMessage(Object path) {
    return Intl.message(
      '"careEpisodeReportsWorkspaceScreen_directoryAccessMessage": "Le dossier configuré n’est pas accessible ou son autorisation doit être renouvelée.\n\n$path\n\nReconnectez son volume si nécessaire, puis sélectionnez ce dossier pour autoriser son accès. Le dossier sélectionné sera enregistré dans vos préférences.",\n"@careEpisodeReportsWorkspaceScreen_directoryAccessMessage": {\n  "placeholders": {\n    "path": {\n      "type": "String"\n    }\n  }\n}',
      name: 'careEpisodeReportsWorkspaceScreen_directoryAccessMessage',
      desc: '',
      args: [path],
    );
  }

  /// `Le rapport « {title} » sera placé dans la corbeille. Il pourra être restauré ultérieurement.`
  String careEpisodeReportsWorkspaceScreen_archiveReportMessage(Object title) {
    return Intl.message(
      'Le rapport « $title » sera placé dans la corbeille. Il pourra être restauré ultérieurement.',
      name: 'careEpisodeReportsWorkspaceScreen_archiveReportMessage',
      desc: '',
      args: [title],
    );
  }

  /// `Le bilan « {title} » sera définitivement supprimé. Cette action est irréversible.`
  String careEpisodeReportsWorkspaceScreen_deleteAssessmentMessage(
      Object title) {
    return Intl.message(
      'Le bilan « $title » sera définitivement supprimé. Cette action est irréversible.',
      name: 'careEpisodeReportsWorkspaceScreen_deleteAssessmentMessage',
      desc: '',
      args: [title],
    );
  }

  /// `Le rapport « {title} » sera définitivement supprimé. Cette action est irréversible.`
  String careEpisodeReportsWorkspaceScreen_deleteReportMessage(Object title) {
    return Intl.message(
      'Le rapport « $title » sera définitivement supprimé. Cette action est irréversible.',
      name: 'careEpisodeReportsWorkspaceScreen_deleteReportMessage',
      desc: '',
      args: [title],
    );
  }

  /// `Souhaitez-vous ajouter le contenu généré à la suite du {documentLabel} actuel ou remplacer le contenu existant ?`
  String careEpisodeReportsWorkspaceScreen_insertTextMessage(
      Object documentLabel) {
    return Intl.message(
      'Souhaitez-vous ajouter le contenu généré à la suite du $documentLabel actuel ou remplacer le contenu existant ?',
      name: 'careEpisodeReportsWorkspaceScreen_insertTextMessage',
      desc: '',
      args: [documentLabel],
    );
  }

  /// `Un brouillon existe déjà pour ce modèle de {documentLabel}.`
  String careEpisodeReportsWorkspaceScreen_existingTemplateDraftMessage(
      Object documentLabel) {
    return Intl.message(
      'Un brouillon existe déjà pour ce modèle de $documentLabel.',
      name: 'careEpisodeReportsWorkspaceScreen_existingTemplateDraftMessage',
      desc: '',
      args: [documentLabel],
    );
  }

  /// `Nouveau {documentLabel}`
  String careEpisodeReportsWorkspaceScreen_newDocument(Object documentLabel) {
    return Intl.message(
      'Nouveau $documentLabel',
      name: 'careEpisodeReportsWorkspaceScreen_newDocument',
      desc: '',
      args: [documentLabel],
    );
  }

  /// `{patientName} — Bilans et rapports`
  String careEpisodeReportsWorkspaceScreen_workspaceTitle(Object patientName) {
    return Intl.message(
      '$patientName — Bilans et rapports',
      name: 'careEpisodeReportsWorkspaceScreen_workspaceTitle',
      desc: '',
      args: [patientName],
    );
  }

  /// `Cet écran permet de préparer et d’enregistrer les bilans et rapports liés à la prise en charge.\n\nPour un bilan, vous pouvez rédiger le texte principal, sélectionner les résultats de tests et les notes de suivi à inclure, puis générer un document DOCX une fois le bilan enregistré.\n\nLes brouillons sont sauvegardés automatiquement tant qu’ils ne sont pas enregistrés comme bilan ou rapport.\n\nL’historique permet de retrouver les bilans et rapports déjà enregistrés.`
  String get clinicalDocuments_help {
    return Intl.message(
      'Cet écran permet de préparer et d’enregistrer les bilans et rapports liés à la prise en charge.\n\nPour un bilan, vous pouvez rédiger le texte principal, sélectionner les résultats de tests et les notes de suivi à inclure, puis générer un document DOCX une fois le bilan enregistré.\n\nLes brouillons sont sauvegardés automatiquement tant qu’ils ne sont pas enregistrés comme bilan ou rapport.\n\nL’historique permet de retrouver les bilans et rapports déjà enregistrés.',
      name: 'clinicalDocuments_help',
      desc: '',
      args: [],
    );
  }

  /// `Bilans et rapports`
  String get clinicalDocuments_title {
    return Intl.message(
      'Bilans et rapports',
      name: 'clinicalDocuments_title',
      desc: '',
      args: [],
    );
  }

  /// `Fermer`
  String get close {
    return Intl.message(
      'Fermer',
      name: 'close',
      desc: '',
      args: [],
    );
  }

  /// `Catégorie`
  String get contactFormTemplateDiagnostic_category {
    return Intl.message(
      'Catégorie',
      name: 'contactFormTemplateDiagnostic_category',
      desc: '',
      args: [],
    );
  }

  /// `Modèle par défaut`
  String get contactFormTemplateDiagnostic_defaultTemplate {
    return Intl.message(
      'Modèle par défaut',
      name: 'contactFormTemplateDiagnostic_defaultTemplate',
      desc: '',
      args: [],
    );
  }

  /// `Erreur`
  String get contactFormTemplateDiagnostic_error {
    return Intl.message(
      'Erreur',
      name: 'contactFormTemplateDiagnostic_error',
      desc: '',
      args: [],
    );
  }

  /// `Champs`
  String get contactFormTemplateDiagnostic_fields {
    return Intl.message(
      'Champs',
      name: 'contactFormTemplateDiagnostic_fields',
      desc: '',
      args: [],
    );
  }

  /// `Non`
  String get contactFormTemplateDiagnostic_no {
    return Intl.message(
      'Non',
      name: 'contactFormTemplateDiagnostic_no',
      desc: '',
      args: [],
    );
  }

  /// `Aucune donnée à afficher.`
  String get contactFormTemplateDiagnostic_noData {
    return Intl.message(
      'Aucune donnée à afficher.',
      name: 'contactFormTemplateDiagnostic_noData',
      desc: '',
      args: [],
    );
  }

  /// `Non définie`
  String get contactFormTemplateDiagnostic_notDefined {
    return Intl.message(
      'Non définie',
      name: 'contactFormTemplateDiagnostic_notDefined',
      desc: '',
      args: [],
    );
  }

  /// `Aucun modèle de fiche d’entretien initial trouvé.`
  String get contactFormTemplateDiagnostic_noTemplate {
    return Intl.message(
      'Aucun modèle de fiche d’entretien initial trouvé.',
      name: 'contactFormTemplateDiagnostic_noTemplate',
      desc: '',
      args: [],
    );
  }

  /// `Ordre`
  String get contactFormTemplateDiagnostic_order {
    return Intl.message(
      'Ordre',
      name: 'contactFormTemplateDiagnostic_order',
      desc: '',
      args: [],
    );
  }

  /// `Praticien`
  String get contactFormTemplateDiagnostic_practitioner {
    return Intl.message(
      'Praticien',
      name: 'contactFormTemplateDiagnostic_practitioner',
      desc: '',
      args: [],
    );
  }

  /// `Actualiser`
  String get contactFormTemplateDiagnostic_refresh {
    return Intl.message(
      'Actualiser',
      name: 'contactFormTemplateDiagnostic_refresh',
      desc: '',
      args: [],
    );
  }

  /// `Obligatoire`
  String get contactFormTemplateDiagnostic_required {
    return Intl.message(
      'Obligatoire',
      name: 'contactFormTemplateDiagnostic_required',
      desc: '',
      args: [],
    );
  }

  /// `Modèle système`
  String get contactFormTemplateDiagnostic_systemTemplate {
    return Intl.message(
      'Modèle système',
      name: 'contactFormTemplateDiagnostic_systemTemplate',
      desc: '',
      args: [],
    );
  }

  /// `ID modèle`
  String get contactFormTemplateDiagnostic_templateId {
    return Intl.message(
      'ID modèle',
      name: 'contactFormTemplateDiagnostic_templateId',
      desc: '',
      args: [],
    );
  }

  /// `Diagnostic fiche d’entretien`
  String get contactFormTemplateDiagnostic_title {
    return Intl.message(
      'Diagnostic fiche d’entretien',
      name: 'contactFormTemplateDiagnostic_title',
      desc: '',
      args: [],
    );
  }

  /// `Type`
  String get contactFormTemplateDiagnostic_type {
    return Intl.message(
      'Type',
      name: 'contactFormTemplateDiagnostic_type',
      desc: '',
      args: [],
    );
  }

  /// `Oui`
  String get contactFormTemplateDiagnostic_yes {
    return Intl.message(
      'Oui',
      name: 'contactFormTemplateDiagnostic_yes',
      desc: '',
      args: [],
    );
  }

  /// `Station clinique locale ABAK`
  String get dashboardTitle {
    return Intl.message(
      'Station clinique locale ABAK',
      name: 'dashboardTitle',
      desc: '',
      args: [],
    );
  }

  /// `Adresse`
  String get desktopAddress {
    return Intl.message(
      'Adresse',
      name: 'desktopAddress',
      desc: '',
      args: [],
    );
  }

  /// `Port`
  String get desktopPort {
    return Intl.message(
      'Port',
      name: 'desktopPort',
      desc: '',
      args: [],
    );
  }

  /// `Praticien associé`
  String get deviceForm_associatedPractitioner {
    return Intl.message(
      'Praticien associé',
      name: 'deviceForm_associatedPractitioner',
      desc: '',
      args: [],
    );
  }

  /// `Annuler`
  String get deviceForm_cancel {
    return Intl.message(
      'Annuler',
      name: 'deviceForm_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Nouvel appareil`
  String get deviceForm_contextName {
    return Intl.message(
      'Nouvel appareil',
      name: 'deviceForm_contextName',
      desc: '',
      args: [],
    );
  }

  /// `Créer`
  String get deviceForm_create {
    return Intl.message(
      'Créer',
      name: 'deviceForm_create',
      desc: '',
      args: [],
    );
  }

  /// `Nom de l’appareil`
  String get deviceForm_deviceName {
    return Intl.message(
      'Nom de l’appareil',
      name: 'deviceForm_deviceName',
      desc: '',
      args: [],
    );
  }

  /// `iPhone Claire, Pixel Marc…`
  String get deviceForm_deviceNameHint {
    return Intl.message(
      'iPhone Claire, Pixel Marc…',
      name: 'deviceForm_deviceNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Le nom de l’appareil est obligatoire`
  String get deviceForm_deviceNameRequired {
    return Intl.message(
      'Le nom de l’appareil est obligatoire',
      name: 'deviceForm_deviceNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Modifier l’appareil`
  String get deviceForm_editDevice {
    return Intl.message(
      'Modifier l’appareil',
      name: 'deviceForm_editDevice',
      desc: '',
      args: [],
    );
  }

  /// `Cette fenêtre permet de créer ou de modifier la fiche d’un appareil dans Companion.\n\nSaisissez un nom permettant de reconnaître facilement le téléphone ou la tablette. Ce nom est obligatoire.\n\nSélectionnez la plateforme de l’appareil : iOS ou Android.\n\nVous pouvez associer l’appareil à un praticien de la liste ou choisir l’option d’appareil partagé pour ne pas l’affecter à un praticien particulier.\n\nCliquez sur « Créer » pour ajouter l’appareil ou sur « Enregistrer » pour valider les modifications. « Annuler » ferme la fenêtre sans appliquer les modifications.\n\nL’ouverture et la fermeture de cette aide conservent votre saisie dans le formulaire.`
  String get deviceForm_help {
    return Intl.message(
      'Cette fenêtre permet de créer ou de modifier la fiche d’un appareil dans Companion.\n\nSaisissez un nom permettant de reconnaître facilement le téléphone ou la tablette. Ce nom est obligatoire.\n\nSélectionnez la plateforme de l’appareil : iOS ou Android.\n\nVous pouvez associer l’appareil à un praticien de la liste ou choisir l’option d’appareil partagé pour ne pas l’affecter à un praticien particulier.\n\nCliquez sur « Créer » pour ajouter l’appareil ou sur « Enregistrer » pour valider les modifications. « Annuler » ferme la fenêtre sans appliquer les modifications.\n\nL’ouverture et la fermeture de cette aide conservent votre saisie dans le formulaire.',
      name: 'deviceForm_help',
      desc: '',
      args: [],
    );
  }

  /// `Erreur lors du chargement des praticiens`
  String get deviceForm_loadingPractitionersError {
    return Intl.message(
      'Erreur lors du chargement des praticiens',
      name: 'deviceForm_loadingPractitionersError',
      desc: '',
      args: [],
    );
  }

  /// `Nouvel appareil`
  String get deviceForm_newDevice {
    return Intl.message(
      'Nouvel appareil',
      name: 'deviceForm_newDevice',
      desc: '',
      args: [],
    );
  }

  /// `Plateforme`
  String get deviceForm_platform {
    return Intl.message(
      'Plateforme',
      name: 'deviceForm_platform',
      desc: '',
      args: [],
    );
  }

  /// `Enregistrer`
  String get deviceForm_save {
    return Intl.message(
      'Enregistrer',
      name: 'deviceForm_save',
      desc: '',
      args: [],
    );
  }

  /// `Aucun / appareil partagé`
  String get deviceForm_sharedDevice {
    return Intl.message(
      'Aucun / appareil partagé',
      name: 'deviceForm_sharedDevice',
      desc: '',
      args: [],
    );
  }

  /// `Actifs`
  String get deviceList_active {
    return Intl.message(
      'Actifs',
      name: 'deviceList_active',
      desc: '',
      args: [],
    );
  }

  /// `Archiver`
  String get deviceList_archive {
    return Intl.message(
      'Archiver',
      name: 'deviceList_archive',
      desc: '',
      args: [],
    );
  }

  /// `Voulez-vous vraiment archiver {deviceName} ?`
  String deviceList_archiveConfirmation(Object deviceName) {
    return Intl.message(
      'Voulez-vous vraiment archiver $deviceName ?',
      name: 'deviceList_archiveConfirmation',
      desc: '',
      args: [deviceName],
    );
  }

  /// `Archivés`
  String get deviceList_archived {
    return Intl.message(
      'Archivés',
      name: 'deviceList_archived',
      desc: '',
      args: [],
    );
  }

  /// `La corbeille des appareils est vide pour le moment.`
  String get deviceList_archivedDevicesEmpty {
    return Intl.message(
      'La corbeille des appareils est vide pour le moment.',
      name: 'deviceList_archivedDevicesEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Archivé le`
  String get deviceList_archivedOn {
    return Intl.message(
      'Archivé le',
      name: 'deviceList_archivedOn',
      desc: '',
      args: [],
    );
  }

  /// `Archiver l’appareil`
  String get deviceList_archiveTitle {
    return Intl.message(
      'Archiver l’appareil',
      name: 'deviceList_archiveTitle',
      desc: '',
      args: [],
    );
  }

  /// `Praticien associé`
  String get deviceList_associatedPractitioner {
    return Intl.message(
      'Praticien associé',
      name: 'deviceList_associatedPractitioner',
      desc: '',
      args: [],
    );
  }

  /// `Annuler`
  String get deviceList_cancel {
    return Intl.message(
      'Annuler',
      name: 'deviceList_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Cet écran montre la liste des appareils connectés à l’établissement`
  String get deviceList_contextComment {
    return Intl.message(
      'Cet écran montre la liste des appareils connectés à l’établissement',
      name: 'deviceList_contextComment',
      desc: '',
      args: [],
    );
  }

  /// `Liste des appareils`
  String get deviceList_contextName {
    return Intl.message(
      'Liste des appareils',
      name: 'deviceList_contextName',
      desc: '',
      args: [],
    );
  }

  /// `Modifier`
  String get deviceList_edit {
    return Intl.message(
      'Modifier',
      name: 'deviceList_edit',
      desc: '',
      args: [],
    );
  }

  /// `Erreur`
  String get deviceList_error {
    return Intl.message(
      'Erreur',
      name: 'deviceList_error',
      desc: '',
      args: [],
    );
  }

  /// `Nouvel appareil`
  String get deviceList_newDevice {
    return Intl.message(
      'Nouvel appareil',
      name: 'deviceList_newDevice',
      desc: '',
      args: [],
    );
  }

  /// `Aucun appareil archivé`
  String get deviceList_noArchivedDevices {
    return Intl.message(
      'Aucun appareil archivé',
      name: 'deviceList_noArchivedDevices',
      desc: '',
      args: [],
    );
  }

  /// `Aucun appareil associé`
  String get deviceList_noPairedDevices {
    return Intl.message(
      'Aucun appareil associé',
      name: 'deviceList_noPairedDevices',
      desc: '',
      args: [],
    );
  }

  /// `Les appareils ABAK associés à l’établissement apparaîtront ici.`
  String get deviceList_pairedDevicesExplanation {
    return Intl.message(
      'Les appareils ABAK associés à l’établissement apparaîtront ici.',
      name: 'deviceList_pairedDevicesExplanation',
      desc: '',
      args: [],
    );
  }

  /// `Plateforme`
  String get deviceList_platform {
    return Intl.message(
      'Plateforme',
      name: 'deviceList_platform',
      desc: '',
      args: [],
    );
  }

  /// `Restaurer`
  String get deviceList_restore {
    return Intl.message(
      'Restaurer',
      name: 'deviceList_restore',
      desc: '',
      args: [],
    );
  }

  /// `Afficher le QR Code`
  String get deviceList_showQrCode {
    return Intl.message(
      'Afficher le QR Code',
      name: 'deviceList_showQrCode',
      desc: '',
      args: [],
    );
  }

  /// `Liste des appareils`
  String get deviceList_title {
    return Intl.message(
      'Liste des appareils',
      name: 'deviceList_title',
      desc: '',
      args: [],
    );
  }

  /// `Cette fenêtre affiche le QR code d’identification de l’appareil, accompagné de son nom, du nom du cabinet et de sa plateforme.\n\nScannez ce QR code depuis ABAK Mobile pour identifier cet appareil dans cet établissement. Vérifiez que le nom affiché correspond bien au téléphone ou à la tablette concernée.\n\nCe QR code sert à identifier l’appareil ; son affichage ne déclenche pas de transfert de résultats.\n\nFermez cette fenêtre pour revenir à la liste des appareils.`
  String get deviceQr_help {
    return Intl.message(
      'Cette fenêtre affiche le QR code d’identification de l’appareil, accompagné de son nom, du nom du cabinet et de sa plateforme.\n\nScannez ce QR code depuis ABAK Mobile pour identifier cet appareil dans cet établissement. Vérifiez que le nom affiché correspond bien au téléphone ou à la tablette concernée.\n\nCe QR code sert à identifier l’appareil ; son affichage ne déclenche pas de transfert de résultats.\n\nFermez cette fenêtre pour revenir à la liste des appareils.',
      name: 'deviceQr_help',
      desc: '',
      args: [],
    );
  }

  /// `Appareil ABAK`
  String get deviceQr_title {
    return Intl.message(
      'Appareil ABAK',
      name: 'deviceQr_title',
      desc: '',
      args: [],
    );
  }

  /// `La mise à la corbeille retire le bilan ou le rapport de son historique habituel.\n\nLe document reste conservé dans Companion. Vous pouvez le retrouver dans les documents archivés et le restaurer pour le faire réapparaître dans l’historique.\n\nLes fichiers DOCX déjà exportés sur votre ordinateur ne sont pas supprimés par cette action.\n\nCliquez sur « Mettre à la corbeille » pour confirmer, ou sur « Annuler » pour conserver le document dans l’historique.`
  String get documentArchiveConfirm_help {
    return Intl.message(
      'La mise à la corbeille retire le bilan ou le rapport de son historique habituel.\n\nLe document reste conservé dans Companion. Vous pouvez le retrouver dans les documents archivés et le restaurer pour le faire réapparaître dans l’historique.\n\nLes fichiers DOCX déjà exportés sur votre ordinateur ne sont pas supprimés par cette action.\n\nCliquez sur « Mettre à la corbeille » pour confirmer, ou sur « Annuler » pour conserver le document dans l’historique.',
      name: 'documentArchiveConfirm_help',
      desc: '',
      args: [],
    );
  }

  /// `Mettre le document à la corbeille ?`
  String get documentArchiveConfirm_title {
    return Intl.message(
      'Mettre le document à la corbeille ?',
      name: 'documentArchiveConfirm_title',
      desc: '',
      args: [],
    );
  }

  /// `Cette fenêtre permet de choisir le praticien désigné comme rédacteur du bilan ou du rapport en cours.\n\nSélectionnez le praticien dans la liste, puis cliquez sur « Valider » pour enregistrer cette association au document.\n\nCe choix concerne le rédacteur du document ; il ne modifie pas le praticien référent de l’épisode de soins.\n\n« Annuler » ferme la fenêtre sans changer le rédacteur.`
  String get documentAuthor_help {
    return Intl.message(
      'Cette fenêtre permet de choisir le praticien désigné comme rédacteur du bilan ou du rapport en cours.\n\nSélectionnez le praticien dans la liste, puis cliquez sur « Valider » pour enregistrer cette association au document.\n\nCe choix concerne le rédacteur du document ; il ne modifie pas le praticien référent de l’épisode de soins.\n\n« Annuler » ferme la fenêtre sans changer le rédacteur.',
      name: 'documentAuthor_help',
      desc: '',
      args: [],
    );
  }

  /// `Companion ne peut pas accéder au dossier prévu pour enregistrer les documents, ou son autorisation d’accès doit être renouvelée.\n\nSi ce dossier se trouve sur un disque externe ou un emplacement réseau, vérifiez d’abord qu’il est connecté et accessible.\n\nCliquez sur « Autoriser un dossier », puis sélectionnez le dossier dans la fenêtre qui s’ouvre. Vous pouvez sélectionner le dossier habituel ou choisir une autre destination.\n\nLe dossier sélectionné est enregistré dans vos préférences pour les prochains exports. Les fichiers déjà présents dans l’ancien dossier ne sont pas déplacés.\n\n« Annuler » interrompt l’export en cours sans modifier votre bilan ou votre rapport.`
  String get documentDirectoryAccess_help {
    return Intl.message(
      'Companion ne peut pas accéder au dossier prévu pour enregistrer les documents, ou son autorisation d’accès doit être renouvelée.\n\nSi ce dossier se trouve sur un disque externe ou un emplacement réseau, vérifiez d’abord qu’il est connecté et accessible.\n\nCliquez sur « Autoriser un dossier », puis sélectionnez le dossier dans la fenêtre qui s’ouvre. Vous pouvez sélectionner le dossier habituel ou choisir une autre destination.\n\nLe dossier sélectionné est enregistré dans vos préférences pour les prochains exports. Les fichiers déjà présents dans l’ancien dossier ne sont pas déplacés.\n\n« Annuler » interrompt l’export en cours sans modifier votre bilan ou votre rapport.',
      name: 'documentDirectoryAccess_help',
      desc: '',
      args: [],
    );
  }

  /// `Autoriser le dossier des documents`
  String get documentDirectoryAccess_title {
    return Intl.message(
      'Autoriser le dossier des documents',
      name: 'documentDirectoryAccess_title',
      desc: '',
      args: [],
    );
  }

  /// `Un fichier DOCX a déjà été associé à ce bilan ou à ce rapport.\n\n« Créer un nouveau » génère un nouveau fichier avec le contenu actuel du document. Si son nom existe déjà dans le dossier de destination, un numéro est ajouté pour conserver le fichier précédent. Le nouveau fichier devient celui associé au document dans Companion.\n\n« Remplacer » réécrit le fichier portant le nom associé au document dans le dossier de destination. Les éventuelles modifications apportées directement à ce fichier dans Word ou LibreOffice seront écrasées.\n\n« Annuler » abandonne l’export sans modifier les fichiers.`
  String get documentDocxExisting_help {
    return Intl.message(
      'Un fichier DOCX a déjà été associé à ce bilan ou à ce rapport.\n\n« Créer un nouveau » génère un nouveau fichier avec le contenu actuel du document. Si son nom existe déjà dans le dossier de destination, un numéro est ajouté pour conserver le fichier précédent. Le nouveau fichier devient celui associé au document dans Companion.\n\n« Remplacer » réécrit le fichier portant le nom associé au document dans le dossier de destination. Les éventuelles modifications apportées directement à ce fichier dans Word ou LibreOffice seront écrasées.\n\n« Annuler » abandonne l’export sans modifier les fichiers.',
      name: 'documentDocxExisting_help',
      desc: '',
      args: [],
    );
  }

  /// `Un DOCX existe déjà`
  String get documentDocxExisting_title {
    return Intl.message(
      'Un DOCX existe déjà',
      name: 'documentDocxExisting_title',
      desc: '',
      args: [],
    );
  }

  /// `Un texte en cours de rédaction a déjà été sauvegardé automatiquement pour ce type de document.\n\n« Reprendre le brouillon » vous permet de retrouver ce texte et de poursuivre votre rédaction.\n\n« Nouveau bilan » ou « Nouveau rapport » efface le titre et le texte de ce brouillon pour recommencer. Le brouillon précédent n’est pas conservé comme un document séparé. Si vous souhaitez garder votre travail, reprenez-le et enregistrez-le avant de commencer un nouveau document.\n\n« Annuler » ferme cette fenêtre sans modifier le brouillon.`
  String get documentDraftChoice_help {
    return Intl.message(
      'Un texte en cours de rédaction a déjà été sauvegardé automatiquement pour ce type de document.\n\n« Reprendre le brouillon » vous permet de retrouver ce texte et de poursuivre votre rédaction.\n\n« Nouveau bilan » ou « Nouveau rapport » efface le titre et le texte de ce brouillon pour recommencer. Le brouillon précédent n’est pas conservé comme un document séparé. Si vous souhaitez garder votre travail, reprenez-le et enregistrez-le avant de commencer un nouveau document.\n\n« Annuler » ferme cette fenêtre sans modifier le brouillon.',
      name: 'documentDraftChoice_help',
      desc: '',
      args: [],
    );
  }

  /// `Un brouillon existe`
  String get documentDraftChoice_title {
    return Intl.message(
      'Un brouillon existe',
      name: 'documentDraftChoice_title',
      desc: '',
      args: [],
    );
  }

  /// `Cette fenêtre offre davantage d’espace pour rédiger ou modifier le texte du bilan ou du rapport en cours.\n\nVos modifications sont répercutées au fur et à mesure dans la zone de rédaction principale. Fermer la fenêtre ne les annule pas.\n\nCliquez sur la croix pour revenir à l’espace Bilans/Rapports, puis poursuivez la préparation et l’enregistrement de votre document.\n\nL’ouverture et la fermeture de cette aide conservent le texte saisi.`
  String get documentExpandedEditor_help {
    return Intl.message(
      'Cette fenêtre offre davantage d’espace pour rédiger ou modifier le texte du bilan ou du rapport en cours.\n\nVos modifications sont répercutées au fur et à mesure dans la zone de rédaction principale. Fermer la fenêtre ne les annule pas.\n\nCliquez sur la croix pour revenir à l’espace Bilans/Rapports, puis poursuivez la préparation et l’enregistrement de votre document.\n\nL’ouverture et la fermeture de cette aide conservent le texte saisi.',
      name: 'documentExpandedEditor_help',
      desc: '',
      args: [],
    );
  }

  /// `Choisir le rédacteur`
  String get documentAuthor_title {
    return Intl.message(
      'Choisir le rédacteur',
      name: 'documentAuthor_title',
      desc: '',
      args: [],
    );
  }

  /// `Rédiger dans la vue agrandie`
  String get documentExpandedEditor_helpTitle {
    return Intl.message(
      'Rédiger dans la vue agrandie',
      name: 'documentExpandedEditor_helpTitle',
      desc: '',
      args: [],
    );
  }

  /// `Cette fenêtre permet de renseigner les destinataires du bilan ou du rapport en cours.\n\nSaisissez librement le nom du destinataire ou les noms des différents destinataires, puis cliquez sur « Valider » pour conserver cette information dans le document.\n\nPour supprimer une mention existante, effacez le contenu du champ puis validez.\n\nCette saisie renseigne les destinataires du document ; elle ne déclenche aucun envoi.\n\n« Annuler » ferme la fenêtre sans appliquer les modifications. L’ouverture et la fermeture de cette aide conservent votre saisie.`
  String get documentRecipient_help {
    return Intl.message(
      'Cette fenêtre permet de renseigner les destinataires du bilan ou du rapport en cours.\n\nSaisissez librement le nom du destinataire ou les noms des différents destinataires, puis cliquez sur « Valider » pour conserver cette information dans le document.\n\nPour supprimer une mention existante, effacez le contenu du champ puis validez.\n\nCette saisie renseigne les destinataires du document ; elle ne déclenche aucun envoi.\n\n« Annuler » ferme la fenêtre sans appliquer les modifications. L’ouverture et la fermeture de cette aide conservent votre saisie.',
      name: 'documentRecipient_help',
      desc: '',
      args: [],
    );
  }

  /// `Destinataire(s)`
  String get documentRecipient_title {
    return Intl.message(
      'Destinataire(s)',
      name: 'documentRecipient_title',
      desc: '',
      args: [],
    );
  }

  /// `Choisir un modèle de bilan`
  String get documentTemplate_assessmentTitle {
    return Intl.message(
      'Choisir un modèle de bilan',
      name: 'documentTemplate_assessmentTitle',
      desc: '',
      args: [],
    );
  }

  /// `Ce guide vous aide à préparer le contenu d’un bilan ou d’un rapport à partir du modèle sélectionné.\n\nUtilisez la liste des rubriques à gauche pour accéder aux différentes sections. Selon les champs proposés, saisissez du texte, sélectionnez des réponses ou complétez les tableaux.\n\nLe bouton de prévisualisation, situé en bas du formulaire, permet de consulter le texte produit à partir de vos réponses.\n\nDepuis l’aperçu, vous pouvez revenir au guide pour poursuivre votre saisie ou demander l’insertion du texte dans le bilan ou le rapport. Suivez les éventuelles propositions d’ajout ou de remplacement affichées par Companion.\n\nL’insertion du texte ne remplace pas l’enregistrement final du bilan ou du rapport.\n\nL’ouverture et la fermeture de cette aide conservent votre saisie.`
  String get documentTemplateGuide_help {
    return Intl.message(
      'Ce guide vous aide à préparer le contenu d’un bilan ou d’un rapport à partir du modèle sélectionné.\n\nUtilisez la liste des rubriques à gauche pour accéder aux différentes sections. Selon les champs proposés, saisissez du texte, sélectionnez des réponses ou complétez les tableaux.\n\nLe bouton de prévisualisation, situé en bas du formulaire, permet de consulter le texte produit à partir de vos réponses.\n\nDepuis l’aperçu, vous pouvez revenir au guide pour poursuivre votre saisie ou demander l’insertion du texte dans le bilan ou le rapport. Suivez les éventuelles propositions d’ajout ou de remplacement affichées par Companion.\n\nL’insertion du texte ne remplace pas l’enregistrement final du bilan ou du rapport.\n\nL’ouverture et la fermeture de cette aide conservent votre saisie.',
      name: 'documentTemplateGuide_help',
      desc: '',
      args: [],
    );
  }

  /// `Utiliser le guide de saisie`
  String get documentTemplateGuide_helpTitle {
    return Intl.message(
      'Utiliser le guide de saisie',
      name: 'documentTemplateGuide_helpTitle',
      desc: '',
      args: [],
    );
  }

  /// `Cette fenêtre présente les modèles disponibles pour le type de document en cours : bilan ou rapport.\n\nCliquez sur un modèle pour ouvrir le guide de saisie correspondant. Le choix du modèle ne crée pas immédiatement un document enregistré.\n\nSi un brouillon existe déjà pour ce modèle dans l’épisode de soins, Companion vous propose de le reprendre ou de commencer une nouvelle saisie.`
  String get documentTemplate_help {
    return Intl.message(
      'Cette fenêtre présente les modèles disponibles pour le type de document en cours : bilan ou rapport.\n\nCliquez sur un modèle pour ouvrir le guide de saisie correspondant. Le choix du modèle ne crée pas immédiatement un document enregistré.\n\nSi un brouillon existe déjà pour ce modèle dans l’épisode de soins, Companion vous propose de le reprendre ou de commencer une nouvelle saisie.',
      name: 'documentTemplate_help',
      desc: '',
      args: [],
    );
  }

  /// `Des réponses ont déjà été enregistrées pour ce modèle de guide dans l’épisode de soins en cours.\n\n« Reprendre le brouillon » ouvre le guide avec ces réponses pour vous permettre de poursuivre ou de modifier votre saisie.\n\n« Nouveau bilan » ou « Nouveau rapport » efface les réponses enregistrées pour ce modèle et ouvre le guide sans reprendre ces réponses. Ce choix ne supprime pas le texte déjà présent dans la zone de rédaction du document.\n\n« Annuler » conserve les réponses enregistrées et revient à l’écran précédent sans ouvrir le guide.`
  String get documentTemplateDraft_help {
    return Intl.message(
      'Des réponses ont déjà été enregistrées pour ce modèle de guide dans l’épisode de soins en cours.\n\n« Reprendre le brouillon » ouvre le guide avec ces réponses pour vous permettre de poursuivre ou de modifier votre saisie.\n\n« Nouveau bilan » ou « Nouveau rapport » efface les réponses enregistrées pour ce modèle et ouvre le guide sans reprendre ces réponses. Ce choix ne supprime pas le texte déjà présent dans la zone de rédaction du document.\n\n« Annuler » conserve les réponses enregistrées et revient à l’écran précédent sans ouvrir le guide.',
      name: 'documentTemplateDraft_help',
      desc: '',
      args: [],
    );
  }

  /// `Brouillon existant`
  String get documentTemplateDraft_title {
    return Intl.message(
      'Brouillon existant',
      name: 'documentTemplateDraft_title',
      desc: '',
      args: [],
    );
  }

  /// `Choisir un modèle de rapport`
  String get documentTemplate_reportTitle {
    return Intl.message(
      'Choisir un modèle de rapport',
      name: 'documentTemplate_reportTitle',
      desc: '',
      args: [],
    );
  }

  /// `Cette fenêtre permet de relire le texte généré à partir des réponses saisies dans le guide.\n\nLe texte est consultable et sélectionnable. Pour modifier vos réponses, cliquez sur « Fermer » afin de revenir au guide, puis relancez la prévisualisation.\n\nCliquez sur « Insérer dans le bilan » ou « Insérer dans le rapport » pour transmettre le texte au document en cours. Suivez les éventuelles propositions d’ajout ou de remplacement affichées par Companion.\n\nSi aucun texte n’a été généré, le bouton d’insertion reste désactivé.\n\nAprès insertion, vérifiez le contenu du document et enregistrez votre bilan ou votre rapport.`
  String get documentTemplatePreview_help {
    return Intl.message(
      'Cette fenêtre permet de relire le texte généré à partir des réponses saisies dans le guide.\n\nLe texte est consultable et sélectionnable. Pour modifier vos réponses, cliquez sur « Fermer » afin de revenir au guide, puis relancez la prévisualisation.\n\nCliquez sur « Insérer dans le bilan » ou « Insérer dans le rapport » pour transmettre le texte au document en cours. Suivez les éventuelles propositions d’ajout ou de remplacement affichées par Companion.\n\nSi aucun texte n’a été généré, le bouton d’insertion reste désactivé.\n\nAprès insertion, vérifiez le contenu du document et enregistrez votre bilan ou votre rapport.',
      name: 'documentTemplatePreview_help',
      desc: '',
      args: [],
    );
  }

  /// `Aperçu du texte généré`
  String get documentTemplatePreview_title {
    return Intl.message(
      'Aperçu du texte généré',
      name: 'documentTemplatePreview_title',
      desc: '',
      args: [],
    );
  }

  /// `Cette vue agrandie permet de consulter les tests réalisés dans la prise en charge et de choisir ceux à inclure dans le bilan ou le rapport en cours.\n\nUtilisez les cases de sélection pour inclure ou retirer un test du document. Cette sélection ne supprime pas les résultats enregistrés dans Companion.\n\nLes actions proposées dans la liste permettent de consulter le détail des résultats. La sélection est disponible lorsqu’un bilan ou un rapport est ouvert et que le chargement est terminé.\n\nCliquez sur la croix pour revenir à l’espace Bilans/Rapports.`
  String get documentTests_help {
    return Intl.message(
      'Cette vue agrandie permet de consulter les tests réalisés dans la prise en charge et de choisir ceux à inclure dans le bilan ou le rapport en cours.\n\nUtilisez les cases de sélection pour inclure ou retirer un test du document. Cette sélection ne supprime pas les résultats enregistrés dans Companion.\n\nLes actions proposées dans la liste permettent de consulter le détail des résultats. La sélection est disponible lorsqu’un bilan ou un rapport est ouvert et que le chargement est terminé.\n\nCliquez sur la croix pour revenir à l’espace Bilans/Rapports.',
      name: 'documentTests_help',
      desc: '',
      args: [],
    );
  }

  /// `Cette fenêtre permet de renseigner le titre du bilan ou du rapport.\n\nConservez le titre proposé ou remplacez-le par un intitulé permettant de reconnaître facilement le document. Le titre ne peut pas être vide.\n\nCliquez sur le bouton de validation ou appuyez sur Entrée pour confirmer. « Annuler » ferme la fenêtre sans valider le titre.\n\nL’ouverture et la fermeture de cette aide conservent le texte saisi.`
  String get documentTitle_help {
    return Intl.message(
      'Cette fenêtre permet de renseigner le titre du bilan ou du rapport.\n\nConservez le titre proposé ou remplacez-le par un intitulé permettant de reconnaître facilement le document. Le titre ne peut pas être vide.\n\nCliquez sur le bouton de validation ou appuyez sur Entrée pour confirmer. « Annuler » ferme la fenêtre sans valider le titre.\n\nL’ouverture et la fermeture de cette aide conservent le texte saisi.',
      name: 'documentTitle_help',
      desc: '',
      args: [],
    );
  }

  /// `Votre bilan ou votre rapport contient déjà du texte. Choisissez comment y intégrer le contenu généré par le guide de saisie.\n\n« Ajouter à la suite » conserve le texte existant et ajoute le contenu généré à la fin.\n\n« Remplacer » remplace tout le texte de la zone de rédaction par le contenu généré. Les passages que vous aviez saisis dans cette zone seront donc remplacés eux aussi.\n\n« Annuler » abandonne cette insertion et conserve le texte actuel.\n\nVous pouvez consulter puis fermer cette aide avant de faire votre choix.`
  String get documentTextInsertion_help {
    return Intl.message(
      'Votre bilan ou votre rapport contient déjà du texte. Choisissez comment y intégrer le contenu généré par le guide de saisie.\n\n« Ajouter à la suite » conserve le texte existant et ajoute le contenu généré à la fin.\n\n« Remplacer » remplace tout le texte de la zone de rédaction par le contenu généré. Les passages que vous aviez saisis dans cette zone seront donc remplacés eux aussi.\n\n« Annuler » abandonne cette insertion et conserve le texte actuel.\n\nVous pouvez consulter puis fermer cette aide avant de faire votre choix.',
      name: 'documentTextInsertion_help',
      desc: '',
      args: [],
    );
  }

  /// `Insérer le texte généré`
  String get documentTextInsertion_title {
    return Intl.message(
      'Insérer le texte généré',
      name: 'documentTextInsertion_title',
      desc: '',
      args: [],
    );
  }

  /// `Documents`
  String get episodeDashboard_documents {
    return Intl.message(
      'Documents',
      name: 'episodeDashboard_documents',
      desc: '',
      args: [],
    );
  }

  /// `Documents associés à cet épisode`
  String get episodeDashboard_documentsDescription {
    return Intl.message(
      'Documents associés à cet épisode',
      name: 'episodeDashboard_documentsDescription',
      desc: '',
      args: [],
    );
  }

  /// `Formulaires`
  String get episodeDashboard_forms {
    return Intl.message(
      'Formulaires',
      name: 'episodeDashboard_forms',
      desc: '',
      args: [],
    );
  }

  /// `Questionnaires spécifiques à cet épisode`
  String get episodeDashboard_formsDescription {
    return Intl.message(
      'Questionnaires spécifiques à cet épisode',
      name: 'episodeDashboard_formsDescription',
      desc: '',
      args: [],
    );
  }

  /// `Notes`
  String get episodeDashboard_notes {
    return Intl.message(
      'Notes',
      name: 'episodeDashboard_notes',
      desc: '',
      args: [],
    );
  }

  /// `Observations et commentaires du kiné`
  String get episodeDashboard_notesDescription {
    return Intl.message(
      'Observations et commentaires du kiné',
      name: 'episodeDashboard_notesDescription',
      desc: '',
      args: [],
    );
  }

  /// `Rapport`
  String get episodeDashboard_report {
    return Intl.message(
      'Rapport',
      name: 'episodeDashboard_report',
      desc: '',
      args: [],
    );
  }

  /// `Synthèse de l’épisode`
  String get episodeDashboard_reportDescription {
    return Intl.message(
      'Synthèse de l’épisode',
      name: 'episodeDashboard_reportDescription',
      desc: '',
      args: [],
    );
  }

  /// `Ajouter un document`
  String get episodeDocuments_addDocument {
    return Intl.message(
      'Ajouter un document',
      name: 'episodeDocuments_addDocument',
      desc: '',
      args: [],
    );
  }

  /// `Ajouté le`
  String get episodeDocuments_addedOn {
    return Intl.message(
      'Ajouté le',
      name: 'episodeDocuments_addedOn',
      desc: '',
      args: [],
    );
  }

  /// `Impossible d’ajouter le document`
  String get episodeDocuments_addError {
    return Intl.message(
      'Impossible d’ajouter le document',
      name: 'episodeDocuments_addError',
      desc: '',
      args: [],
    );
  }

  /// `Document`
  String get episodeDocuments_document {
    return Intl.message(
      'Document',
      name: 'episodeDocuments_document',
      desc: '',
      args: [],
    );
  }

  /// `Le document a été ajouté à la prise en charge.`
  String get episodeDocuments_documentAdded {
    return Intl.message(
      'Le document a été ajouté à la prise en charge.',
      name: 'episodeDocuments_documentAdded',
      desc: '',
      args: [],
    );
  }

  /// `Vous pouvez ajouter un document texte, une feuille de calcul, un PDF, une image ou tout autre fichier utile.`
  String get episodeDocuments_emptyDescription {
    return Intl.message(
      'Vous pouvez ajouter un document texte, une feuille de calcul, un PDF, une image ou tout autre fichier utile.',
      name: 'episodeDocuments_emptyDescription',
      desc: '',
      args: [],
    );
  }

  /// `Le fichier associé est introuvable.`
  String get episodeDocuments_fileNotFound {
    return Intl.message(
      'Le fichier associé est introuvable.',
      name: 'episodeDocuments_fileNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Vous pouvez associer à cette prise en charge des documents créés avec vos applications habituelles : traitement de texte, tableur, lecteur PDF ou logiciel d’image.\n\nLes fichiers ajoutés sont copiés dans l’espace de stockage de Companion. Un clic sur un document l’ouvre avec l’application correspondante installée sur cet ordinateur.`
  String get episodeDocuments_help {
    return Intl.message(
      'Vous pouvez associer à cette prise en charge des documents créés avec vos applications habituelles : traitement de texte, tableur, lecteur PDF ou logiciel d’image.\n\nLes fichiers ajoutés sont copiés dans l’espace de stockage de Companion. Un clic sur un document l’ouvre avec l’application correspondante installée sur cet ordinateur.',
      name: 'episodeDocuments_help',
      desc: '',
      args: [],
    );
  }

  /// `Image`
  String get episodeDocuments_image {
    return Intl.message(
      'Image',
      name: 'episodeDocuments_image',
      desc: '',
      args: [],
    );
  }

  /// `Impossible de charger les documents associés.`
  String get episodeDocuments_loadError {
    return Intl.message(
      'Impossible de charger les documents associés.',
      name: 'episodeDocuments_loadError',
      desc: '',
      args: [],
    );
  }

  /// `Aucun document associé à cette prise en charge.`
  String get episodeDocuments_noDocument {
    return Intl.message(
      'Aucun document associé à cette prise en charge.',
      name: 'episodeDocuments_noDocument',
      desc: '',
      args: [],
    );
  }

  /// `Ouvrir le document`
  String get episodeDocuments_openDocument {
    return Intl.message(
      'Ouvrir le document',
      name: 'episodeDocuments_openDocument',
      desc: '',
      args: [],
    );
  }

  /// `Impossible d’ouvrir le fichier`
  String get episodeDocuments_openError {
    return Intl.message(
      'Impossible d’ouvrir le fichier',
      name: 'episodeDocuments_openError',
      desc: '',
      args: [],
    );
  }

  /// `Document PDF`
  String get episodeDocuments_pdfDocument {
    return Intl.message(
      'Document PDF',
      name: 'episodeDocuments_pdfDocument',
      desc: '',
      args: [],
    );
  }

  /// `Ouverture non prise en charge sur cette plateforme.`
  String get episodeDocuments_platformNotSupported {
    return Intl.message(
      'Ouverture non prise en charge sur cette plateforme.',
      name: 'episodeDocuments_platformNotSupported',
      desc: '',
      args: [],
    );
  }

  /// `Actualiser`
  String get episodeDocuments_refresh {
    return Intl.message(
      'Actualiser',
      name: 'episodeDocuments_refresh',
      desc: '',
      args: [],
    );
  }

  /// `Feuille de calcul`
  String get episodeDocuments_spreadsheet {
    return Intl.message(
      'Feuille de calcul',
      name: 'episodeDocuments_spreadsheet',
      desc: '',
      args: [],
    );
  }

  /// `Document texte`
  String get episodeDocuments_textDocument {
    return Intl.message(
      'Document texte',
      name: 'episodeDocuments_textDocument',
      desc: '',
      args: [],
    );
  }

  /// `Documents de la prise en charge`
  String get episodeDocuments_title {
    return Intl.message(
      'Documents de la prise en charge',
      name: 'episodeDocuments_title',
      desc: '',
      args: [],
    );
  }

  /// `évaluation`
  String get episodeEvolution_evaluation {
    return Intl.message(
      'évaluation',
      name: 'episodeEvolution_evaluation',
      desc: '',
      args: [],
    );
  }

  /// `évaluations`
  String get episodeEvolution_evaluations {
    return Intl.message(
      'évaluations',
      name: 'episodeEvolution_evaluations',
      desc: '',
      args: [],
    );
  }

  /// `Première`
  String get episodeEvolution_first {
    return Intl.message(
      'Première',
      name: 'episodeEvolution_first',
      desc: '',
      args: [],
    );
  }

  /// `Exercices suivis`
  String get episodeEvolution_followedExercises {
    return Intl.message(
      'Exercices suivis',
      name: 'episodeEvolution_followedExercises',
      desc: '',
      args: [],
    );
  }

  /// `Dernière`
  String get episodeEvolution_last {
    return Intl.message(
      'Dernière',
      name: 'episodeEvolution_last',
      desc: '',
      args: [],
    );
  }

  /// `Aucun résultat disponible pour cet épisode.`
  String get episodeEvolution_noResults {
    return Intl.message(
      'Aucun résultat disponible pour cet épisode.',
      name: 'episodeEvolution_noResults',
      desc: '',
      args: [],
    );
  }

  /// `Une seule valeur chiffrée disponible`
  String get episodeEvolution_singleNumericValue {
    return Intl.message(
      'Une seule valeur chiffrée disponible',
      name: 'episodeEvolution_singleNumericValue',
      desc: '',
      args: [],
    );
  }

  /// `Évolution de l'épisode`
  String get episodeEvolution_title {
    return Intl.message(
      'Évolution de l\'épisode',
      name: 'episodeEvolution_title',
      desc: '',
      args: [],
    );
  }

  /// `Voir l'évolution`
  String get episodeEvolution_viewEvolution {
    return Intl.message(
      'Voir l\'évolution',
      name: 'episodeEvolution_viewEvolution',
      desc: '',
      args: [],
    );
  }

  /// `Erreur`
  String get episodeFormEditor_error {
    return Intl.message(
      'Erreur',
      name: 'episodeFormEditor_error',
      desc: '',
      args: [],
    );
  }

  /// `Aucun champ à afficher.`
  String get episodeFormEditor_noField {
    return Intl.message(
      'Aucun champ à afficher.',
      name: 'episodeFormEditor_noField',
      desc: '',
      args: [],
    );
  }

  /// `Le champ "{fieldName}" est obligatoire.`
  String episodeFormEditor_requiredField(Object fieldName) {
    return Intl.message(
      'Le champ "$fieldName" est obligatoire.',
      name: 'episodeFormEditor_requiredField',
      desc: '',
      args: [fieldName],
    );
  }

  /// `Enregistrer`
  String get episodeFormEditor_save {
    return Intl.message(
      'Enregistrer',
      name: 'episodeFormEditor_save',
      desc: '',
      args: [],
    );
  }

  /// `Modifier le formulaire`
  String get episodeFormEditor_title {
    return Intl.message(
      'Modifier le formulaire',
      name: 'episodeFormEditor_title',
      desc: '',
      args: [],
    );
  }

  /// `Modèles disponibles`
  String get episodeForms_availableTemplates {
    return Intl.message(
      'Modèles disponibles',
      name: 'episodeForms_availableTemplates',
      desc: '',
      args: [],
    );
  }

  /// `Catégorie`
  String get episodeForms_category {
    return Intl.message(
      'Catégorie',
      name: 'episodeForms_category',
      desc: '',
      args: [],
    );
  }

  /// `complété`
  String get episodeForms_completed {
    return Intl.message(
      'complété',
      name: 'episodeForms_completed',
      desc: '',
      args: [],
    );
  }

  /// `Créer`
  String get episodeForms_create {
    return Intl.message(
      'Créer',
      name: 'episodeForms_create',
      desc: '',
      args: [],
    );
  }

  /// `Formulaires créés`
  String get episodeForms_createdForms {
    return Intl.message(
      'Formulaires créés',
      name: 'episodeForms_createdForms',
      desc: '',
      args: [],
    );
  }

  /// `Créé le`
  String get episodeForms_createdOn {
    return Intl.message(
      'Créé le',
      name: 'episodeForms_createdOn',
      desc: '',
      args: [],
    );
  }

  /// `Modèle personnalisé`
  String get episodeForms_customTemplate {
    return Intl.message(
      'Modèle personnalisé',
      name: 'episodeForms_customTemplate',
      desc: '',
      args: [],
    );
  }

  /// `Erreur`
  String get episodeForms_error {
    return Intl.message(
      'Erreur',
      name: 'episodeForms_error',
      desc: '',
      args: [],
    );
  }

  /// `Formulaire`
  String get episodeForms_form {
    return Intl.message(
      'Formulaire',
      name: 'episodeForms_form',
      desc: '',
      args: [],
    );
  }

  /// `en cours`
  String get episodeForms_inProgress {
    return Intl.message(
      'en cours',
      name: 'episodeForms_inProgress',
      desc: '',
      args: [],
    );
  }

  /// `Aucun modèle de formulaire disponible.`
  String get episodeForms_noAvailableTemplate {
    return Intl.message(
      'Aucun modèle de formulaire disponible.',
      name: 'episodeForms_noAvailableTemplate',
      desc: '',
      args: [],
    );
  }

  /// `Aucun formulaire créé pour cet épisode.`
  String get episodeForms_noCreatedForm {
    return Intl.message(
      'Aucun formulaire créé pour cet épisode.',
      name: 'episodeForms_noCreatedForm',
      desc: '',
      args: [],
    );
  }

  /// `Aucune donnée à afficher.`
  String get episodeForms_noData {
    return Intl.message(
      'Aucune donnée à afficher.',
      name: 'episodeForms_noData',
      desc: '',
      args: [],
    );
  }

  /// `Actualiser`
  String get episodeForms_refresh {
    return Intl.message(
      'Actualiser',
      name: 'episodeForms_refresh',
      desc: '',
      args: [],
    );
  }

  /// `État`
  String get episodeForms_state {
    return Intl.message(
      'État',
      name: 'episodeForms_state',
      desc: '',
      args: [],
    );
  }

  /// `Modèle système`
  String get episodeForms_systemTemplate {
    return Intl.message(
      'Modèle système',
      name: 'episodeForms_systemTemplate',
      desc: '',
      args: [],
    );
  }

  /// `Formulaires`
  String get episodeForms_title {
    return Intl.message(
      'Formulaires',
      name: 'episodeForms_title',
      desc: '',
      args: [],
    );
  }

  /// `Archiver`
  String get episodeNotes_archive {
    return Intl.message(
      'Archiver',
      name: 'episodeNotes_archive',
      desc: '',
      args: [],
    );
  }

  /// `La note "{noteTitle}" ne sera plus affichée.`
  String episodeNotes_archiveConfirmation(Object noteTitle) {
    return Intl.message(
      'La note "$noteTitle" ne sera plus affichée.',
      name: 'episodeNotes_archiveConfirmation',
      desc: '',
      args: [noteTitle],
    );
  }

  /// `Archiver la note ?`
  String get episodeNotes_archiveTitle {
    return Intl.message(
      'Archiver la note ?',
      name: 'episodeNotes_archiveTitle',
      desc: '',
      args: [],
    );
  }

  /// `Annuler`
  String get episodeNotes_cancel {
    return Intl.message(
      'Annuler',
      name: 'episodeNotes_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Contenu`
  String get episodeNotes_content {
    return Intl.message(
      'Contenu',
      name: 'episodeNotes_content',
      desc: '',
      args: [],
    );
  }

  /// `Modifier la note`
  String get episodeNotes_editNote {
    return Intl.message(
      'Modifier la note',
      name: 'episodeNotes_editNote',
      desc: '',
      args: [],
    );
  }

  /// `Erreur`
  String get episodeNotes_error {
    return Intl.message(
      'Erreur',
      name: 'episodeNotes_error',
      desc: '',
      args: [],
    );
  }

  /// `Modifiée le`
  String get episodeNotes_modifiedOn {
    return Intl.message(
      'Modifiée le',
      name: 'episodeNotes_modifiedOn',
      desc: '',
      args: [],
    );
  }

  /// `Nouvelle note`
  String get episodeNotes_newNote {
    return Intl.message(
      'Nouvelle note',
      name: 'episodeNotes_newNote',
      desc: '',
      args: [],
    );
  }

  /// `Aucune note associée à cet épisode.`
  String get episodeNotes_noNote {
    return Intl.message(
      'Aucune note associée à cet épisode.',
      name: 'episodeNotes_noNote',
      desc: '',
      args: [],
    );
  }

  /// `Titre`
  String get episodeNotes_noteTitle {
    return Intl.message(
      'Titre',
      name: 'episodeNotes_noteTitle',
      desc: '',
      args: [],
    );
  }

  /// `Actualiser`
  String get episodeNotes_refresh {
    return Intl.message(
      'Actualiser',
      name: 'episodeNotes_refresh',
      desc: '',
      args: [],
    );
  }

  /// `Enregistrer`
  String get episodeNotes_save {
    return Intl.message(
      'Enregistrer',
      name: 'episodeNotes_save',
      desc: '',
      args: [],
    );
  }

  /// `Notes`
  String get episodeNotes_title {
    return Intl.message(
      'Notes',
      name: 'episodeNotes_title',
      desc: '',
      args: [],
    );
  }

  /// `Le titre est obligatoire.`
  String get episodeNotes_titleRequired {
    return Intl.message(
      'Le titre est obligatoire.',
      name: 'episodeNotes_titleRequired',
      desc: '',
      args: [],
    );
  }

  /// `Cette fenêtre permet de choisir le kiné référent et le médecin prescripteur associés à la prise en charge.\n\nSélectionnez les professionnels dans les listes. Vous pouvez également retirer une association en choisissant l’option sans professionnel.\n\nLes boutons de gestion situés à droite des listes permettent d’accéder aux fiches des praticiens et des correspondants externes, notamment pour ajouter un professionnel manquant.\n\nCliquez sur « Enregistrer » pour appliquer les associations choisies. Les changements de kiné référent sont conservés dans l’historique de la prise en charge.\n\n« Annuler » abandonne les changements d’association dans cette fenêtre. Les fiches éventuellement créées depuis les écrans de gestion restent enregistrées.`
  String get episodeReferents_help {
    return Intl.message(
      'Cette fenêtre permet de choisir le kiné référent et le médecin prescripteur associés à la prise en charge.\n\nSélectionnez les professionnels dans les listes. Vous pouvez également retirer une association en choisissant l’option sans professionnel.\n\nLes boutons de gestion situés à droite des listes permettent d’accéder aux fiches des praticiens et des correspondants externes, notamment pour ajouter un professionnel manquant.\n\nCliquez sur « Enregistrer » pour appliquer les associations choisies. Les changements de kiné référent sont conservés dans l’historique de la prise en charge.\n\n« Annuler » abandonne les changements d’association dans cette fenêtre. Les fiches éventuellement créées depuis les écrans de gestion restent enregistrées.',
      name: 'episodeReferents_help',
      desc: '',
      args: [],
    );
  }

  /// `Modifier les référents`
  String get episodeReferents_title {
    return Intl.message(
      'Modifier les référents',
      name: 'episodeReferents_title',
      desc: '',
      args: [],
    );
  }

  /// `Origine ABAK`
  String get episodeReport_abakOrigin {
    return Intl.message(
      'Origine ABAK',
      name: 'episodeReport_abakOrigin',
      desc: '',
      args: [],
    );
  }

  /// `Ajouter une conclusion`
  String get episodeReport_addConclusion {
    return Intl.message(
      'Ajouter une conclusion',
      name: 'episodeReport_addConclusion',
      desc: '',
      args: [],
    );
  }

  /// `Conclusion clinique`
  String get episodeReport_clinicalConclusion {
    return Intl.message(
      'Conclusion clinique',
      name: 'episodeReport_clinicalConclusion',
      desc: '',
      args: [],
    );
  }

  /// `La conclusion ne peut pas être vide.`
  String get episodeReport_conclusionRequired {
    return Intl.message(
      'La conclusion ne peut pas être vide.',
      name: 'episodeReport_conclusionRequired',
      desc: '',
      args: [],
    );
  }

  /// `Documents`
  String get episodeReport_documents {
    return Intl.message(
      'Documents',
      name: 'episodeReport_documents',
      desc: '',
      args: [],
    );
  }

  /// `Côté dominant`
  String get episodeReport_dominantSide {
    return Intl.message(
      'Côté dominant',
      name: 'episodeReport_dominantSide',
      desc: '',
      args: [],
    );
  }

  /// `Modifier la conclusion`
  String get episodeReport_editConclusion {
    return Intl.message(
      'Modifier la conclusion',
      name: 'episodeReport_editConclusion',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get episodeReport_email {
    return Intl.message(
      'Email',
      name: 'episodeReport_email',
      desc: '',
      args: [],
    );
  }

  /// `Erreur`
  String get episodeReport_error {
    return Intl.message(
      'Erreur',
      name: 'episodeReport_error',
      desc: '',
      args: [],
    );
  }

  /// `Formulaires`
  String get episodeReport_forms {
    return Intl.message(
      'Formulaires',
      name: 'episodeReport_forms',
      desc: '',
      args: [],
    );
  }

  /// `Aperçu du rapport généré`
  String get episodeReport_generatedPreview {
    return Intl.message(
      'Aperçu du rapport généré',
      name: 'episodeReport_generatedPreview',
      desc: '',
      args: [],
    );
  }

  /// `Génération de l’aperçu texte...`
  String get episodeReport_generatingPreview {
    return Intl.message(
      'Génération de l’aperçu texte...',
      name: 'episodeReport_generatingPreview',
      desc: '',
      args: [],
    );
  }

  /// `Nom`
  String get episodeReport_name {
    return Intl.message(
      'Nom',
      name: 'episodeReport_name',
      desc: '',
      args: [],
    );
  }

  /// `Aucune conclusion renseignée.`
  String get episodeReport_noConclusion {
    return Intl.message(
      'Aucune conclusion renseignée.',
      name: 'episodeReport_noConclusion',
      desc: '',
      args: [],
    );
  }

  /// `Aucune donnée à afficher.`
  String get episodeReport_noData {
    return Intl.message(
      'Aucune donnée à afficher.',
      name: 'episodeReport_noData',
      desc: '',
      args: [],
    );
  }

  /// `Aucun document associé`
  String get episodeReport_noDocument {
    return Intl.message(
      'Aucun document associé',
      name: 'episodeReport_noDocument',
      desc: '',
      args: [],
    );
  }

  /// `Aucun formulaire associé`
  String get episodeReport_noForm {
    return Intl.message(
      'Aucun formulaire associé',
      name: 'episodeReport_noForm',
      desc: '',
      args: [],
    );
  }

  /// `Aucune note associée`
  String get episodeReport_noNote {
    return Intl.message(
      'Aucune note associée',
      name: 'episodeReport_noNote',
      desc: '',
      args: [],
    );
  }

  /// `Aucun résultat associé`
  String get episodeReport_noResult {
    return Intl.message(
      'Aucun résultat associé',
      name: 'episodeReport_noResult',
      desc: '',
      args: [],
    );
  }

  /// `Notes`
  String get episodeReport_notes {
    return Intl.message(
      'Notes',
      name: 'episodeReport_notes',
      desc: '',
      args: [],
    );
  }

  /// `Non renseigné`
  String get episodeReport_notProvided {
    return Intl.message(
      'Non renseigné',
      name: 'episodeReport_notProvided',
      desc: '',
      args: [],
    );
  }

  /// `Patient`
  String get episodeReport_patient {
    return Intl.message(
      'Patient',
      name: 'episodeReport_patient',
      desc: '',
      args: [],
    );
  }

  /// `Téléphone`
  String get episodeReport_phone {
    return Intl.message(
      'Téléphone',
      name: 'episodeReport_phone',
      desc: '',
      args: [],
    );
  }

  /// `Profession`
  String get episodeReport_profession {
    return Intl.message(
      'Profession',
      name: 'episodeReport_profession',
      desc: '',
      args: [],
    );
  }

  /// `Actualiser`
  String get episodeReport_refresh {
    return Intl.message(
      'Actualiser',
      name: 'episodeReport_refresh',
      desc: '',
      args: [],
    );
  }

  /// `Résultats ABAK`
  String get episodeReport_results {
    return Intl.message(
      'Résultats ABAK',
      name: 'episodeReport_results',
      desc: '',
      args: [],
    );
  }

  /// `Enregistrer`
  String get episodeReport_save {
    return Intl.message(
      'Enregistrer',
      name: 'episodeReport_save',
      desc: '',
      args: [],
    );
  }

  /// `Score`
  String get episodeReport_score {
    return Intl.message(
      'Score',
      name: 'episodeReport_score',
      desc: '',
      args: [],
    );
  }

  /// `Activité sportive`
  String get episodeReport_sportActivity {
    return Intl.message(
      'Activité sportive',
      name: 'episodeReport_sportActivity',
      desc: '',
      args: [],
    );
  }

  /// `Rapport`
  String get episodeReport_title {
    return Intl.message(
      'Rapport',
      name: 'episodeReport_title',
      desc: '',
      args: [],
    );
  }

  /// `Type inconnu`
  String get episodeReport_unknownType {
    return Intl.message(
      'Type inconnu',
      name: 'episodeReport_unknownType',
      desc: '',
      args: [],
    );
  }

  /// `Dossier d'échange réinitialisé`
  String get exchangeDirectoryReset {
    return Intl.message(
      'Dossier d\'échange réinitialisé',
      name: 'exchangeDirectoryReset',
      desc: '',
      args: [],
    );
  }

  /// `Choisir le dossier d’échange ABAK`
  String get exchangeDirectoryService_choose {
    return Intl.message(
      'Choisir le dossier d’échange ABAK',
      name: 'exchangeDirectoryService_choose',
      desc: '',
      args: [],
    );
  }

  /// `Dossier d'échange ABAK mis à jour`
  String get exchangeDirectoryUpdated {
    return Intl.message(
      'Dossier d\'échange ABAK mis à jour',
      name: 'exchangeDirectoryUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Modifier le correspondant`
  String get externalCorrespondentForm_editTitle {
    return Intl.message(
      'Modifier le correspondant',
      name: 'externalCorrespondentForm_editTitle',
      desc: '',
      args: [],
    );
  }

  /// `Ajouter un correspondant`
  String get externalCorrespondentForm_addTitle {
    return Intl.message(
      'Ajouter un correspondant',
      name: 'externalCorrespondentForm_addTitle',
      desc: '',
      args: [],
    );
  }

  /// `Cette fenêtre permet de renseigner la fiche d’un correspondant externe.\n\nLe nom est obligatoire. Vous pouvez compléter le prénom, la profession, la spécialité, l’adresse, le code postal, la ville, l’adresse électronique et le téléphone.\n\nCliquez sur « Enregistrer » pour valider la fiche. « Annuler » ferme la fenêtre sans appliquer les modifications.\n\nL’ouverture et la fermeture de cette aide conservent votre saisie dans le formulaire.`
  String get externalCorrespondentForm_help {
    return Intl.message(
      'Cette fenêtre permet de renseigner la fiche d’un correspondant externe.\n\nLe nom est obligatoire. Vous pouvez compléter le prénom, la profession, la spécialité, l’adresse, le code postal, la ville, l’adresse électronique et le téléphone.\n\nCliquez sur « Enregistrer » pour valider la fiche. « Annuler » ferme la fenêtre sans appliquer les modifications.\n\nL’ouverture et la fermeture de cette aide conservent votre saisie dans le formulaire.',
      name: 'externalCorrespondentForm_help',
      desc: '',
      args: [],
    );
  }

  /// `Correspondants externes`
  String get externalCorrespondents_title {
    return Intl.message(
      'Correspondants externes',
      name: 'externalCorrespondents_title',
      desc: '',
      args: [],
    );
  }

  /// `Cet écran présente les correspondants externes enregistrés dans Companion. Chaque ligne indique le nom du correspondant et, lorsqu’elles sont renseignées, sa profession, sa spécialité et sa ville.\n\nCliquez sur « Ajouter » pour créer un correspondant. Renseignez son identité et les coordonnées utiles, puis cliquez sur « Enregistrer » pour l’ajouter à la liste. « Annuler » ferme le formulaire sans créer de correspondant.\n\nCes correspondants peuvent notamment être sélectionnés comme prescripteurs dans les épisodes de soins.`
  String get externalCorrespondents_help {
    return Intl.message(
      'Cet écran présente les correspondants externes enregistrés dans Companion. Chaque ligne indique le nom du correspondant et, lorsqu’elles sont renseignées, sa profession, sa spécialité et sa ville.\n\nCliquez sur « Ajouter » pour créer un correspondant. Renseignez son identité et les coordonnées utiles, puis cliquez sur « Enregistrer » pour l’ajouter à la liste. « Annuler » ferme le formulaire sans créer de correspondant.\n\nCes correspondants peuvent notamment être sélectionnés comme prescripteurs dans les épisodes de soins.',
      name: 'externalCorrespondents_help',
      desc: '',
      args: [],
    );
  }

  /// `L’add-on n’a retourné aucune réponse.`
  String get externalSpeechToTextProvider_empty {
    return Intl.message(
      'L’add-on n’a retourné aucune réponse.',
      name: 'externalSpeechToTextProvider_empty',
      desc: '',
      args: [],
    );
  }

  /// `Échec de l’add-on de reconnaissance vocale.`
  String get externalSpeechToTextProvider_failure {
    return Intl.message(
      'Échec de l’add-on de reconnaissance vocale.',
      name: 'externalSpeechToTextProvider_failure',
      desc: '',
      args: [],
    );
  }

  /// `Réponse invalide de l’add-on de reconnaissance vocale.`
  String get externalSpeechToTextProvider_invalid {
    return Intl.message(
      'Réponse invalide de l’add-on de reconnaissance vocale.',
      name: 'externalSpeechToTextProvider_invalid',
      desc: '',
      args: [],
    );
  }

  /// `L’add-on n’a retourné aucun texte.`
  String get externalSpeechToTextProvider_noText {
    return Intl.message(
      'L’add-on n’a retourné aucun texte.',
      name: 'externalSpeechToTextProvider_noText',
      desc: '',
      args: [],
    );
  }

  /// `La transcription a échoué.`
  String get externalSpeechToTextProvider_transcription {
    return Intl.message(
      'La transcription a échoué.',
      name: 'externalSpeechToTextProvider_transcription',
      desc: '',
      args: [],
    );
  }

  /// `Nouvelle note de suivi`
  String get followUpNoteForm_createTitle {
    return Intl.message(
      'Nouvelle note de suivi',
      name: 'followUpNoteForm_createTitle',
      desc: '',
      args: [],
    );
  }

  /// `Modifier la note de suivi`
  String get followUpNoteForm_editTitle {
    return Intl.message(
      'Modifier la note de suivi',
      name: 'followUpNoteForm_editTitle',
      desc: '',
      args: [],
    );
  }

  /// `Cette vue présente les notes de suivi de la prise en charge, avec leur date, leur titre et un aperçu de leur contenu.\n\nLe bouton d’ajout permet de créer une note. L’icône de modification permet d’ouvrir une note existante pour la consulter ou la modifier.\n\nUtilisez les cases de sélection pour choisir les notes à inclure dans le bilan ou le rapport en cours. Décocher une note la retire de cette sélection sans supprimer la note de suivi.\n\nLa sélection est disponible lorsqu’un bilan ou un rapport est ouvert et que le chargement est terminé.\n\nCliquez sur la croix pour fermer la vue agrandie et revenir à l’espace Bilans/Rapports.`
  String get followUpNotes_help {
    return Intl.message(
      'Cette vue présente les notes de suivi de la prise en charge, avec leur date, leur titre et un aperçu de leur contenu.\n\nLe bouton d’ajout permet de créer une note. L’icône de modification permet d’ouvrir une note existante pour la consulter ou la modifier.\n\nUtilisez les cases de sélection pour choisir les notes à inclure dans le bilan ou le rapport en cours. Décocher une note la retire de cette sélection sans supprimer la note de suivi.\n\nLa sélection est disponible lorsqu’un bilan ou un rapport est ouvert et que le chargement est terminé.\n\nCliquez sur la croix pour fermer la vue agrandie et revenir à l’espace Bilans/Rapports.',
      name: 'followUpNotes_help',
      desc: '',
      args: [],
    );
  }

  /// `Cette fenêtre permet de créer ou de modifier une note de suivi rattachée à l’épisode de soins.\n\nRenseignez un titre et le contenu de la note. Ces deux champs doivent contenir du texte pour que la note soit enregistrée.\n\nLors de la création, cliquez sur « Ajouter ». Lors d’une modification, cliquez sur « Enregistrer » pour conserver vos changements.\n\n« Annuler » ferme la fenêtre sans enregistrer votre saisie. Vous pouvez ouvrir puis fermer cette aide sans perdre le texte en cours de rédaction.`
  String get followUpNoteForm_help {
    return Intl.message(
      'Cette fenêtre permet de créer ou de modifier une note de suivi rattachée à l’épisode de soins.\n\nRenseignez un titre et le contenu de la note. Ces deux champs doivent contenir du texte pour que la note soit enregistrée.\n\nLors de la création, cliquez sur « Ajouter ». Lors d’une modification, cliquez sur « Enregistrer » pour conserver vos changements.\n\n« Annuler » ferme la fenêtre sans enregistrer votre saisie. Vous pouvez ouvrir puis fermer cette aide sans perdre le texte en cours de rédaction.',
      name: 'followUpNoteForm_help',
      desc: '',
      args: [],
    );
  }

  /// `Préfix ARB`
  String get g_arb_prefix {
    return Intl.message(
      'Préfix ARB',
      name: 'g_arb_prefix',
      desc: '',
      args: [],
    );
  }

  /// `Fermer`
  String get g_close {
    return Intl.message(
      'Fermer',
      name: 'g_close',
      desc: '',
      args: [],
    );
  }

  /// `Commentaire`
  String get g_comment {
    return Intl.message(
      'Commentaire',
      name: 'g_comment',
      desc: '',
      args: [],
    );
  }

  /// `Contexte`
  String get g_context {
    return Intl.message(
      'Contexte',
      name: 'g_context',
      desc: '',
      args: [],
    );
  }

  /// `Copier`
  String get g_copy {
    return Intl.message(
      'Copier',
      name: 'g_copy',
      desc: '',
      args: [],
    );
  }

  /// `Fichier`
  String get g_file {
    return Intl.message(
      'Fichier',
      name: 'g_file',
      desc: '',
      args: [],
    );
  }

  /// `Afficher l’aide`
  String get g_helpTooltip {
    return Intl.message(
      'Afficher l’aide',
      name: 'g_helpTooltip',
      desc: '',
      args: [],
    );
  }

  /// `En savoir plus`
  String get g_learn_more {
    return Intl.message(
      'En savoir plus',
      name: 'g_learn_more',
      desc: '',
      args: [],
    );
  }

  /// `Informations techniques`
  String get g_technical_informations {
    return Intl.message(
      'Informations techniques',
      name: 'g_technical_informations',
      desc: '',
      args: [],
    );
  }

  /// `Informations techniques copiées`
  String get g_technical_informations_copied {
    return Intl.message(
      'Informations techniques copiées',
      name: 'g_technical_informations_copied',
      desc: '',
      args: [],
    );
  }

  /// `Les patients archivés peuvent être restaurés jusqu'à la date indiquée.\nAprès cette date, ils sont supprimés automatiquement afin de ne pas conserver indéfiniment des dossiers inutilisés.\nLa durée de conservation peut être modifiée dans les paramètres de Companion.`
  String get help_archived_patient {
    return Intl.message(
      'Les patients archivés peuvent être restaurés jusqu\'à la date indiquée.\nAprès cette date, ils sont supprimés automatiquement afin de ne pas conserver indéfiniment des dossiers inutilisés.\nLa durée de conservation peut être modifiée dans les paramètres de Companion.',
      name: 'help_archived_patient',
      desc: '',
      args: [],
    );
  }

  /// `Il s'agit des appareils (téléphone, tablette) utilisés pour réaliser les tests.\n- Un appareil peut être utilisé par des personnes différentes.\n- Une personne peut posséder plusieurs appareils.\n\nCette information permet de savoir quelle est la source matérielle de l'information qui est transférée vers Companion.\nVous pouvez créer, modifier, archiver un appareil.\n\nPour des raisons de traçabilité il n'est pas possible de supprimer un appareil\nVous pouvez si nécessaire restaurer un appareil archivé.\n\nC'est un QR Code qui est utilisé pour appairer un téléphone ou une tablette. Il faut afficher le QR Code sur le poste fixe (Appareil > icone correspondant de l'appareil) et sur le téléphone (ou la tablette) accéder aux paramètres > Organisation professionnelle > Appareils enregistrés > Ajouter un appareil.\n\nApprochez l'appareil de l'écran pour lire le QR Code.Un message vous informe de la réussite de l'opération.`
  String get help_device_list_content {
    return Intl.message(
      'Il s\'agit des appareils (téléphone, tablette) utilisés pour réaliser les tests.\n- Un appareil peut être utilisé par des personnes différentes.\n- Une personne peut posséder plusieurs appareils.\n\nCette information permet de savoir quelle est la source matérielle de l\'information qui est transférée vers Companion.\nVous pouvez créer, modifier, archiver un appareil.\n\nPour des raisons de traçabilité il n\'est pas possible de supprimer un appareil\nVous pouvez si nécessaire restaurer un appareil archivé.\n\nC\'est un QR Code qui est utilisé pour appairer un téléphone ou une tablette. Il faut afficher le QR Code sur le poste fixe (Appareil > icone correspondant de l\'appareil) et sur le téléphone (ou la tablette) accéder aux paramètres > Organisation professionnelle > Appareils enregistrés > Ajouter un appareil.\n\nApprochez l\'appareil de l\'écran pour lire le QR Code.Un message vous informe de la réussite de l\'opération.',
      name: 'help_device_list_content',
      desc: '',
      args: [],
    );
  }

  /// `Liste des appareils`
  String get help_device_list_title {
    return Intl.message(
      'Liste des appareils',
      name: 'help_device_list_title',
      desc: '',
      args: [],
    );
  }

  /// `Vous trouvez ici les données complémentaires concernant votre patient`
  String get help_donnees_cliniques_patient {
    return Intl.message(
      'Vous trouvez ici les données complémentaires concernant votre patient',
      name: 'help_donnees_cliniques_patient',
      desc: '',
      args: [],
    );
  }

  /// `Cet écran est l'écran principal d'ABAK Companion.\n\nIl est constitué :\n\n1) d'un bandeau qui vous informe : \n - sur le nombre de patients actifs et archivés.\n  - du nombre d'alertes en cours.\n\nVous pouvez dans les paramètres renseigner le nom de votre établissement et ajouter votre logo.\n\n2) "Imports récents" vous indique les dernier dossier de résultats importés depuis ABAK Mobile.\n\n3) "Etat système" vous indique un éventuel problème et la date de la dernière sauvegarde.\n\n4) "Nouveau résultats ABAK à associer", vous montre les résultats qui ont été envoyé depuis ABAK Mobile mais qui ne sont pas encore attribués à un patient dans ABAK Companion.\n\n5) "Alerte système" vous renseigne sur la nature d'un problème.\n\n6) "Action rapide", vous permet d'accéder à l'historique de tous vos imports et de créer une nouvelle sauvegarde.`
  String get help_home {
    return Intl.message(
      'Cet écran est l\'écran principal d\'ABAK Companion.\n\nIl est constitué :\n\n1) d\'un bandeau qui vous informe : \n - sur le nombre de patients actifs et archivés.\n  - du nombre d\'alertes en cours.\n\nVous pouvez dans les paramètres renseigner le nom de votre établissement et ajouter votre logo.\n\n2) "Imports récents" vous indique les dernier dossier de résultats importés depuis ABAK Mobile.\n\n3) "Etat système" vous indique un éventuel problème et la date de la dernière sauvegarde.\n\n4) "Nouveau résultats ABAK à associer", vous montre les résultats qui ont été envoyé depuis ABAK Mobile mais qui ne sont pas encore attribués à un patient dans ABAK Companion.\n\n5) "Alerte système" vous renseigne sur la nature d\'un problème.\n\n6) "Action rapide", vous permet d\'accéder à l\'historique de tous vos imports et de créer une nouvelle sauvegarde.',
      name: 'help_home',
      desc: '',
      args: [],
    );
  }

  /// `Les patients actifs sont ceux à qui vous pouvez attribuer un résultat de test ou questionnaire.\n\nLes patients archivés sont des patients dont les informations seront prochainement supprimées de l'ordinateur.\n\nLa suppression intervient automatiquement aprsès la date indiquée.\n\nVous pouvez :\n  - Gérer le délai de conservation dans Paramètres.\n. -Réactiver un patient archivé pour le rendre actif.\n\nLa durée de conservation est paramètrable entre 30 et 365 jours.`
  String get help_home_active_archived_patients_content {
    return Intl.message(
      'Les patients actifs sont ceux à qui vous pouvez attribuer un résultat de test ou questionnaire.\n\nLes patients archivés sont des patients dont les informations seront prochainement supprimées de l\'ordinateur.\n\nLa suppression intervient automatiquement aprsès la date indiquée.\n\nVous pouvez :\n  - Gérer le délai de conservation dans Paramètres.\n. -Réactiver un patient archivé pour le rendre actif.\n\nLa durée de conservation est paramètrable entre 30 et 365 jours.',
      name: 'help_home_active_archived_patients_content',
      desc: '',
      args: [],
    );
  }

  /// `Patients actifs et archivés`
  String get help_home_active_archived_patients_title {
    return Intl.message(
      'Patients actifs et archivés',
      name: 'help_home_active_archived_patients_title',
      desc: '',
      args: [],
    );
  }

  /// `Les tests et exercices sont réalisés sur votre téléphone (ou tablette) avecABAK Mobile.\nUne fois le test terminé, si vous avez enregistré le résultat, l'option Dossier > Envoyer vers Desktop vous permet de transférer les informations vers ABAK Companion\n\nUn message dans Companion vous informe qu'un dossier est arrivé et qu'il faut l'attribuer à un patient. Cette attribution vous conduit à sélectionner le patient puis à sélectionner l'épisode de soin.\n\nPourquoi un tel mécanisme ?\nABAK mobile ne gère pas les dossiers patients. Sur ABAK Mobile, vous pouvez identifier le patient par un pseudo et celui ci peut être différent selon le praticien. Ce pseudo vous sert ensuite à attribuer le résultat au bon patient. Ce mécanisme permet de conserver une indépendance de fonctionnemnent entre les deux applications et préserve, autant que possible, l'anonymat des patients sur le téléphone ou la tablette qui peuvent êtr partagés.`
  String get help_home_import_assignment_content {
    return Intl.message(
      'Les tests et exercices sont réalisés sur votre téléphone (ou tablette) avecABAK Mobile.\nUne fois le test terminé, si vous avez enregistré le résultat, l\'option Dossier > Envoyer vers Desktop vous permet de transférer les informations vers ABAK Companion\n\nUn message dans Companion vous informe qu\'un dossier est arrivé et qu\'il faut l\'attribuer à un patient. Cette attribution vous conduit à sélectionner le patient puis à sélectionner l\'épisode de soin.\n\nPourquoi un tel mécanisme ?\nABAK mobile ne gère pas les dossiers patients. Sur ABAK Mobile, vous pouvez identifier le patient par un pseudo et celui ci peut être différent selon le praticien. Ce pseudo vous sert ensuite à attribuer le résultat au bon patient. Ce mécanisme permet de conserver une indépendance de fonctionnemnent entre les deux applications et préserve, autant que possible, l\'anonymat des patients sur le téléphone ou la tablette qui peuvent êtr partagés.',
      name: 'help_home_import_assignment_content',
      desc: '',
      args: [],
    );
  }

  /// `Récupération d'un résultats et affectation à un patient`
  String get help_home_import_assignment_title {
    return Intl.message(
      'Récupération d\'un résultats et affectation à un patient',
      name: 'help_home_import_assignment_title',
      desc: '',
      args: [],
    );
  }

  /// `Vous trouvez ici l'identification de votre patient`
  String get help_information_patient {
    return Intl.message(
      'Vous trouvez ici l\'identification de votre patient',
      name: 'help_information_patient',
      desc: '',
      args: [],
    );
  }

  /// `Cet écran permet :\n - La sélection de la langue.\n - La définition de la duré de consevation des dossiers patients archivés.\n - L'activation du mode expertı\n - L'accession à l'écrran Etablissement pour saisir le nom de votre établisement et son logo`
  String get help_parametres_utilisateur {
    return Intl.message(
      'Cet écran permet :\n - La sélection de la langue.\n - La définition de la duré de consevation des dossiers patients archivés.\n - L\'activation du mode expertı\n - L\'accession à l\'écrran Etablissement pour saisir le nom de votre établisement et son logo',
      name: 'help_parametres_utilisateur',
      desc: '',
      args: [],
    );
  }

  /// `Cet écran vous permet d'ajouter un nouveau praticien, de modifier les informations le concernant.\n\nLa mise dans la corbeille ne supprime pas le praticien. Pour des raisons de traçabilité il n'est pas possible de supprimer un praticien.\n\nL'affichage du QR Code vous permet de créer atutomatiquement le profil du praticien pour votre établissement dans le téléphone ou la tablette de celui-ci.`
  String get help_practitionerList_helpText {
    return Intl.message(
      'Cet écran vous permet d\'ajouter un nouveau praticien, de modifier les informations le concernant.\n\nLa mise dans la corbeille ne supprime pas le praticien. Pour des raisons de traçabilité il n\'est pas possible de supprimer un praticien.\n\nL\'affichage du QR Code vous permet de créer atutomatiquement le profil du praticien pour votre établissement dans le téléphone ou la tablette de celui-ci.',
      name: 'help_practitionerList_helpText',
      desc: '',
      args: [],
    );
  }

  /// `Une prise en charge correspond à un épisode de soin.\nVous trouvez ici les différentes prises en charge  actives de votre patient.\nPour rattacher un résultat, vous pouvez utiliser un épisode existant ou en créer un nouveau.\nUne fois l'épisode terminé vous pouvez l'archiver.`
  String get help_prise_en_charge {
    return Intl.message(
      'Une prise en charge correspond à un épisode de soin.\nVous trouvez ici les différentes prises en charge  actives de votre patient.\nPour rattacher un résultat, vous pouvez utiliser un épisode existant ou en créer un nouveau.\nUne fois l\'épisode terminé vous pouvez l\'archiver.',
      name: 'help_prise_en_charge',
      desc: '',
      args: [],
    );
  }

  /// `Exercice ABAK`
  String get home_abak_exercice {
    return Intl.message(
      'Exercice ABAK',
      name: 'home_abak_exercice',
      desc: '',
      args: [],
    );
  }

  /// `Fichier ABAK`
  String get home_abak_file {
    return Intl.message(
      'Fichier ABAK',
      name: 'home_abak_file',
      desc: '',
      args: [],
    );
  }

  /// `Accueil`
  String get home_accueil {
    return Intl.message(
      'Accueil',
      name: 'home_accueil',
      desc: '',
      args: [],
    );
  }

  /// `Action requise : associer ce dossier à un patient.`
  String get home_action_required {
    return Intl.message(
      'Action requise : associer ce dossier à un patient.',
      name: 'home_action_required',
      desc: '',
      args: [],
    );
  }

  /// `Déjà importé`
  String get home_already_imported {
    return Intl.message(
      'Déjà importé',
      name: 'home_already_imported',
      desc: '',
      args: [],
    );
  }

  /// `Une intervention est nécessaire`
  String get home_an_intervention_is_necessary {
    return Intl.message(
      'Une intervention est nécessaire',
      name: 'home_an_intervention_is_necessary',
      desc: '',
      args: [],
    );
  }

  /// `Archives`
  String get home_archives {
    return Intl.message(
      'Archives',
      name: 'home_archives',
      desc: '',
      args: [],
    );
  }

  /// `Attention`
  String get home_attention {
    return Intl.message(
      'Attention',
      name: 'home_attention',
      desc: '',
      args: [],
    );
  }

  /// `Sauvegarde créée avec succès.`
  String get home_backup_successfully_created {
    return Intl.message(
      'Sauvegarde créée avec succès.',
      name: 'home_backup_successfully_created',
      desc: '',
      args: [],
    );
  }

  /// `Date du bilan`
  String get home_balance_sheet_date {
    return Intl.message(
      'Date du bilan',
      name: 'home_balance_sheet_date',
      desc: '',
      args: [],
    );
  }

  /// `Conflit détecté`
  String get home_conflict_detected {
    return Intl.message(
      'Conflit détecté',
      name: 'home_conflict_detected',
      desc: '',
      args: [],
    );
  }

  /// `Correspondants`
  String get home_correspondents {
    return Intl.message(
      'Correspondants',
      name: 'home_correspondents',
      desc: '',
      args: [],
    );
  }

  /// `Créer une sauvegarde`
  String get home_create_a_backup {
    return Intl.message(
      'Créer une sauvegarde',
      name: 'home_create_a_backup',
      desc: '',
      args: [],
    );
  }

  /// `Date non renseignée`
  String get home_date_not_specified {
    return Intl.message(
      'Date non renseignée',
      name: 'home_date_not_specified',
      desc: '',
      args: [],
    );
  }

  /// `Appareils`
  String get home_devices {
    return Intl.message(
      'Appareils',
      name: 'home_devices',
      desc: '',
      args: [],
    );
  }

  /// `Erreur lors de la sauvegarde : {error}`
  String home_error_while_saving(Object error) {
    return Intl.message(
      'Erreur lors de la sauvegarde : $error',
      name: 'home_error_while_saving',
      desc: '',
      args: [error],
    );
  }

  /// `Tout fonctionne normalement`
  String get home_everything_is_working_normally {
    return Intl.message(
      'Tout fonctionne normalement',
      name: 'home_everything_is_working_normally',
      desc: '',
      args: [],
    );
  }

  /// `Cet écran est l'écran principal de Companion.`
  String get home_expert_comment {
    return Intl.message(
      'Cet écran est l\'écran principal de Companion.',
      name: 'home_expert_comment',
      desc: '',
      args: [],
    );
  }

  /// `Échec`
  String get home_failure {
    return Intl.message(
      'Échec',
      name: 'home_failure',
      desc: '',
      args: [],
    );
  }

  /// `Fermer`
  String get home_fermer {
    return Intl.message(
      'Fermer',
      name: 'home_fermer',
      desc: '',
      args: [],
    );
  }

  /// `Fichier`
  String get home_file {
    return Intl.message(
      'Fichier',
      name: 'home_file',
      desc: '',
      args: [],
    );
  }

  /// `Historique`
  String get home_historique {
    return Intl.message(
      'Historique',
      name: 'home_historique',
      desc: '',
      args: [],
    );
  }

  /// `Accueil`
  String get home_home {
    return Intl.message(
      'Accueil',
      name: 'home_home',
      desc: '',
      args: [],
    );
  }

  /// `Historique des imports`
  String get home_import_history {
    return Intl.message(
      'Historique des imports',
      name: 'home_import_history',
      desc: '',
      args: [],
    );
  }

  /// `Imports interrompus ou en cours`
  String get home_imports_interrupted_or_in_progress {
    return Intl.message(
      'Imports interrompus ou en cours',
      name: 'home_imports_interrupted_or_in_progress',
      desc: '',
      args: [],
    );
  }

  /// `Imports en erreur`
  String get home_imports_with_errors {
    return Intl.message(
      'Imports en erreur',
      name: 'home_imports_with_errors',
      desc: '',
      args: [],
    );
  }

  /// `A propos`
  String get home_information {
    return Intl.message(
      'A propos',
      name: 'home_information',
      desc: '',
      args: [],
    );
  }

  /// `Chemin du fichier invalide :`
  String get home_invalid_file_path {
    return Intl.message(
      'Chemin du fichier invalide :',
      name: 'home_invalid_file_path',
      desc: '',
      args: [],
    );
  }

  /// `Adresse IP introuvable`
  String get home_ipAddressNotFound {
    return Intl.message(
      'Adresse IP introuvable',
      name: 'home_ipAddressNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Impossible de déterminer l'adresse IP locale du Desktop.\n\nVérifiez que l'ordinateur est connecté au réseau local.`
  String get home_ipAddressNotFoundMessage {
    return Intl.message(
      'Impossible de déterminer l\'adresse IP locale du Desktop.\n\nVérifiez que l\'ordinateur est connecté au réseau local.',
      name: 'home_ipAddressNotFoundMessage',
      desc: '',
      args: [],
    );
  }

  /// `Nombre important de patients archivés`
  String get home_large_number_of_archived_patients {
    return Intl.message(
      'Nombre important de patients archivés',
      name: 'home_large_number_of_archived_patients',
      desc: '',
      args: [],
    );
  }

  /// `Base SQLite volumineuse`
  String get home_large_sqlite_database {
    return Intl.message(
      'Base SQLite volumineuse',
      name: 'home_large_sqlite_database',
      desc: '',
      args: [],
    );
  }

  /// `Dernière sauvegarde`
  String get home_last_backup {
    return Intl.message(
      'Dernière sauvegarde',
      name: 'home_last_backup',
      desc: '',
      args: [],
    );
  }

  /// `Dernière sauvegarde ancienne`
  String get home_last_old_backup {
    return Intl.message(
      'Dernière sauvegarde ancienne',
      name: 'home_last_old_backup',
      desc: '',
      args: [],
    );
  }

  /// `Associer à une prise en charge`
  String get home_link_to_a_care_plan {
    return Intl.message(
      'Associer à une prise en charge',
      name: 'home_link_to_a_care_plan',
      desc: '',
      args: [],
    );
  }

  /// `Plus de 7 jours`
  String get home_more_7_days {
    return Intl.message(
      'Plus de 7 jours',
      name: 'home_more_7_days',
      desc: '',
      args: [],
    );
  }

  /// `Nouveaux résultats ABAK à associer à un patient`
  String get home_new_abak_results_to_be_linked {
    return Intl.message(
      'Nouveaux résultats ABAK à associer à un patient',
      name: 'home_new_abak_results_to_be_linked',
      desc: '',
      args: [],
    );
  }

  /// `Aucun résultat ABAK à associer.`
  String get home_no_abak_result_to_associate {
    return Intl.message(
      'Aucun résultat ABAK à associer.',
      name: 'home_no_abak_result_to_associate',
      desc: '',
      args: [],
    );
  }

  /// `Aucune alerte détectée`
  String get home_no_alert_detected {
    return Intl.message(
      'Aucune alerte détectée',
      name: 'home_no_alert_detected',
      desc: '',
      args: [],
    );
  }

  /// `Aucun import enregistré.`
  String get home_no_imports_recorded {
    return Intl.message(
      'Aucun import enregistré.',
      name: 'home_no_imports_recorded',
      desc: '',
      args: [],
    );
  }

  /// `Aucun import en attente`
  String get home_no_pending_imports {
    return Intl.message(
      'Aucun import en attente',
      name: 'home_no_pending_imports',
      desc: '',
      args: [],
    );
  }

  /// `Aucune sauvegarde enregistrée`
  String get home_no_saved_backup {
    return Intl.message(
      'Aucune sauvegarde enregistrée',
      name: 'home_no_saved_backup',
      desc: '',
      args: [],
    );
  }

  /// `renseignée`
  String get home_not_specified {
    return Intl.message(
      'renseignée',
      name: 'home_not_specified',
      desc: '',
      args: [],
    );
  }

  /// `Octets`
  String get home_octets {
    return Intl.message(
      'Octets',
      name: 'home_octets',
      desc: '',
      args: [],
    );
  }

  /// `{count} autre(s) exercice(s)`
  String home_other_exercises(Object count) {
    return Intl.message(
      '$count autre(s) exercice(s)',
      name: 'home_other_exercises',
      desc: '',
      args: [count],
    );
  }

  /// `Paramètres`
  String get home_parameters {
    return Intl.message(
      'Paramètres',
      name: 'home_parameters',
      desc: '',
      args: [],
    );
  }

  /// `Chemin`
  String get home_pathway {
    return Intl.message(
      'Chemin',
      name: 'home_pathway',
      desc: '',
      args: [],
    );
  }

  /// `Patient ABAK`
  String get home_patient_abak {
    return Intl.message(
      'Patient ABAK',
      name: 'home_patient_abak',
      desc: '',
      args: [],
    );
  }

  /// `Patients`
  String get home_patients {
    return Intl.message(
      'Patients',
      name: 'home_patients',
      desc: '',
      args: [],
    );
  }

  /// `{count} association(s) en attente`
  String home_pending_association(Object count) {
    return Intl.message(
      '$count association(s) en attente',
      name: 'home_pending_association',
      desc: '',
      args: [count],
    );
  }

  /// `praticiens`
  String get home_practitioners {
    return Intl.message(
      'praticiens',
      name: 'home_practitioners',
      desc: '',
      args: [],
    );
  }

  /// `Actions rapides`
  String get home_quick_actions {
    return Intl.message(
      'Actions rapides',
      name: 'home_quick_actions',
      desc: '',
      args: [],
    );
  }

  /// `Imports récents`
  String get home_receents_imports {
    return Intl.message(
      'Imports récents',
      name: 'home_receents_imports',
      desc: '',
      args: [],
    );
  }

  /// `Restauration récente détectée`
  String get home_recent_restoration_detected {
    return Intl.message(
      'Restauration récente détectée',
      name: 'home_recent_restoration_detected',
      desc: '',
      args: [],
    );
  }

  /// `Résultats`
  String get home_results {
    return Intl.message(
      'Résultats',
      name: 'home_results',
      desc: '',
      args: [],
    );
  }

  /// `Scannez ce QR code depuis ABAK Mobile pour configurer automatiquement la connexion au Desktop.`
  String get home_select_qr_code {
    return Intl.message(
      'Scannez ce QR code depuis ABAK Mobile pour configurer automatiquement la connexion au Desktop.',
      name: 'home_select_qr_code',
      desc: '',
      args: [],
    );
  }

  /// `Assistance`
  String get home_settings {
    return Intl.message(
      'Assistance',
      name: 'home_settings',
      desc: '',
      args: [],
    );
  }

  /// `Taille`
  String get home_size {
    return Intl.message(
      'Taille',
      name: 'home_size',
      desc: '',
      args: [],
    );
  }

  /// `Résoudre`
  String get home_solve {
    return Intl.message(
      'Résoudre',
      name: 'home_solve',
      desc: '',
      args: [],
    );
  }

  /// `Succès`
  String get home_success {
    return Intl.message(
      'Succès',
      name: 'home_success',
      desc: '',
      args: [],
    );
  }

  /// `Alerte système`
  String get home_system_alert {
    return Intl.message(
      'Alerte système',
      name: 'home_system_alert',
      desc: '',
      args: [],
    );
  }

  /// `État système`
  String get home_system_status {
    return Intl.message(
      'État système',
      name: 'home_system_status',
      desc: '',
      args: [],
    );
  }

  /// `Informations techniques`
  String get home_technical_information {
    return Intl.message(
      'Informations techniques',
      name: 'home_technical_information',
      desc: '',
      args: [],
    );
  }

  /// `Ce fichier avait déjà été importé. Aucune donnée n'a été ajoutée.`
  String get home_this_file_had_already_been_imported {
    return Intl.message(
      'Ce fichier avait déjà été importé. Aucune donnée n\'a été ajoutée.',
      name: 'home_this_file_had_already_been_imported',
      desc: '',
      args: [],
    );
  }

  /// `à vérifier`
  String get home_to_be_verified {
    return Intl.message(
      'à vérifier',
      name: 'home_to_be_verified',
      desc: '',
      args: [],
    );
  }

  /// `À faire`
  String get home_to_do_list {
    return Intl.message(
      'À faire',
      name: 'home_to_do_list',
      desc: '',
      args: [],
    );
  }

  /// `Impossible de charger les imports récents.`
  String get home_unable_to_load_recent_imports {
    return Intl.message(
      'Impossible de charger les imports récents.',
      name: 'home_unable_to_load_recent_imports',
      desc: '',
      args: [],
    );
  }

  /// `Import ABAK illisible.`
  String get home_unreadable_abak_import {
    return Intl.message(
      'Import ABAK illisible.',
      name: 'home_unreadable_abak_import',
      desc: '',
      args: [],
    );
  }

  /// `En échec`
  String get home_unsuccessful {
    return Intl.message(
      'En échec',
      name: 'home_unsuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Vérifier`
  String get home_verify {
    return Intl.message(
      'Vérifier',
      name: 'home_verify',
      desc: '',
      args: [],
    );
  }

  /// `Sauvegardes très volumineuses`
  String get home_very_large_backups {
    return Intl.message(
      'Sauvegardes très volumineuses',
      name: 'home_very_large_backups',
      desc: '',
      args: [],
    );
  }

  /// `Conflits`
  String get homeImportSummary_conflicts {
    return Intl.message(
      'Conflits',
      name: 'homeImportSummary_conflicts',
      desc: '',
      args: [],
    );
  }

  /// `Fichiers en erreur`
  String get homeImportSummary_failedFiles {
    return Intl.message(
      'Fichiers en erreur',
      name: 'homeImportSummary_failedFiles',
      desc: '',
      args: [],
    );
  }

  /// `Date import`
  String get homeImportSummary_importDate {
    return Intl.message(
      'Date import',
      name: 'homeImportSummary_importDate',
      desc: '',
      args: [],
    );
  }

  /// `Métriques importées`
  String get homeImportSummary_importedMetrics {
    return Intl.message(
      'Métriques importées',
      name: 'homeImportSummary_importedMetrics',
      desc: '',
      args: [],
    );
  }

  /// `Résultats importés`
  String get homeImportSummary_importedResults {
    return Intl.message(
      'Résultats importés',
      name: 'homeImportSummary_importedResults',
      desc: '',
      args: [],
    );
  }

  /// `Ouvrir`
  String get homeImportSummary_open {
    return Intl.message(
      'Ouvrir',
      name: 'homeImportSummary_open',
      desc: '',
      args: [],
    );
  }

  /// `Patients concernés`
  String get homeImportSummary_patients {
    return Intl.message(
      'Patients concernés',
      name: 'homeImportSummary_patients',
      desc: '',
      args: [],
    );
  }

  /// `Fichiers traités`
  String get homeImportSummary_processedFiles {
    return Intl.message(
      'Fichiers traités',
      name: 'homeImportSummary_processedFiles',
      desc: '',
      args: [],
    );
  }

  /// `Résultats ignorés`
  String get homeImportSummary_skippedResults {
    return Intl.message(
      'Résultats ignorés',
      name: 'homeImportSummary_skippedResults',
      desc: '',
      args: [],
    );
  }

  /// `Dernier import ABAK`
  String get homeImportSummary_title {
    return Intl.message(
      'Dernier import ABAK',
      name: 'homeImportSummary_title',
      desc: '',
      args: [],
    );
  }

  /// `Cette fenêtre permet de créer un patient pour lui rattacher les résultats importés depuis ABAK Mobile.\n\nSaisissez son nom et son prénom. Vous pouvez compléter sa date de naissance au format AAAA-MM-JJ et renseigner son sexe, ou conserver « Non renseigné ».\n\nSi vous avez utilisé la lecture de la carte Vitale, vérifiez les informations préremplies et corrigez-les si nécessaire.\n\nCliquez sur « Créer » pour enregistrer le patient et le sélectionner. Choisissez ensuite la prise en charge à laquelle rattacher les résultats : la création du patient ne termine pas, à elle seule, le rattachement de l’import.\n\n« Annuler » ferme cette fenêtre sans créer de patient. L’ouverture puis la fermeture de cette aide conserve votre saisie.`
  String get importPatientForm_help {
    return Intl.message(
      'Cette fenêtre permet de créer un patient pour lui rattacher les résultats importés depuis ABAK Mobile.\n\nSaisissez son nom et son prénom. Vous pouvez compléter sa date de naissance au format AAAA-MM-JJ et renseigner son sexe, ou conserver « Non renseigné ».\n\nSi vous avez utilisé la lecture de la carte Vitale, vérifiez les informations préremplies et corrigez-les si nécessaire.\n\nCliquez sur « Créer » pour enregistrer le patient et le sélectionner. Choisissez ensuite la prise en charge à laquelle rattacher les résultats : la création du patient ne termine pas, à elle seule, le rattachement de l’import.\n\n« Annuler » ferme cette fenêtre sans créer de patient. L’ouverture puis la fermeture de cette aide conserve votre saisie.',
      name: 'importPatientForm_help',
      desc: '',
      args: [],
    );
  }

  /// `Nouveau patient`
  String get importPatientForm_title {
    return Intl.message(
      'Nouveau patient',
      name: 'importPatientForm_title',
      desc: '',
      args: [],
    );
  }

  /// `Rattacher l'import`
  String get importResolution_title {
    return Intl.message(
      'Rattacher l\'import',
      name: 'importResolution_title',
      desc: '',
      args: [],
    );
  }

  /// `fichier`
  String get importResolutionAssistant_file {
    return Intl.message(
      'fichier',
      name: 'importResolutionAssistant_file',
      desc: '',
      args: [],
    );
  }

  /// `fichiers`
  String get importResolutionAssistant_files {
    return Intl.message(
      'fichiers',
      name: 'importResolutionAssistant_files',
      desc: '',
      args: [],
    );
  }

  /// `Import`
  String get importResolutionAssistant_import {
    return Intl.message(
      'Import',
      name: 'importResolutionAssistant_import',
      desc: '',
      args: [],
    );
  }

  /// `Import en échec`
  String get importResolutionAssistant_importFailed {
    return Intl.message(
      'Import en échec',
      name: 'importResolutionAssistant_importFailed',
      desc: '',
      args: [],
    );
  }

  /// `Import à terminer`
  String get importResolutionAssistant_importToComplete {
    return Intl.message(
      'Import à terminer',
      name: 'importResolutionAssistant_importToComplete',
      desc: '',
      args: [],
    );
  }

  /// `Import à vérifier`
  String get importResolutionAssistant_importToReview {
    return Intl.message(
      'Import à vérifier',
      name: 'importResolutionAssistant_importToReview',
      desc: '',
      args: [],
    );
  }

  /// `en erreur`
  String get importResolutionAssistant_inError {
    return Intl.message(
      'en erreur',
      name: 'importResolutionAssistant_inError',
      desc: '',
      args: [],
    );
  }

  /// `Une intervention est nécessaire pour terminer cet import.`
  String get importResolutionAssistant_interventionRequired {
    return Intl.message(
      'Une intervention est nécessaire pour terminer cet import.',
      name: 'importResolutionAssistant_interventionRequired',
      desc: '',
      args: [],
    );
  }

  /// `Impossible de charger les imports`
  String get importResolutionAssistant_loadingError {
    return Intl.message(
      'Impossible de charger les imports',
      name: 'importResolutionAssistant_loadingError',
      desc: '',
      args: [],
    );
  }

  /// `Aucun problème d’import détecté.`
  String get importResolutionAssistant_noProblem {
    return Intl.message(
      'Aucun problème d’import détecté.',
      name: 'importResolutionAssistant_noProblem',
      desc: '',
      args: [],
    );
  }

  /// `résultat`
  String get importResolutionAssistant_result {
    return Intl.message(
      'résultat',
      name: 'importResolutionAssistant_result',
      desc: '',
      args: [],
    );
  }

  /// `résultats`
  String get importResolutionAssistant_results {
    return Intl.message(
      'résultats',
      name: 'importResolutionAssistant_results',
      desc: '',
      args: [],
    );
  }

  /// `Sélectionnez un import pour afficher son détail et suivre les étapes proposées.`
  String get importResolutionAssistant_selectImportInstruction {
    return Intl.message(
      'Sélectionnez un import pour afficher son détail et suivre les étapes proposées.',
      name: 'importResolutionAssistant_selectImportInstruction',
      desc: '',
      args: [],
    );
  }

  /// `Résolution des problèmes d’import`
  String get importResolutionAssistant_title {
    return Intl.message(
      'Résolution des problèmes d’import',
      name: 'importResolutionAssistant_title',
      desc: '',
      args: [],
    );
  }

  /// `à vérifier`
  String get importResolutionAssistant_toReview {
    return Intl.message(
      'à vérifier',
      name: 'importResolutionAssistant_toReview',
      desc: '',
      args: [],
    );
  }

  /// `Suivi de l’import`
  String get importSessionDetail_title {
    return Intl.message(
      'Suivi de l’import',
      name: 'importSessionDetail_title',
      desc: '',
      args: [],
    );
  }

  /// `{count} sauvegardes`
  String information_backupCount(Object count) {
    return Intl.message(
      '$count sauvegardes',
      name: 'information_backupCount',
      desc: '',
      args: [count],
    );
  }

  /// `Sauvegardes`
  String get information_backups {
    return Intl.message(
      'Sauvegardes',
      name: 'information_backups',
      desc: '',
      args: [],
    );
  }

  /// `Configuré`
  String get information_configured {
    return Intl.message(
      'Configuré',
      name: 'information_configured',
      desc: '',
      args: [],
    );
  }

  /// `Cet écran affiche les informations générales, techniques et légales de Companion.`
  String get information_contextComment {
    return Intl.message(
      'Cet écran affiche les informations générales, techniques et légales de Companion.',
      name: 'information_contextComment',
      desc: '',
      args: [],
    );
  }

  /// `Informations`
  String get information_contextName {
    return Intl.message(
      'Informations',
      name: 'information_contextName',
      desc: '',
      args: [],
    );
  }

  /// `Base de données`
  String get information_database {
    return Intl.message(
      'Base de données',
      name: 'information_database',
      desc: '',
      args: [],
    );
  }

  /// `Cette page présente les informations générales de votre installation de Companion : version de l’application, cabinet configuré, présence du logo, système utilisé et langue.\n\nLa rubrique consacrée au stockage local indique la taille de la base de données ainsi que le nombre et la taille totale des sauvegardes enregistrées.\n\nLes boutons permettent de consulter les nouveautés, la licence et les avertissements relatifs à l’utilisation de l’application.\n\nLors d’un échange avec l’assistance, la version de Companion et le système affichés ici peuvent aider à identifier votre configuration.`
  String get information_help {
    return Intl.message(
      'Cette page présente les informations générales de votre installation de Companion : version de l’application, cabinet configuré, présence du logo, système utilisé et langue.\n\nLa rubrique consacrée au stockage local indique la taille de la base de données ainsi que le nombre et la taille totale des sauvegardes enregistrées.\n\nLes boutons permettent de consulter les nouveautés, la licence et les avertissements relatifs à l’utilisation de l’application.\n\nLors d’un échange avec l’assistance, la version de Companion et le système affichés ici peuvent aider à identifier votre configuration.',
      name: 'information_help',
      desc: '',
      args: [],
    );
  }

  /// `Langue`
  String get information_language {
    return Intl.message(
      'Langue',
      name: 'information_language',
      desc: '',
      args: [],
    );
  }

  /// `Avertissement légal`
  String get information_legalNotice {
    return Intl.message(
      'Avertissement légal',
      name: 'information_legalNotice',
      desc: '',
      args: [],
    );
  }

  /// `Chargement...`
  String get information_loading {
    return Intl.message(
      'Chargement...',
      name: 'information_loading',
      desc: '',
      args: [],
    );
  }

  /// `Stockage local`
  String get information_localStorage {
    return Intl.message(
      'Stockage local',
      name: 'information_localStorage',
      desc: '',
      args: [],
    );
  }

  /// `Logo`
  String get information_logo {
    return Intl.message(
      'Logo',
      name: 'information_logo',
      desc: '',
      args: [],
    );
  }

  /// `Version 1.1.0 build 3\nPossibilité de dictée vocale pour les bilans et rapports, nécessite le module gratuit.\nSauvegarde automatique Bilan et Rapport.\nBouton duplication Bilan et Rapport.\nNotes modifiables.\nBouton pour voir tous les tests d'un patient pour un épisode.\nModèles de bilans.\nGraphique automatique si plusieurs résultats pour un test\nCréation d'un document au format docx.\nAffichage de l'aide utilisée pour E72 et E76`
  String get information_new {
    return Intl.message(
      'Version 1.1.0 build 3\nPossibilité de dictée vocale pour les bilans et rapports, nécessite le module gratuit.\nSauvegarde automatique Bilan et Rapport.\nBouton duplication Bilan et Rapport.\nNotes modifiables.\nBouton pour voir tous les tests d\'un patient pour un épisode.\nModèles de bilans.\nGraphique automatique si plusieurs résultats pour un test\nCréation d\'un document au format docx.\nAffichage de l\'aide utilisée pour E72 et E76',
      name: 'information_new',
      desc: '',
      args: [],
    );
  }

  /// `Cette page présente les nouveautés et les évolutions décrites pour Companion.\n\nFaites défiler le texte pour consulter l’ensemble des informations. Vous pouvez sélectionner et copier un passage si nécessaire.\n\nUtilisez la flèche de retour pour revenir à la page « À propos ».`
  String get information_newHelp {
    return Intl.message(
      'Cette page présente les nouveautés et les évolutions décrites pour Companion.\n\nFaites défiler le texte pour consulter l’ensemble des informations. Vous pouvez sélectionner et copier un passage si nécessaire.\n\nUtilisez la flèche de retour pour revenir à la page « À propos ».',
      name: 'information_newHelp',
      desc: '',
      args: [],
    );
  }

  /// `Nouveautés de la version`
  String get information_newTitle {
    return Intl.message(
      'Nouveautés de la version',
      name: 'information_newTitle',
      desc: '',
      args: [],
    );
  }

  /// `Non configuré`
  String get information_notConfigured {
    return Intl.message(
      'Non configuré',
      name: 'information_notConfigured',
      desc: '',
      args: [],
    );
  }

  /// `Non renseigné`
  String get information_notProvided {
    return Intl.message(
      'Non renseigné',
      name: 'information_notProvided',
      desc: '',
      args: [],
    );
  }

  /// `Cabinet`
  String get information_office {
    return Intl.message(
      'Cabinet',
      name: 'information_office',
      desc: '',
      args: [],
    );
  }

  /// `Taille : {size}`
  String information_size(Object size) {
    return Intl.message(
      'Taille : $size',
      name: 'information_size',
      desc: '',
      args: [size],
    );
  }

  /// `Système`
  String get information_system {
    return Intl.message(
      'Système',
      name: 'information_system',
      desc: '',
      args: [],
    );
  }

  /// `Informations`
  String get information_title {
    return Intl.message(
      'Informations',
      name: 'information_title',
      desc: '',
      args: [],
    );
  }

  /// `Taille totale : {size}`
  String information_totalSize(Object size) {
    return Intl.message(
      'Taille totale : $size',
      name: 'information_totalSize',
      desc: '',
      args: [size],
    );
  }

  /// `Version {version}`
  String information_version(Object version) {
    return Intl.message(
      'Version $version',
      name: 'information_version',
      desc: '',
      args: [version],
    );
  }

  /// `Version...`
  String get information_versionLoading {
    return Intl.message(
      'Version...',
      name: 'information_versionLoading',
      desc: '',
      args: [],
    );
  }

  /// `Consulter la licence`
  String get information_viewLicense {
    return Intl.message(
      'Consulter la licence',
      name: 'information_viewLicense',
      desc: '',
      args: [],
    );
  }

  /// `Associer un bilan initial Word`
  String get initialReportDocumentService_associate {
    return Intl.message(
      'Associer un bilan initial Word',
      name: 'initialReportDocumentService_associate',
      desc: '',
      args: [],
    );
  }

  /// `Plateforme non supportée`
  String get initialReportDocumentService_unsupported {
    return Intl.message(
      'Plateforme non supportée',
      name: 'initialReportDocumentService_unsupported',
      desc: '',
      args: [],
    );
  }

  /// `Cet écran présente l’historique des sessions d’import enregistrées dans Companion.\n\nChaque ligne indique la date de la session, son état, le nombre de fichiers traités et le nombre de résultats importés, ignorés ou en conflit.\n\nL’icône signale notamment un import en cours, un échec, des erreurs ou des conflits nécessitant votre attention.\n\nCliquez sur une session pour consulter son détail et mieux comprendre le traitement des résultats.`
  String get importHistory_help {
    return Intl.message(
      'Cet écran présente l’historique des sessions d’import enregistrées dans Companion.\n\nChaque ligne indique la date de la session, son état, le nombre de fichiers traités et le nombre de résultats importés, ignorés ou en conflit.\n\nL’icône signale notamment un import en cours, un échec, des erreurs ou des conflits nécessitant votre attention.\n\nCliquez sur une session pour consulter son détail et mieux comprendre le traitement des résultats.',
      name: 'importHistory_help',
      desc: '',
      args: [],
    );
  }

  /// `Cet écran permet de rattacher les résultats reçus depuis ABAK Mobile au bon patient et à la bonne prise en charge dans Companion.\n\nConsultez les informations de l’import reçu, puis sélectionnez le patient concerné dans la liste. Si nécessaire, créez sa fiche avec « Nouveau patient » ou « Depuis Carte Vitale », lorsque le dispositif de lecture est disponible.\n\nAprès avoir sélectionné le patient, choisissez une prise en charge active ou créez-en une. Une prise en charge archivée doit être restaurée avant de pouvoir être sélectionnée.\n\nVérifiez le patient et la prise en charge avant de choisir cette dernière : sa sélection valide le rattachement et permet de poursuivre l’import.`
  String get importResolution_help {
    return Intl.message(
      'Cet écran permet de rattacher les résultats reçus depuis ABAK Mobile au bon patient et à la bonne prise en charge dans Companion.\n\nConsultez les informations de l’import reçu, puis sélectionnez le patient concerné dans la liste. Si nécessaire, créez sa fiche avec « Nouveau patient » ou « Depuis Carte Vitale », lorsque le dispositif de lecture est disponible.\n\nAprès avoir sélectionné le patient, choisissez une prise en charge active ou créez-en une. Une prise en charge archivée doit être restaurée avant de pouvoir être sélectionnée.\n\nVérifiez le patient et la prise en charge avant de choisir cette dernière : sa sélection valide le rattachement et permet de poursuivre l’import.',
      name: 'importResolution_help',
      desc: '',
      args: [],
    );
  }

  /// `Cet écran regroupe les imports qui nécessitent votre attention : association à un patient à compléter, échec de l’import, erreurs, résultats ignorés ou conflits à examiner.\n\nChaque ligne indique la date de l’import et les informations disponibles pour identifier le dossier concerné.\n\nCliquez sur un import pour ouvrir son suivi, consulter les explications et accéder aux actions proposées selon sa situation.\n\nLa liste est actualisée à votre retour depuis le suivi de l’import. Si aucun import ne répond à ces critères, un message indique qu’aucun problème n’a été détecté.`
  String get importResolutionAssistant_help {
    return Intl.message(
      'Cet écran regroupe les imports qui nécessitent votre attention : association à un patient à compléter, échec de l’import, erreurs, résultats ignorés ou conflits à examiner.\n\nChaque ligne indique la date de l’import et les informations disponibles pour identifier le dossier concerné.\n\nCliquez sur un import pour ouvrir son suivi, consulter les explications et accéder aux actions proposées selon sa situation.\n\nLa liste est actualisée à votre retour depuis le suivi de l’import. Si aucun import ne répond à ces critères, un message indique qu’aucun problème n’a été détecté.',
      name: 'importResolutionAssistant_help',
      desc: '',
      args: [],
    );
  }

  /// `Cet écran présente le suivi d’un import reçu dans Companion. Le message principal indique si l’import a réussi, nécessite une association à un patient ou comporte un problème.\n\nLorsqu’une association est nécessaire, cliquez sur « Associer à un patient » pour choisir le dossier auquel rattacher les résultats.\n\nLe compte rendu et la liste des fichiers permettent de consulter le détail du traitement et les éventuels avertissements.\n\nSi le fichier reçu est incomplet ou endommagé, demandez un nouvel envoi depuis ABAK Mobile.\n\nSelon la situation, le bouton « Supprimer cet import » est proposé. Consultez le message de confirmation avant de valider la suppression.`
  String get importSessionDetail_help {
    return Intl.message(
      'Cet écran présente le suivi d’un import reçu dans Companion. Le message principal indique si l’import a réussi, nécessite une association à un patient ou comporte un problème.\n\nLorsqu’une association est nécessaire, cliquez sur « Associer à un patient » pour choisir le dossier auquel rattacher les résultats.\n\nLe compte rendu et la liste des fichiers permettent de consulter le détail du traitement et les éventuels avertissements.\n\nSi le fichier reçu est incomplet ou endommagé, demandez un nouvel envoi depuis ABAK Mobile.\n\nSelon la situation, le bouton « Supprimer cet import » est proposé. Consultez le message de confirmation avant de valider la suppression.',
      name: 'importSessionDetail_help',
      desc: '',
      args: [],
    );
  }

  /// `Langue de l'application`
  String get language_choice {
    return Intl.message(
      'Langue de l\'application',
      name: 'language_choice',
      desc: '',
      args: [],
    );
  }

  /// `Langue enregistrée.`
  String get languageSaved {
    return Intl.message(
      'Langue enregistrée.',
      name: 'languageSaved',
      desc: '',
      args: [],
    );
  }

  /// `Avertissement`
  String get legalNotice_appBarTitle {
    return Intl.message(
      'Avertissement',
      name: 'legalNotice_appBarTitle',
      desc: '',
      args: [],
    );
  }

  /// `ABAK Desktop Companion est un logiciel d’aide à l’organisation, à l’importation et à la consultation de résultats cliniques issus de l’écosystème ABAK.\n\nIl ne constitue pas un dispositif médical certifié et ne remplace pas le jugement du professionnel de santé.\n\nLes résultats, scores, comptes rendus et indicateurs affichés doivent toujours être interprétés par un professionnel qualifié, en tenant compte de l’examen clinique, du contexte du patient et des recommandations en vigueur.\n\nL’utilisateur reste seul responsable de ses décisions cliniques, de la vérification des données importées et de la conformité de leur utilisation avec les règles professionnelles, réglementaires et déontologiques applicables.\n\nABAK Desktop Companion ne réalise pas de diagnostic autonome, ne prescrit aucun traitement et ne se substitue en aucun cas à une consultation médicale ou paramédicale.`
  String get legalNotice_content {
    return Intl.message(
      'ABAK Desktop Companion est un logiciel d’aide à l’organisation, à l’importation et à la consultation de résultats cliniques issus de l’écosystème ABAK.\n\nIl ne constitue pas un dispositif médical certifié et ne remplace pas le jugement du professionnel de santé.\n\nLes résultats, scores, comptes rendus et indicateurs affichés doivent toujours être interprétés par un professionnel qualifié, en tenant compte de l’examen clinique, du contexte du patient et des recommandations en vigueur.\n\nL’utilisateur reste seul responsable de ses décisions cliniques, de la vérification des données importées et de la conformité de leur utilisation avec les règles professionnelles, réglementaires et déontologiques applicables.\n\nABAK Desktop Companion ne réalise pas de diagnostic autonome, ne prescrit aucun traitement et ne se substitue en aucun cas à une consultation médicale ou paramédicale.',
      name: 'legalNotice_content',
      desc: '',
      args: [],
    );
  }

  /// `Cette page présente les avertissements et les informations relatifs à l’utilisation de Companion.\n\nFaites défiler la page pour lire l’intégralité du texte.\n\nUtilisez la flèche de retour pour revenir à la page « À propos ».`
  String get legalNotice_help {
    return Intl.message(
      'Cette page présente les avertissements et les informations relatifs à l’utilisation de Companion.\n\nFaites défiler la page pour lire l’intégralité du texte.\n\nUtilisez la flèche de retour pour revenir à la page « À propos ».',
      name: 'legalNotice_help',
      desc: '',
      args: [],
    );
  }

  /// `Avertissement Légal`
  String get legalNotice_title {
    return Intl.message(
      'Avertissement Légal',
      name: 'legalNotice_title',
      desc: '',
      args: [],
    );
  }

  /// `Chargement...`
  String get loading {
    return Intl.message(
      'Chargement...',
      name: 'loading',
      desc: '',
      args: [],
    );
  }

  /// `Sauvegarde annulée.`
  String get localDatabaseBackup_cancelled {
    return Intl.message(
      'Sauvegarde annulée.',
      name: 'localDatabaseBackup_cancelled',
      desc: '',
      args: [],
    );
  }

  /// `Choisir le dossier de sauvegarde ABAK`
  String get localDatabaseBackup_chooseBackupFolder {
    return Intl.message(
      'Choisir le dossier de sauvegarde ABAK',
      name: 'localDatabaseBackup_chooseBackupFolder',
      desc: '',
      args: [],
    );
  }

  /// `Base SQLite introuvable.`
  String get localDatabaseBackup_databaseNotFound {
    return Intl.message(
      'Base SQLite introuvable.',
      name: 'localDatabaseBackup_databaseNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Sauvegarde préalable impossible`
  String get localDatabaseReset_backupFailed {
    return Intl.message(
      'Sauvegarde préalable impossible',
      name: 'localDatabaseReset_backupFailed',
      desc: '',
      args: [],
    );
  }

  /// `La base restaurée présente une anomalie : {integrityStatus}`
  String localDatabaseRestoreService_anomaly(Object integrityStatus) {
    return Intl.message(
      'La base restaurée présente une anomalie : $integrityStatus',
      name: 'localDatabaseRestoreService_anomaly',
      desc: '',
      args: [integrityStatus],
    );
  }

  /// `Échec de la restauration : {error}`
  String localDatabaseRestoreService_failure(Object error) {
    return Intl.message(
      'Échec de la restauration : $error',
      name: 'localDatabaseRestoreService_failure',
      desc: '',
      args: [error],
    );
  }

  /// `Restauration effectuée mais integrity_check a retourné : {integrityStatus}`
  String localDatabaseRestoreService_integrity(Object integrityStatus) {
    return Intl.message(
      'Restauration effectuée mais integrity_check a retourné : $integrityStatus',
      name: 'localDatabaseRestoreService_integrity',
      desc: '',
      args: [integrityStatus],
    );
  }

  /// `Le fichier de sauvegarde est introuvable.`
  String get localDatabaseRestoreService_missing {
    return Intl.message(
      'Le fichier de sauvegarde est introuvable.',
      name: 'localDatabaseRestoreService_missing',
      desc: '',
      args: [],
    );
  }

  /// `Restauration effectuée avec succès.`
  String get localDatabaseRestoreService_success {
    return Intl.message(
      'Restauration effectuée avec succès.',
      name: 'localDatabaseRestoreService_success',
      desc: '',
      args: [],
    );
  }

  /// `Une seule instance peut être ouverte à la fois.\n\nUtilisez la fenêtre Companion déjà ouverte.`
  String get main_alreadyRunningMessage {
    return Intl.message(
      'Une seule instance peut être ouverte à la fois.\n\nUtilisez la fenêtre Companion déjà ouverte.',
      name: 'main_alreadyRunningMessage',
      desc: '',
      args: [],
    );
  }

  /// `ABAK Desktop Companion est déjà ouvert`
  String get main_alreadyRunningTitle {
    return Intl.message(
      'ABAK Desktop Companion est déjà ouvert',
      name: 'main_alreadyRunningTitle',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get main_close {
    return Intl.message(
      '',
      name: 'main_close',
      desc: '',
      args: [],
    );
  }

  /// `Modifier`
  String get modify {
    return Intl.message(
      'Modifier',
      name: 'modify',
      desc: '',
      args: [],
    );
  }

  /// `Aucun dossier défini`
  String get noDirectoryDefined {
    return Intl.message(
      'Aucun dossier défini',
      name: 'noDirectoryDefined',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Ouvrir`
  String get open {
    return Intl.message(
      'Ouvrir',
      name: 'open',
      desc: '',
      args: [],
    );
  }

  /// `Choisir un logo`
  String get organization_chooseLogo {
    return Intl.message(
      'Choisir un logo',
      name: 'organization_chooseLogo',
      desc: '',
      args: [],
    );
  }

  /// `Cet écran permet de renseigner le nom et les coordonnées de votre cabinet : adresse, code postal, ville, téléphone et adresse électronique.\n\nCliquez sur « Enregistrer les coordonnées » pour conserver vos modifications avant de quitter l’écran.\n\nVous pouvez également choisir une image sur votre ordinateur pour définir le logo du cabinet. Le choix du logo est enregistré immédiatement, indépendamment des coordonnées.\n\nLe bouton de suppression du logo permet de retirer le logo utilisé dans Companion.`
  String get organization_help {
    return Intl.message(
      'Cet écran permet de renseigner le nom et les coordonnées de votre cabinet : adresse, code postal, ville, téléphone et adresse électronique.\n\nCliquez sur « Enregistrer les coordonnées » pour conserver vos modifications avant de quitter l’écran.\n\nVous pouvez également choisir une image sur votre ordinateur pour définir le logo du cabinet. Le choix du logo est enregistré immédiatement, indépendamment des coordonnées.\n\nLe bouton de suppression du logo permet de retirer le logo utilisé dans Companion.',
      name: 'organization_help',
      desc: '',
      args: [],
    );
  }

  /// `Identité de l’établissement`
  String get organization_identityTitle {
    return Intl.message(
      'Identité de l’établissement',
      name: 'organization_identityTitle',
      desc: '',
      args: [],
    );
  }

  /// `Logo de l’établissement supprimé.`
  String get organization_logoRemoved {
    return Intl.message(
      'Logo de l’établissement supprimé.',
      name: 'organization_logoRemoved',
      desc: '',
      args: [],
    );
  }

  /// `Logo de l’établissement enregistré.`
  String get organization_logoSaved {
    return Intl.message(
      'Logo de l’établissement enregistré.',
      name: 'organization_logoSaved',
      desc: '',
      args: [],
    );
  }

  /// `Nom de l’établissement`
  String get organization_nameLabel {
    return Intl.message(
      'Nom de l’établissement',
      name: 'organization_nameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Nom de l’établissement enregistré.`
  String get organization_nameSaved {
    return Intl.message(
      'Nom de l’établissement enregistré.',
      name: 'organization_nameSaved',
      desc: '',
      args: [],
    );
  }

  /// `Supprimer le logo`
  String get organization_removeLogo {
    return Intl.message(
      'Supprimer le logo',
      name: 'organization_removeLogo',
      desc: '',
      args: [],
    );
  }

  /// `Enregistrer le nom`
  String get organization_saveName {
    return Intl.message(
      'Enregistrer le nom',
      name: 'organization_saveName',
      desc: '',
      args: [],
    );
  }

  /// `Établissement`
  String get organization_title {
    return Intl.message(
      'Établissement',
      name: 'organization_title',
      desc: '',
      args: [],
    );
  }

  /// `Associer un téléphone`
  String get pairPhone {
    return Intl.message(
      'Associer un téléphone',
      name: 'pairPhone',
      desc: '',
      args: [],
    );
  }

  /// `Cette fenêtre affiche les informations permettant à ABAK Mobile de trouver Companion sur le réseau local.\n\nConnectez le téléphone ou la tablette et l’ordinateur au même réseau local, puis scannez ce QR code depuis la fonction d’association à Companion dans ABAK Mobile.\n\nLe QR code contient l’adresse réseau et le port de communication de cet ordinateur. Ces informations sont également affichées sous le code.\n\nGardez Companion ouvert sur l’ordinateur lors des échanges. Si l’adresse réseau de l’ordinateur change, ouvrez à nouveau cette fenêtre et scannez le nouveau code.\n\nL’affichage de ce QR code ne déclenche pas à lui seul l’envoi de résultats.`
  String get pairPhone_help {
    return Intl.message(
      'Cette fenêtre affiche les informations permettant à ABAK Mobile de trouver Companion sur le réseau local.\n\nConnectez le téléphone ou la tablette et l’ordinateur au même réseau local, puis scannez ce QR code depuis la fonction d’association à Companion dans ABAK Mobile.\n\nLe QR code contient l’adresse réseau et le port de communication de cet ordinateur. Ces informations sont également affichées sous le code.\n\nGardez Companion ouvert sur l’ordinateur lors des échanges. Si l’adresse réseau de l’ordinateur change, ouvrez à nouveau cette fenêtre et scannez le nouveau code.\n\nL’affichage de ce QR code ne déclenche pas à lui seul l’envoi de résultats.',
      name: 'pairPhone_help',
      desc: '',
      args: [],
    );
  }

  /// `Associer un téléphone`
  String get pairPhoneDialogTitle {
    return Intl.message(
      'Associer un téléphone',
      name: 'pairPhoneDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Scannez ce QR code depuis ABAK Mobile pour configurer automatiquement la connexion au Desktop.`
  String get pairPhoneInstructions {
    return Intl.message(
      'Scannez ce QR code depuis ABAK Mobile pour configurer automatiquement la connexion au Desktop.',
      name: 'pairPhoneInstructions',
      desc: '',
      args: [],
    );
  }

  /// `Adresse`
  String get patientClinicalDataEdit_address {
    return Intl.message(
      'Adresse',
      name: 'patientClinicalDataEdit_address',
      desc: '',
      args: [],
    );
  }

  /// `Identité administrative`
  String get patientClinicalDataEdit_administrativeIdentity {
    return Intl.message(
      'Identité administrative',
      name: 'patientClinicalDataEdit_administrativeIdentity',
      desc: '',
      args: [],
    );
  }

  /// `Ambidextre`
  String get patientClinicalDataEdit_ambidextrous {
    return Intl.message(
      'Ambidextre',
      name: 'patientClinicalDataEdit_ambidextrous',
      desc: '',
      args: [],
    );
  }

  /// `En centimètres`
  String get patientClinicalDataEdit_centimeters {
    return Intl.message(
      'En centimètres',
      name: 'patientClinicalDataEdit_centimeters',
      desc: '',
      args: [],
    );
  }

  /// `Côté dominant`
  String get patientClinicalDataEdit_dominantSide {
    return Intl.message(
      'Côté dominant',
      name: 'patientClinicalDataEdit_dominantSide',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get patientClinicalDataEdit_email {
    return Intl.message(
      'Email',
      name: 'patientClinicalDataEdit_email',
      desc: '',
      args: [],
    );
  }

  /// `Pays du système de santé`
  String get patientClinicalDataEdit_healthSystemCountry {
    return Intl.message(
      'Pays du système de santé',
      name: 'patientClinicalDataEdit_healthSystemCountry',
      desc: '',
      args: [],
    );
  }

  /// `Taille`
  String get patientClinicalDataEdit_height {
    return Intl.message(
      'Taille',
      name: 'patientClinicalDataEdit_height',
      desc: '',
      args: [],
    );
  }

  /// `Cet écran permet de compléter les informations administratives et le profil du patient.\n\nVous pouvez renseigner son identifiant de santé, la source de son identité, son téléphone, son adresse électronique et son adresse postale.\n\nLe profil comprend le côté dominant, la profession, l’activité sportive, la taille en centimètres et le poids en kilogrammes.\n\nCliquez sur « Enregistrer » pour sauvegarder vos modifications et revenir à la fiche du patient. Revenir en arrière sans enregistrer abandonne les modifications.`
  String get patientClinicalDataEdit_help {
    return Intl.message(
      'Cet écran permet de compléter les informations administratives et le profil du patient.\n\nVous pouvez renseigner son identifiant de santé, la source de son identité, son téléphone, son adresse électronique et son adresse postale.\n\nLe profil comprend le côté dominant, la profession, l’activité sportive, la taille en centimètres et le poids en kilogrammes.\n\nCliquez sur « Enregistrer » pour sauvegarder vos modifications et revenir à la fiche du patient. Revenir en arrière sans enregistrer abandonne les modifications.',
      name: 'patientClinicalDataEdit_help',
      desc: '',
      args: [],
    );
  }

  /// `Source de l’identité`
  String get patientClinicalDataEdit_identitySource {
    return Intl.message(
      'Source de l’identité',
      name: 'patientClinicalDataEdit_identitySource',
      desc: '',
      args: [],
    );
  }

  /// `En kilogrammes`
  String get patientClinicalDataEdit_kilograms {
    return Intl.message(
      'En kilogrammes',
      name: 'patientClinicalDataEdit_kilograms',
      desc: '',
      args: [],
    );
  }

  /// `Gauche`
  String get patientClinicalDataEdit_left {
    return Intl.message(
      'Gauche',
      name: 'patientClinicalDataEdit_left',
      desc: '',
      args: [],
    );
  }

  /// `Saisie manuelle`
  String get patientClinicalDataEdit_manualEntry {
    return Intl.message(
      'Saisie manuelle',
      name: 'patientClinicalDataEdit_manualEntry',
      desc: '',
      args: [],
    );
  }

  /// `Identifiant national de santé`
  String get patientClinicalDataEdit_nationalHealthId {
    return Intl.message(
      'Identifiant national de santé',
      name: 'patientClinicalDataEdit_nationalHealthId',
      desc: '',
      args: [],
    );
  }

  /// `Exemple France : numéro de sécurité sociale`
  String get patientClinicalDataEdit_nationalHealthIdHelper {
    return Intl.message(
      'Exemple France : numéro de sécurité sociale',
      name: 'patientClinicalDataEdit_nationalHealthIdHelper',
      desc: '',
      args: [],
    );
  }

  /// `Profil patient`
  String get patientClinicalDataEdit_patientProfile {
    return Intl.message(
      'Profil patient',
      name: 'patientClinicalDataEdit_patientProfile',
      desc: '',
      args: [],
    );
  }

  /// `Téléphone`
  String get patientClinicalDataEdit_phone {
    return Intl.message(
      'Téléphone',
      name: 'patientClinicalDataEdit_phone',
      desc: '',
      args: [],
    );
  }

  /// `Profession`
  String get patientClinicalDataEdit_profession {
    return Intl.message(
      'Profession',
      name: 'patientClinicalDataEdit_profession',
      desc: '',
      args: [],
    );
  }

  /// `Droite`
  String get patientClinicalDataEdit_right {
    return Intl.message(
      'Droite',
      name: 'patientClinicalDataEdit_right',
      desc: '',
      args: [],
    );
  }

  /// `Enregistrer`
  String get patientClinicalDataEdit_save {
    return Intl.message(
      'Enregistrer',
      name: 'patientClinicalDataEdit_save',
      desc: '',
      args: [],
    );
  }

  /// `Activité sportive habituelle`
  String get patientClinicalDataEdit_sportActivity {
    return Intl.message(
      'Activité sportive habituelle',
      name: 'patientClinicalDataEdit_sportActivity',
      desc: '',
      args: [],
    );
  }

  /// `Modifier les données cliniques`
  String get patientClinicalDataEdit_title {
    return Intl.message(
      'Modifier les données cliniques',
      name: 'patientClinicalDataEdit_title',
      desc: '',
      args: [],
    );
  }

  /// `Non précisé`
  String get patientClinicalDataEdit_unspecified {
    return Intl.message(
      'Non précisé',
      name: 'patientClinicalDataEdit_unspecified',
      desc: '',
      args: [],
    );
  }

  /// `Carte Vitale`
  String get patientClinicalDataEdit_vitaleCard {
    return Intl.message(
      'Carte Vitale',
      name: 'patientClinicalDataEdit_vitaleCard',
      desc: '',
      args: [],
    );
  }

  /// `Poids`
  String get patientClinicalDataEdit_weight {
    return Intl.message(
      'Poids',
      name: 'patientClinicalDataEdit_weight',
      desc: '',
      args: [],
    );
  }

  /// `Adresse`
  String get patientDetail_address {
    return Intl.message(
      'Adresse',
      name: 'patientDetail_address',
      desc: '',
      args: [],
    );
  }

  /// `Identité administrative`
  String get patientDetail_administrativeIdentity {
    return Intl.message(
      'Identité administrative',
      name: 'patientDetail_administrativeIdentity',
      desc: '',
      args: [],
    );
  }

  /// `archivé`
  String get patientDetail_archived {
    return Intl.message(
      'archivé',
      name: 'patientDetail_archived',
      desc: '',
      args: [],
    );
  }

  /// `Né(e) le`
  String get patientDetail_bornOn {
    return Intl.message(
      'Né(e) le',
      name: 'patientDetail_bornOn',
      desc: '',
      args: [],
    );
  }

  /// `Annuler`
  String get patientDetail_cancel {
    return Intl.message(
      'Annuler',
      name: 'patientDetail_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Prise en charge ouverte en`
  String get patientDetail_careEpisodeOpenedIn {
    return Intl.message(
      'Prise en charge ouverte en',
      name: 'patientDetail_careEpisodeOpenedIn',
      desc: '',
      args: [],
    );
  }

  /// `Prises en charge`
  String get patientDetail_careEpisodes {
    return Intl.message(
      'Prises en charge',
      name: 'patientDetail_careEpisodes',
      desc: '',
      args: [],
    );
  }

  /// `Créer`
  String get patientDetail_create {
    return Intl.message(
      'Créer',
      name: 'patientDetail_create',
      desc: '',
      args: [],
    );
  }

  /// `Côté dominant`
  String get patientDetail_dominantSide {
    return Intl.message(
      'Côté dominant',
      name: 'patientDetail_dominantSide',
      desc: '',
      args: [],
    );
  }

  /// `Modifier`
  String get patientDetail_edit {
    return Intl.message(
      'Modifier',
      name: 'patientDetail_edit',
      desc: '',
      args: [],
    );
  }

  /// `Modifier la prise en charge`
  String get patientDetail_editCareEpisode {
    return Intl.message(
      'Modifier la prise en charge',
      name: 'patientDetail_editCareEpisode',
      desc: '',
      args: [],
    );
  }

  /// `Cette fenêtre permet de modifier les informations de la prise en charge du patient.\n\nVous pouvez corriger la pathologie ou le motif de la prise en charge, compléter le texte initial et choisir le praticien référent ainsi que le médecin prescripteur.\n\nLa pathologie doit être renseignée pour que les modifications soient enregistrées.\n\nCliquez sur « Enregistrer » pour valider les modifications. « Annuler » ferme la fenêtre sans les appliquer.\n\nL’ouverture et la fermeture de cette aide conservent votre saisie dans le formulaire.`
  String get patientDetail_editCareEpisodeHelp {
    return Intl.message(
      'Cette fenêtre permet de modifier les informations de la prise en charge du patient.\n\nVous pouvez corriger la pathologie ou le motif de la prise en charge, compléter le texte initial et choisir le praticien référent ainsi que le médecin prescripteur.\n\nLa pathologie doit être renseignée pour que les modifications soient enregistrées.\n\nCliquez sur « Enregistrer » pour valider les modifications. « Annuler » ferme la fenêtre sans les appliquer.\n\nL’ouverture et la fermeture de cette aide conservent votre saisie dans le formulaire.',
      name: 'patientDetail_editCareEpisodeHelp',
      desc: '',
      args: [],
    );
  }

  /// `Modifier les données cliniques`
  String get patientDetail_editClinicalData {
    return Intl.message(
      'Modifier les données cliniques',
      name: 'patientDetail_editClinicalData',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get patientDetail_email {
    return Intl.message(
      'Email',
      name: 'patientDetail_email',
      desc: '',
      args: [],
    );
  }

  /// `Erreur`
  String get patientDetail_error {
    return Intl.message(
      'Erreur',
      name: 'patientDetail_error',
      desc: '',
      args: [],
    );
  }

  /// `Identité de santé — France`
  String get patientDetail_frHealthIdentity {
    return Intl.message(
      'Identité de santé — France',
      name: 'patientDetail_frHealthIdentity',
      desc: '',
      args: [],
    );
  }

  /// `Pays système santé`
  String get patientDetail_healthSystemCountry {
    return Intl.message(
      'Pays système santé',
      name: 'patientDetail_healthSystemCountry',
      desc: '',
      args: [],
    );
  }

  /// `Taille`
  String get patientDetail_height {
    return Intl.message(
      'Taille',
      name: 'patientDetail_height',
      desc: '',
      args: [],
    );
  }

  /// `Source identité`
  String get patientDetail_identitySource {
    return Intl.message(
      'Source identité',
      name: 'patientDetail_identitySource',
      desc: '',
      args: [],
    );
  }

  /// `Compte rendu initial`
  String get patientDetail_initialReport {
    return Intl.message(
      'Compte rendu initial',
      name: 'patientDetail_initialReport',
      desc: '',
      args: [],
    );
  }

  /// `Identifiant national`
  String get patientDetail_nationalIdentifier {
    return Intl.message(
      'Identifiant national',
      name: 'patientDetail_nationalIdentifier',
      desc: '',
      args: [],
    );
  }

  /// `Nouvelle prise en charge`
  String get patientDetail_newCareEpisode {
    return Intl.message(
      'Nouvelle prise en charge',
      name: 'patientDetail_newCareEpisode',
      desc: '',
      args: [],
    );
  }

  /// `Cette fenêtre permet de créer une nouvelle prise en charge pour le patient sélectionné.\n\nRenseignez la pathologie ou le motif de la prise en charge. Cette information est nécessaire pour créer l’épisode.\n\nVous pouvez compléter le texte initial et sélectionner un praticien référent. Ces informations sont facultatives.\n\nCliquez sur « Créer » pour enregistrer l’épisode. « Annuler » ferme la fenêtre sans le créer.\n\nL’ouverture et la fermeture de cette aide conservent votre saisie dans le formulaire.`
  String get patientDetail_newCareEpisodeHelp {
    return Intl.message(
      'Cette fenêtre permet de créer une nouvelle prise en charge pour le patient sélectionné.\n\nRenseignez la pathologie ou le motif de la prise en charge. Cette information est nécessaire pour créer l’épisode.\n\nVous pouvez compléter le texte initial et sélectionner un praticien référent. Ces informations sont facultatives.\n\nCliquez sur « Créer » pour enregistrer l’épisode. « Annuler » ferme la fenêtre sans le créer.\n\nL’ouverture et la fermeture de cette aide conservent votre saisie dans le formulaire.',
      name: 'patientDetail_newCareEpisodeHelp',
      desc: '',
      args: [],
    );
  }

  /// `Non renseigné`
  String get patientDetail_noBirthdate {
    return Intl.message(
      'Non renseigné',
      name: 'patientDetail_noBirthdate',
      desc: '',
      args: [],
    );
  }

  /// `Aucune prise en charge créée pour ce patient.`
  String get patientDetail_noCareEpisode {
    return Intl.message(
      'Aucune prise en charge créée pour ce patient.',
      name: 'patientDetail_noCareEpisode',
      desc: '',
      args: [],
    );
  }

  /// `Non renseigné`
  String get patientDetail_notProvided {
    return Intl.message(
      'Non renseigné',
      name: 'patientDetail_notProvided',
      desc: '',
      args: [],
    );
  }

  /// `Non renseignée`
  String get patientDetail_notProvidedFemale {
    return Intl.message(
      'Non renseignée',
      name: 'patientDetail_notProvidedFemale',
      desc: '',
      args: [],
    );
  }

  /// `Pathologie`
  String get patientDetail_pathology {
    return Intl.message(
      'Pathologie',
      name: 'patientDetail_pathology',
      desc: '',
      args: [],
    );
  }

  /// `Informations patient`
  String get patientDetail_patientInformation {
    return Intl.message(
      'Informations patient',
      name: 'patientDetail_patientInformation',
      desc: '',
      args: [],
    );
  }

  /// `Profil patient`
  String get patientDetail_patientProfile {
    return Intl.message(
      'Profil patient',
      name: 'patientDetail_patientProfile',
      desc: '',
      args: [],
    );
  }

  /// `Téléphone`
  String get patientDetail_phone {
    return Intl.message(
      'Téléphone',
      name: 'patientDetail_phone',
      desc: '',
      args: [],
    );
  }

  /// `Profession`
  String get patientDetail_profession {
    return Intl.message(
      'Profession',
      name: 'patientDetail_profession',
      desc: '',
      args: [],
    );
  }

  /// `Provisoire`
  String get patientDetail_provisional {
    return Intl.message(
      'Provisoire',
      name: 'patientDetail_provisional',
      desc: '',
      args: [],
    );
  }

  /// `Identité à compléter`
  String get patientDetail_provisionalDescription {
    return Intl.message(
      'Identité à compléter',
      name: 'patientDetail_provisionalDescription',
      desc: '',
      args: [],
    );
  }

  /// `Qualifiée`
  String get patientDetail_qualified {
    return Intl.message(
      'Qualifiée',
      name: 'patientDetail_qualified',
      desc: '',
      args: [],
    );
  }

  /// `Identité conforme`
  String get patientDetail_qualifiedDescription {
    return Intl.message(
      'Identité conforme',
      name: 'patientDetail_qualifiedDescription',
      desc: '',
      args: [],
    );
  }

  /// `Kiné référent`
  String get patientDetail_referringPractitioner {
    return Intl.message(
      'Kiné référent',
      name: 'patientDetail_referringPractitioner',
      desc: '',
      args: [],
    );
  }

  /// `Récupérée`
  String get patientDetail_retrieved {
    return Intl.message(
      'Récupérée',
      name: 'patientDetail_retrieved',
      desc: '',
      args: [],
    );
  }

  /// `INS obtenue, identité à contrôler`
  String get patientDetail_retrievedDescription {
    return Intl.message(
      'INS obtenue, identité à contrôler',
      name: 'patientDetail_retrievedDescription',
      desc: '',
      args: [],
    );
  }

  /// `Enregistrer`
  String get patientDetail_save {
    return Intl.message(
      'Enregistrer',
      name: 'patientDetail_save',
      desc: '',
      args: [],
    );
  }

  /// `Sexe`
  String get patientDetail_sex {
    return Intl.message(
      'Sexe',
      name: 'patientDetail_sex',
      desc: '',
      args: [],
    );
  }

  /// `Activité sportive`
  String get patientDetail_sportActivity {
    return Intl.message(
      'Activité sportive',
      name: 'patientDetail_sportActivity',
      desc: '',
      args: [],
    );
  }

  /// `État`
  String get patientDetail_state {
    return Intl.message(
      'État',
      name: 'patientDetail_state',
      desc: '',
      args: [],
    );
  }

  /// `Statut`
  String get patientDetail_status {
    return Intl.message(
      'Statut',
      name: 'patientDetail_status',
      desc: '',
      args: [],
    );
  }

  /// `Validée`
  String get patientDetail_validated {
    return Intl.message(
      'Validée',
      name: 'patientDetail_validated',
      desc: '',
      args: [],
    );
  }

  /// `Identité contrôlée, INS à rechercher`
  String get patientDetail_validatedDescription {
    return Intl.message(
      'Identité contrôlée, INS à rechercher',
      name: 'patientDetail_validatedDescription',
      desc: '',
      args: [],
    );
  }

  /// `Poids`
  String get patientDetail_weight {
    return Intl.message(
      'Poids',
      name: 'patientDetail_weight',
      desc: '',
      args: [],
    );
  }

  /// `ans`
  String get patientDetail_years {
    return Intl.message(
      'ans',
      name: 'patientDetail_years',
      desc: '',
      args: [],
    );
  }

  /// `Cet écran permet de créer un patient dans ABAK Companion.\n\nSaisissez son nom et son prénom : ces deux informations sont obligatoires. Vous pouvez compléter sa date de naissance à l’aide du calendrier et renseigner son sexe.\n\nLe bouton de lecture de la carte Vitale permet de récupérer l’identité du patient lorsque le lecteur et le module de lecture sont disponibles. Si plusieurs bénéficiaires sont proposés, sélectionnez la personne concernée, puis vérifiez les informations affichées. La saisie manuelle reste possible.\n\nSi Companion détecte un patient déjà présent, vérifiez les informations proposées avant de poursuivre afin d’éviter un doublon. Un patient archivé peut être proposé à la restauration.\n\nCliquez sur « Créer le patient » pour enregistrer la fiche, ou sur « Annuler » pour quitter sans créer de patient.`
  String get patientNew_help {
    return Intl.message(
      'Cet écran permet de créer un patient dans ABAK Companion.\n\nSaisissez son nom et son prénom : ces deux informations sont obligatoires. Vous pouvez compléter sa date de naissance à l’aide du calendrier et renseigner son sexe.\n\nLe bouton de lecture de la carte Vitale permet de récupérer l’identité du patient lorsque le lecteur et le module de lecture sont disponibles. Si plusieurs bénéficiaires sont proposés, sélectionnez la personne concernée, puis vérifiez les informations affichées. La saisie manuelle reste possible.\n\nSi Companion détecte un patient déjà présent, vérifiez les informations proposées avant de poursuivre afin d’éviter un doublon. Un patient archivé peut être proposé à la restauration.\n\nCliquez sur « Créer le patient » pour enregistrer la fiche, ou sur « Annuler » pour quitter sans créer de patient.',
      name: 'patientNew_help',
      desc: '',
      args: [],
    );
  }

  /// `Date de naissance`
  String get patientForm_birthDate {
    return Intl.message(
      'Date de naissance',
      name: 'patientForm_birthDate',
      desc: '',
      args: [],
    );
  }

  /// `Annuler`
  String get patientForm_cancel {
    return Intl.message(
      'Annuler',
      name: 'patientForm_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Créer`
  String get patientForm_create {
    return Intl.message(
      'Créer',
      name: 'patientForm_create',
      desc: '',
      args: [],
    );
  }

  /// `Modifier le patient`
  String get patientForm_editPatient {
    return Intl.message(
      'Modifier le patient',
      name: 'patientForm_editPatient',
      desc: '',
      args: [],
    );
  }

  /// `Femme`
  String get patientForm_female {
    return Intl.message(
      'Femme',
      name: 'patientForm_female',
      desc: '',
      args: [],
    );
  }

  /// `Prénom`
  String get patientForm_firstName {
    return Intl.message(
      'Prénom',
      name: 'patientForm_firstName',
      desc: '',
      args: [],
    );
  }

  /// `Le prénom est obligatoire`
  String get patientForm_firstNameRequired {
    return Intl.message(
      'Le prénom est obligatoire',
      name: 'patientForm_firstNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Nom`
  String get patientForm_lastName {
    return Intl.message(
      'Nom',
      name: 'patientForm_lastName',
      desc: '',
      args: [],
    );
  }

  /// `Cette fenêtre permet de renseigner ou de corriger l’identité du patient.\n\nLe nom et le prénom sont obligatoires. Vous pouvez sélectionner la date de naissance dans le calendrier et renseigner le sexe, ou conserver la valeur « Non précisé ».\n\nCliquez sur « Enregistrer » pour valider les modifications. Si le formulaire est ouvert en mode création, le bouton « Créer » permet de créer la fiche.\n\n« Annuler » ferme la fenêtre sans appliquer les modifications. L’ouverture et la fermeture de cette aide conservent votre saisie dans le formulaire.`
  String get patientForm_help {
    return Intl.message(
      'Cette fenêtre permet de renseigner ou de corriger l’identité du patient.\n\nLe nom et le prénom sont obligatoires. Vous pouvez sélectionner la date de naissance dans le calendrier et renseigner le sexe, ou conserver la valeur « Non précisé ».\n\nCliquez sur « Enregistrer » pour valider les modifications. Si le formulaire est ouvert en mode création, le bouton « Créer » permet de créer la fiche.\n\n« Annuler » ferme la fenêtre sans appliquer les modifications. L’ouverture et la fermeture de cette aide conservent votre saisie dans le formulaire.',
      name: 'patientForm_help',
      desc: '',
      args: [],
    );
  }

  /// `Le nom est obligatoire`
  String get patientForm_lastNameRequired {
    return Intl.message(
      'Le nom est obligatoire',
      name: 'patientForm_lastNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Homme`
  String get patientForm_male {
    return Intl.message(
      'Homme',
      name: 'patientForm_male',
      desc: '',
      args: [],
    );
  }

  /// `Nouveau patient`
  String get patientForm_newPatient {
    return Intl.message(
      'Nouveau patient',
      name: 'patientForm_newPatient',
      desc: '',
      args: [],
    );
  }

  /// `Autre`
  String get patientForm_other {
    return Intl.message(
      'Autre',
      name: 'patientForm_other',
      desc: '',
      args: [],
    );
  }

  /// `Enregistrer`
  String get patientForm_save {
    return Intl.message(
      'Enregistrer',
      name: 'patientForm_save',
      desc: '',
      args: [],
    );
  }

  /// `Sexe`
  String get patientForm_sex {
    return Intl.message(
      'Sexe',
      name: 'patientForm_sex',
      desc: '',
      args: [],
    );
  }

  /// `Non précisé`
  String get patientForm_unspecified {
    return Intl.message(
      'Non précisé',
      name: 'patientForm_unspecified',
      desc: '',
      args: [],
    );
  }

  /// `Actifs`
  String get patientList_active {
    return Intl.message(
      'Actifs',
      name: 'patientList_active',
      desc: '',
      args: [],
    );
  }

  /// `Archiver`
  String get patientList_archive {
    return Intl.message(
      'Archiver',
      name: 'patientList_archive',
      desc: '',
      args: [],
    );
  }

  /// `Voulez-vous vraiment archiver {patientName} ? Il ne sera plus affiché dans la liste active.`
  String patientList_archiveConfirmation(Object patientName) {
    return Intl.message(
      'Voulez-vous vraiment archiver $patientName ? Il ne sera plus affiché dans la liste active.',
      name: 'patientList_archiveConfirmation',
      desc: '',
      args: [patientName],
    );
  }

  /// `Archivés`
  String get patientList_archived {
    return Intl.message(
      'Archivés',
      name: 'patientList_archived',
      desc: '',
      args: [],
    );
  }

  /// `Archivé le`
  String get patientList_archivedOn {
    return Intl.message(
      'Archivé le',
      name: 'patientList_archivedOn',
      desc: '',
      args: [],
    );
  }

  /// `Patient archivé`
  String get patientList_archivedPatient {
    return Intl.message(
      'Patient archivé',
      name: 'patientList_archivedPatient',
      desc: '',
      args: [],
    );
  }

  /// `La corbeille des patients est vide pour le moment.`
  String get patientList_archivedPatientsEmpty {
    return Intl.message(
      'La corbeille des patients est vide pour le moment.',
      name: 'patientList_archivedPatientsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `{patientName} archivé.`
  String patientList_archiveSuccess(Object patientName) {
    return Intl.message(
      '$patientName archivé.',
      name: 'patientList_archiveSuccess',
      desc: '',
      args: [patientName],
    );
  }

  /// `Archiver le patient`
  String get patientList_archiveTitle {
    return Intl.message(
      'Archiver le patient',
      name: 'patientList_archiveTitle',
      desc: '',
      args: [],
    );
  }

  /// `Né(e) le`
  String get patientList_bornOn {
    return Intl.message(
      'Né(e) le',
      name: 'patientList_bornOn',
      desc: '',
      args: [],
    );
  }

  /// `Annuler`
  String get patientList_cancel {
    return Intl.message(
      'Annuler',
      name: 'patientList_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Vous pouvez afficher la liste des patients actifs et ceux archivés`
  String get patientList_contextComment {
    return Intl.message(
      'Vous pouvez afficher la liste des patients actifs et ceux archivés',
      name: 'patientList_contextComment',
      desc: '',
      args: [],
    );
  }

  /// `Liste des patients`
  String get patientList_contextName {
    return Intl.message(
      'Liste des patients',
      name: 'patientList_contextName',
      desc: '',
      args: [],
    );
  }

  /// `Modifier`
  String get patientList_edit {
    return Intl.message(
      'Modifier',
      name: 'patientList_edit',
      desc: '',
      args: [],
    );
  }

  /// `Erreur : {error}`
  String patientList_error(Object error) {
    return Intl.message(
      'Erreur : $error',
      name: 'patientList_error',
      desc: '',
      args: [error],
    );
  }

  /// `Cet écran permet de retrouver vos patients et d’accéder à leur dossier.\n\nLes boutons « Actifs » et « Archivés » permettent de choisir la liste affichée. Le nombre indiqué correspond au total des patients de chaque catégorie.\n\nPour rechercher un patient dans la liste affichée, saisissez tout ou partie de son nom ou de son prénom dans le champ de recherche. Cliquez sur sa ligne pour ouvrir son dossier.\n\nLe bouton « Nouveau patient » ouvre l’écran de création d’un patient.\n\nPour un patient actif, l’icône crayon permet de modifier son identité. L’icône d’archivage permet de le retirer de la liste des patients actifs après confirmation.\n\nDans la liste des patients archivés, l’icône de restauration permet de remettre un patient dans la liste des actifs. Une aide spécifique, accessible près de la date d’archivage, précise les modalités de conservation.`
  String get patientList_help {
    return Intl.message(
      'Cet écran permet de retrouver vos patients et d’accéder à leur dossier.\n\nLes boutons « Actifs » et « Archivés » permettent de choisir la liste affichée. Le nombre indiqué correspond au total des patients de chaque catégorie.\n\nPour rechercher un patient dans la liste affichée, saisissez tout ou partie de son nom ou de son prénom dans le champ de recherche. Cliquez sur sa ligne pour ouvrir son dossier.\n\nLe bouton « Nouveau patient » ouvre l’écran de création d’un patient.\n\nPour un patient actif, l’icône crayon permet de modifier son identité. L’icône d’archivage permet de le retirer de la liste des patients actifs après confirmation.\n\nDans la liste des patients archivés, l’icône de restauration permet de remettre un patient dans la liste des actifs. Une aide spécifique, accessible près de la date d’archivage, précise les modalités de conservation.',
      name: 'patientList_help',
      desc: '',
      args: [],
    );
  }

  /// `Nouveau patient`
  String get patientList_newPatient {
    return Intl.message(
      'Nouveau patient',
      name: 'patientList_newPatient',
      desc: '',
      args: [],
    );
  }

  /// `Aucun patient archivé`
  String get patientList_noArchivedPatients {
    return Intl.message(
      'Aucun patient archivé',
      name: 'patientList_noArchivedPatients',
      desc: '',
      args: [],
    );
  }

  /// `Aucun patient trouvé`
  String get patientList_noPatientFound {
    return Intl.message(
      'Aucun patient trouvé',
      name: 'patientList_noPatientFound',
      desc: '',
      args: [],
    );
  }

  /// `Aucun patient enregistré`
  String get patientList_noRegisteredPatients {
    return Intl.message(
      'Aucun patient enregistré',
      name: 'patientList_noRegisteredPatients',
      desc: '',
      args: [],
    );
  }

  /// `Le fichier patient local est vide pour le moment.`
  String get patientList_patientFileEmpty {
    return Intl.message(
      'Le fichier patient local est vide pour le moment.',
      name: 'patientList_patientFileEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Restaurable jusqu’au`
  String get patientList_restorableUntil {
    return Intl.message(
      'Restaurable jusqu’au',
      name: 'patientList_restorableUntil',
      desc: '',
      args: [],
    );
  }

  /// `Restaurer`
  String get patientList_restore {
    return Intl.message(
      'Restaurer',
      name: 'patientList_restore',
      desc: '',
      args: [],
    );
  }

  /// `{patientName} restauré dans la liste active.`
  String patientList_restoreSuccess(Object patientName) {
    return Intl.message(
      '$patientName restauré dans la liste active.',
      name: 'patientList_restoreSuccess',
      desc: '',
      args: [patientName],
    );
  }

  /// `Rechercher un patient`
  String get patientList_searchPatient {
    return Intl.message(
      'Rechercher un patient',
      name: 'patientList_searchPatient',
      desc: '',
      args: [],
    );
  }

  /// `Sexe`
  String get patientList_sex {
    return Intl.message(
      'Sexe',
      name: 'patientList_sex',
      desc: '',
      args: [],
    );
  }

  /// `Liste des patients`
  String get patientList_title {
    return Intl.message(
      'Liste des patients',
      name: 'patientList_title',
      desc: '',
      args: [],
    );
  }

  /// `Correspondance archivée à vérifier`
  String get patientNew_archivedMatchToReview {
    return Intl.message(
      'Correspondance archivée à vérifier',
      name: 'patientNew_archivedMatchToReview',
      desc: '',
      args: [],
    );
  }

  /// `Un patient archivé ayant les mêmes nom, prénom et date de naissance existe déjà, mais ses informations administratives sont différentes.\n\nAucune restauration automatique ne sera effectuée. Vérifiez les dossiers avant de poursuivre.`
  String get patientNew_archivedMatchToReviewMessage {
    return Intl.message(
      'Un patient archivé ayant les mêmes nom, prénom et date de naissance existe déjà, mais ses informations administratives sont différentes.\n\nAucune restauration automatique ne sera effectuée. Vérifiez les dossiers avant de poursuivre.',
      name: 'patientNew_archivedMatchToReviewMessage',
      desc: '',
      args: [],
    );
  }

  /// `Patient trouvé dans les archives`
  String get patientNew_archivedPatientFound {
    return Intl.message(
      'Patient trouvé dans les archives',
      name: 'patientNew_archivedPatientFound',
      desc: '',
      args: [],
    );
  }

  /// `Cette Carte Vitale correspond au patient archivé :`
  String get patientNew_archivedPatientMatch {
    return Intl.message(
      'Cette Carte Vitale correspond au patient archivé :',
      name: 'patientNew_archivedPatientMatch',
      desc: '',
      args: [],
    );
  }

  /// `Rattacher`
  String get patientNew_attach {
    return Intl.message(
      'Rattacher',
      name: 'patientNew_attach',
      desc: '',
      args: [],
    );
  }

  /// `Impossible de rattacher la Carte Vitale`
  String get patientNew_attachVitaleError {
    return Intl.message(
      'Impossible de rattacher la Carte Vitale',
      name: 'patientNew_attachVitaleError',
      desc: '',
      args: [],
    );
  }

  /// `Voulez-vous rattacher les informations de la Carte Vitale à ce patient ?`
  String get patientNew_attachVitaleQuestion {
    return Intl.message(
      'Voulez-vous rattacher les informations de la Carte Vitale à ce patient ?',
      name: 'patientNew_attachVitaleQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Carte Vitale rattachée au patient {patientName}.`
  String patientNew_attachVitaleSuccess(Object patientName) {
    return Intl.message(
      'Carte Vitale rattachée au patient $patientName.',
      name: 'patientNew_attachVitaleSuccess',
      desc: '',
      args: [patientName],
    );
  }

  /// `Retour à la liste`
  String get patientNew_backToList {
    return Intl.message(
      'Retour à la liste',
      name: 'patientNew_backToList',
      desc: '',
      args: [],
    );
  }

  /// `Date de naissance`
  String get patientNew_birthDate {
    return Intl.message(
      'Date de naissance',
      name: 'patientNew_birthDate',
      desc: '',
      args: [],
    );
  }

  /// `Annuler`
  String get patientNew_cancel {
    return Intl.message(
      'Annuler',
      name: 'patientNew_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Choisir le patient`
  String get patientNew_choosePatient {
    return Intl.message(
      'Choisir le patient',
      name: 'patientNew_choosePatient',
      desc: '',
      args: [],
    );
  }

  /// `Fermer`
  String get patientNew_close {
    return Intl.message(
      'Fermer',
      name: 'patientNew_close',
      desc: '',
      args: [],
    );
  }

  /// `Cet écran permet la création d’un nouveau patient par saisie ou lecture de la Carte Vitale.`
  String get patientNew_contextComment {
    return Intl.message(
      'Cet écran permet la création d’un nouveau patient par saisie ou lecture de la Carte Vitale.',
      name: 'patientNew_contextComment',
      desc: '',
      args: [],
    );
  }

  /// `Nouveau patient`
  String get patientNew_contextName {
    return Intl.message(
      'Nouveau patient',
      name: 'patientNew_contextName',
      desc: '',
      args: [],
    );
  }

  /// `Erreur lors de la création du patient`
  String get patientNew_createError {
    return Intl.message(
      'Erreur lors de la création du patient',
      name: 'patientNew_createError',
      desc: '',
      args: [],
    );
  }

  /// `Créer le patient`
  String get patientNew_createPatient {
    return Intl.message(
      'Créer le patient',
      name: 'patientNew_createPatient',
      desc: '',
      args: [],
    );
  }

  /// `Création...`
  String get patientNew_creating {
    return Intl.message(
      'Création...',
      name: 'patientNew_creating',
      desc: '',
      args: [],
    );
  }

  /// `Télécharger`
  String get patientNew_download {
    return Intl.message(
      'Télécharger',
      name: 'patientNew_download',
      desc: '',
      args: [],
    );
  }

  /// `Patient déjà existant ?`
  String get patientNew_existingPatientTitle {
    return Intl.message(
      'Patient déjà existant ?',
      name: 'patientNew_existingPatientTitle',
      desc: '',
      args: [],
    );
  }

  /// `Féminin`
  String get patientNew_female {
    return Intl.message(
      'Féminin',
      name: 'patientNew_female',
      desc: '',
      args: [],
    );
  }

  /// `Prénom`
  String get patientNew_firstName {
    return Intl.message(
      'Prénom',
      name: 'patientNew_firstName',
      desc: '',
      args: [],
    );
  }

  /// `Le prénom est obligatoire`
  String get patientNew_firstNameRequired {
    return Intl.message(
      'Le prénom est obligatoire',
      name: 'patientNew_firstNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `La lecture de la carte Vitale proposée dans Companion concerne actuellement la France. Elle permet de récupérer des informations d’identité pour faciliter la création de la fiche patient.\n\nABAK Companion souhaite étendre cette démarche aux moyens d’identification utilisés dans d’autres pays. Les cartes, identifiants et services de santé y fonctionnent différemment : leur prise en charge n’est pas encore intégrée à Companion. La saisie manuelle reste disponible.\n\nNous souhaitons explorer ces possibilités avec les kinésithérapeutes qui utilisent ABAK. Vous souhaitez nous accompagner dans votre pays ? Votre connaissance des pratiques locales et votre participation aux essais nous aideront à définir une solution utile et adaptée.\n\nLes évolutions seront construites progressivement avec les praticiens volontaires, selon les besoins exprimés, les possibilités techniques et les autorisations nécessaires.`
  String get patientNew_identificationCountriesHelp {
    return Intl.message(
      'La lecture de la carte Vitale proposée dans Companion concerne actuellement la France. Elle permet de récupérer des informations d’identité pour faciliter la création de la fiche patient.\n\nABAK Companion souhaite étendre cette démarche aux moyens d’identification utilisés dans d’autres pays. Les cartes, identifiants et services de santé y fonctionnent différemment : leur prise en charge n’est pas encore intégrée à Companion. La saisie manuelle reste disponible.\n\nNous souhaitons explorer ces possibilités avec les kinésithérapeutes qui utilisent ABAK. Vous souhaitez nous accompagner dans votre pays ? Votre connaissance des pratiques locales et votre participation aux essais nous aideront à définir une solution utile et adaptée.\n\nLes évolutions seront construites progressivement avec les praticiens volontaires, selon les besoins exprimés, les possibilités techniques et les autorisations nécessaires.',
      name: 'patientNew_identificationCountriesHelp',
      desc: '',
      args: [],
    );
  }

  /// `Identification des patients selon les pays`
  String get patientNew_identificationCountriesTitle {
    return Intl.message(
      'Identification des patients selon les pays',
      name: 'patientNew_identificationCountriesTitle',
      desc: '',
      args: [],
    );
  }

  /// `Nom`
  String get patientNew_lastName {
    return Intl.message(
      'Nom',
      name: 'patientNew_lastName',
      desc: '',
      args: [],
    );
  }

  /// `Le nom est obligatoire`
  String get patientNew_lastNameRequired {
    return Intl.message(
      'Le nom est obligatoire',
      name: 'patientNew_lastNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Masculin`
  String get patientNew_male {
    return Intl.message(
      'Masculin',
      name: 'patientNew_male',
      desc: '',
      args: [],
    );
  }

  /// `Un patient correspondant a été trouvé :`
  String get patientNew_matchingPatientFound {
    return Intl.message(
      'Un patient correspondant a été trouvé :',
      name: 'patientNew_matchingPatientFound',
      desc: '',
      args: [],
    );
  }

  /// `Correspondance à vérifier`
  String get patientNew_matchToReview {
    return Intl.message(
      'Correspondance à vérifier',
      name: 'patientNew_matchToReview',
      desc: '',
      args: [],
    );
  }

  /// `Un patient ayant les mêmes nom, prénom et date de naissance existe déjà.\n\nLes informations administratives ne correspondent pas complètement. Vérifiez le dossier avant de poursuivre.`
  String get patientNew_matchToReviewMessage {
    return Intl.message(
      'Un patient ayant les mêmes nom, prénom et date de naissance existe déjà.\n\nLes informations administratives ne correspondent pas complètement. Vérifiez le dossier avant de poursuivre.',
      name: 'patientNew_matchToReviewMessage',
      desc: '',
      args: [],
    );
  }

  /// `NIR`
  String get patientNew_nir {
    return Intl.message(
      'NIR',
      name: 'patientNew_nir',
      desc: '',
      args: [],
    );
  }

  /// `détecté et protégé`
  String get patientNew_nirDetectedProtected {
    return Intl.message(
      'détecté et protégé',
      name: 'patientNew_nirDetectedProtected',
      desc: '',
      args: [],
    );
  }

  /// `non disponible`
  String get patientNew_nirUnavailable {
    return Intl.message(
      'non disponible',
      name: 'patientNew_nirUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Non`
  String get patientNew_no {
    return Intl.message(
      'Non',
      name: 'patientNew_no',
      desc: '',
      args: [],
    );
  }

  /// `Aucun nouveau patient ne sera créé.`
  String get patientNew_noNewPatientCreated {
    return Intl.message(
      'Aucun nouveau patient ne sera créé.',
      name: 'patientNew_noNewPatientCreated',
      desc: '',
      args: [],
    );
  }

  /// `Non renseigné`
  String get patientNew_notProvided {
    return Intl.message(
      'Non renseigné',
      name: 'patientNew_notProvided',
      desc: '',
      args: [],
    );
  }

  /// `non renseignée`
  String get patientNew_notProvidedFemale {
    return Intl.message(
      'non renseignée',
      name: 'patientNew_notProvidedFemale',
      desc: '',
      args: [],
    );
  }

  /// `Autre`
  String get patientNew_other {
    return Intl.message(
      'Autre',
      name: 'patientNew_other',
      desc: '',
      args: [],
    );
  }

  /// `Patient déjà enregistré`
  String get patientNew_patientAlreadyRegistered {
    return Intl.message(
      'Patient déjà enregistré',
      name: 'patientNew_patientAlreadyRegistered',
      desc: '',
      args: [],
    );
  }

  /// `Identité du patient`
  String get patientNew_patientIdentity {
    return Intl.message(
      'Identité du patient',
      name: 'patientNew_patientIdentity',
      desc: '',
      args: [],
    );
  }

  /// `Lecteur de Carte Vitale non détecté`
  String get patientNew_readerNotDetected {
    return Intl.message(
      'Lecteur de Carte Vitale non détecté',
      name: 'patientNew_readerNotDetected',
      desc: '',
      args: [],
    );
  }

  /// `ABAK Desktop Companion n’a détecté aucun lecteur de Carte Vitale.\n\nPour utiliser cette fonction, vous devez disposer :\n\n• d’un lecteur de Carte Vitale compatible PC/SC, généralement connecté en USB ;\n• du module ABAK Carte Vitale, fourni gratuitement. Voir le site abak.care.\n\nUne fois le lecteur connecté, cliquez de nouveau sur « Lire Carte Vitale ».`
  String get patientNew_readerNotDetectedMessage {
    return Intl.message(
      'ABAK Desktop Companion n’a détecté aucun lecteur de Carte Vitale.\n\nPour utiliser cette fonction, vous devez disposer :\n\n• d’un lecteur de Carte Vitale compatible PC/SC, généralement connecté en USB ;\n• du module ABAK Carte Vitale, fourni gratuitement. Voir le site abak.care.\n\nUne fois le lecteur connecté, cliquez de nouveau sur « Lire Carte Vitale ».',
      name: 'patientNew_readerNotDetectedMessage',
      desc: '',
      args: [],
    );
  }

  /// `Lecture en cours...`
  String get patientNew_reading {
    return Intl.message(
      'Lecture en cours...',
      name: 'patientNew_reading',
      desc: '',
      args: [],
    );
  }

  /// `Lecture effectuée le`
  String get patientNew_readOn {
    return Intl.message(
      'Lecture effectuée le',
      name: 'patientNew_readOn',
      desc: '',
      args: [],
    );
  }

  /// `Lire Carte Vitale`
  String get patientNew_readVitale {
    return Intl.message(
      'Lire Carte Vitale',
      name: 'patientNew_readVitale',
      desc: '',
      args: [],
    );
  }

  /// `Restaurer`
  String get patientNew_restore {
    return Intl.message(
      'Restaurer',
      name: 'patientNew_restore',
      desc: '',
      args: [],
    );
  }

  /// `Impossible de restaurer le patient`
  String get patientNew_restoreError {
    return Intl.message(
      'Impossible de restaurer le patient',
      name: 'patientNew_restoreError',
      desc: '',
      args: [],
    );
  }

  /// `Souhaitez-vous restaurer ce dossier plutôt que créer un nouveau patient ?`
  String get patientNew_restoreInsteadOfCreate {
    return Intl.message(
      'Souhaitez-vous restaurer ce dossier plutôt que créer un nouveau patient ?',
      name: 'patientNew_restoreInsteadOfCreate',
      desc: '',
      args: [],
    );
  }

  /// `Le patient {patientName} a été restauré.`
  String patientNew_restoreSuccess(Object patientName) {
    return Intl.message(
      'Le patient $patientName a été restauré.',
      name: 'patientNew_restoreSuccess',
      desc: '',
      args: [patientName],
    );
  }

  /// `Sexe`
  String get patientNew_sex {
    return Intl.message(
      'Sexe',
      name: 'patientNew_sex',
      desc: '',
      args: [],
    );
  }

  /// `Identité lue depuis la Carte Vitale`
  String get patientNew_vitaleIdentityRead {
    return Intl.message(
      'Identité lue depuis la Carte Vitale',
      name: 'patientNew_vitaleIdentityRead',
      desc: '',
      args: [],
    );
  }

  /// `Cette Carte Vitale correspond au patient :`
  String get patientNew_vitaleMatchesPatient {
    return Intl.message(
      'Cette Carte Vitale correspond au patient :',
      name: 'patientNew_vitaleMatchesPatient',
      desc: '',
      args: [],
    );
  }

  /// `La configuration du module Carte Vitale est absente ou incorrecte. Réinstallez le module puis réessayez.`
  String get patientNew_vitaleModuleConfigurationError {
    return Intl.message(
      'La configuration du module Carte Vitale est absente ou incorrecte. Réinstallez le module puis réessayez.',
      name: 'patientNew_vitaleModuleConfigurationError',
      desc: '',
      args: [],
    );
  }

  /// `Module Carte Vitale non installé`
  String get patientNew_vitaleModuleNotInstalled {
    return Intl.message(
      'Module Carte Vitale non installé',
      name: 'patientNew_vitaleModuleNotInstalled',
      desc: '',
      args: [],
    );
  }

  /// `Le module ABAK Carte Vitale n’est pas installé sur cet ordinateur.\n\nVous pouvez le télécharger gratuitement depuis le site ABAK.`
  String get patientNew_vitaleModuleNotInstalledMessage {
    return Intl.message(
      'Le module ABAK Carte Vitale n’est pas installé sur cet ordinateur.\n\nVous pouvez le télécharger gratuitement depuis le site ABAK.',
      name: 'patientNew_vitaleModuleNotInstalledMessage',
      desc: '',
      args: [],
    );
  }

  /// `Informations patient préremplies depuis la Carte Vitale.`
  String get patientNew_vitalePrefilled {
    return Intl.message(
      'Informations patient préremplies depuis la Carte Vitale.',
      name: 'patientNew_vitalePrefilled',
      desc: '',
      args: [],
    );
  }

  /// `La lecture de la Carte Vitale a échoué.`
  String get patientNew_vitaleReadFailed {
    return Intl.message(
      'La lecture de la Carte Vitale a échoué.',
      name: 'patientNew_vitaleReadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Actifs`
  String get practitionerList_active {
    return Intl.message(
      'Actifs',
      name: 'practitionerList_active',
      desc: '',
      args: [],
    );
  }

  /// `Ajoutez les kinés du cabinet pour identifier les tests importés.`
  String get practitionerList_addPractitionersHint {
    return Intl.message(
      'Ajoutez les kinés du cabinet pour identifier les tests importés.',
      name: 'practitionerList_addPractitionersHint',
      desc: '',
      args: [],
    );
  }

  /// `Archiver`
  String get practitionerList_archive {
    return Intl.message(
      'Archiver',
      name: 'practitionerList_archive',
      desc: '',
      args: [],
    );
  }

  /// `Voulez-vous vraiment archiver {practitionerName} ?`
  String practitionerList_archiveConfirmation(Object practitionerName) {
    return Intl.message(
      'Voulez-vous vraiment archiver $practitionerName ?',
      name: 'practitionerList_archiveConfirmation',
      desc: '',
      args: [practitionerName],
    );
  }

  /// `Archivés`
  String get practitionerList_archived {
    return Intl.message(
      'Archivés',
      name: 'practitionerList_archived',
      desc: '',
      args: [],
    );
  }

  /// `Archivé le {date}`
  String practitionerList_archivedOn(Object date) {
    return Intl.message(
      'Archivé le $date',
      name: 'practitionerList_archivedOn',
      desc: '',
      args: [date],
    );
  }

  /// `La corbeille des kinés est vide pour le moment.`
  String get practitionerList_archiveEmpty {
    return Intl.message(
      'La corbeille des kinés est vide pour le moment.',
      name: 'practitionerList_archiveEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Archiver le kiné`
  String get practitionerList_archivePractitioner {
    return Intl.message(
      'Archiver le kiné',
      name: 'practitionerList_archivePractitioner',
      desc: '',
      args: [],
    );
  }

  /// `Créer un praticien`
  String get practitionerList_button_create {
    return Intl.message(
      'Créer un praticien',
      name: 'practitionerList_button_create',
      desc: '',
      args: [],
    );
  }

  /// `Annuler`
  String get practitionerList_cancel {
    return Intl.message(
      'Annuler',
      name: 'practitionerList_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Cet écran affiche la liste des praticiens enregistrés.`
  String get practitionerList_contextComment {
    return Intl.message(
      'Cet écran affiche la liste des praticiens enregistrés.',
      name: 'practitionerList_contextComment',
      desc: '',
      args: [],
    );
  }

  /// `Liste des praticiens`
  String get practitionerList_contextName {
    return Intl.message(
      'Liste des praticiens',
      name: 'practitionerList_contextName',
      desc: '',
      args: [],
    );
  }

  /// `Modifier`
  String get practitionerList_edit {
    return Intl.message(
      'Modifier',
      name: 'practitionerList_edit',
      desc: '',
      args: [],
    );
  }

  /// `Erreur : {error}`
  String practitionerList_error(Object error) {
    return Intl.message(
      'Erreur : $error',
      name: 'practitionerList_error',
      desc: '',
      args: [error],
    );
  }

  /// `Aucun kiné archivé`
  String get practitionerList_noArchivedPractitioner {
    return Intl.message(
      'Aucun kiné archivé',
      name: 'practitionerList_noArchivedPractitioner',
      desc: '',
      args: [],
    );
  }

  /// `Aucun kiné enregistré`
  String get practitionerList_noPractitioner {
    return Intl.message(
      'Aucun kiné enregistré',
      name: 'practitionerList_noPractitioner',
      desc: '',
      args: [],
    );
  }

  /// `ID pro : {professionalId}`
  String practitionerList_professionalId(Object professionalId) {
    return Intl.message(
      'ID pro : $professionalId',
      name: 'practitionerList_professionalId',
      desc: '',
      args: [professionalId],
    );
  }

  /// `Restaurer`
  String get practitionerList_restore {
    return Intl.message(
      'Restaurer',
      name: 'practitionerList_restore',
      desc: '',
      args: [],
    );
  }

  /// `Afficher le QR Code`
  String get practitionerList_showQrCode {
    return Intl.message(
      'Afficher le QR Code',
      name: 'practitionerList_showQrCode',
      desc: '',
      args: [],
    );
  }

  /// `Liste des praticiens`
  String get practitionerList_title {
    return Intl.message(
      'Liste des praticiens',
      name: 'practitionerList_title',
      desc: '',
      args: [],
    );
  }

  /// `Annuler`
  String get practitionerNew_cancel {
    return Intl.message(
      'Annuler',
      name: 'practitionerNew_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Cet écran permet de créer un praticien.`
  String get practitionerNew_cet_ecran_permet {
    return Intl.message(
      'Cet écran permet de créer un praticien.',
      name: 'practitionerNew_cet_ecran_permet',
      desc: '',
      args: [],
    );
  }

  /// `Créer`
  String get practitionerNew_create {
    return Intl.message(
      'Créer',
      name: 'practitionerNew_create',
      desc: '',
      args: [],
    );
  }

  /// `Nom affiché`
  String get practitionerNew_displayName {
    return Intl.message(
      'Nom affiché',
      name: 'practitionerNew_displayName',
      desc: '',
      args: [],
    );
  }

  /// `Le nom affiché est obligatoire`
  String get practitionerNew_displayNameRequired {
    return Intl.message(
      'Le nom affiché est obligatoire',
      name: 'practitionerNew_displayNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Modifier le praticien`
  String get practitionerNew_editPractitioner {
    return Intl.message(
      'Modifier le praticien',
      name: 'practitionerNew_editPractitioner',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get practitionerNew_email {
    return Intl.message(
      'Email',
      name: 'practitionerNew_email',
      desc: '',
      args: [],
    );
  }

  /// `Prénom`
  String get practitionerNew_firstName {
    return Intl.message(
      'Prénom',
      name: 'practitionerNew_firstName',
      desc: '',
      args: [],
    );
  }

  /// `Cette fenêtre permet de créer ou de modifier la fiche d’un praticien.\n\nLe nom affiché est obligatoire : il permet d’identifier le praticien dans Companion. Vous pouvez également renseigner son prénom, son nom, son identifiant professionnel, son adresse électronique et son téléphone.\n\nCliquez sur « Créer » pour ajouter un praticien ou sur « Enregistrer » pour valider les modifications d’une fiche existante.\n\n« Annuler » ferme la fenêtre sans appliquer les modifications. L’ouverture et la fermeture de cette aide conservent votre saisie dans le formulaire.`
  String get practitionerNew_help {
    return Intl.message(
      'Cette fenêtre permet de créer ou de modifier la fiche d’un praticien.\n\nLe nom affiché est obligatoire : il permet d’identifier le praticien dans Companion. Vous pouvez également renseigner son prénom, son nom, son identifiant professionnel, son adresse électronique et son téléphone.\n\nCliquez sur « Créer » pour ajouter un praticien ou sur « Enregistrer » pour valider les modifications d’une fiche existante.\n\n« Annuler » ferme la fenêtre sans appliquer les modifications. L’ouverture et la fermeture de cette aide conservent votre saisie dans le formulaire.',
      name: 'practitionerNew_help',
      desc: '',
      args: [],
    );
  }

  /// `Nom`
  String get practitionerNew_lastName {
    return Intl.message(
      'Nom',
      name: 'practitionerNew_lastName',
      desc: '',
      args: [],
    );
  }

  /// `Nouveau praticien`
  String get practitionerNew_newPractitioner {
    return Intl.message(
      'Nouveau praticien',
      name: 'practitionerNew_newPractitioner',
      desc: '',
      args: [],
    );
  }

  /// `Téléphone`
  String get practitionerNew_phone {
    return Intl.message(
      'Téléphone',
      name: 'practitionerNew_phone',
      desc: '',
      args: [],
    );
  }

  /// `Identifiant professionnel`
  String get practitionerNew_professionalId {
    return Intl.message(
      'Identifiant professionnel',
      name: 'practitionerNew_professionalId',
      desc: '',
      args: [],
    );
  }

  /// `RPPS, ADELI…`
  String get practitionerNew_professionalIdHint {
    return Intl.message(
      'RPPS, ADELI…',
      name: 'practitionerNew_professionalIdHint',
      desc: '',
      args: [],
    );
  }

  /// `Enregistrer`
  String get practitionerNew_save {
    return Intl.message(
      'Enregistrer',
      name: 'practitionerNew_save',
      desc: '',
      args: [],
    );
  }

  /// `Fermer`
  String get practitionerQr_close {
    return Intl.message(
      'Fermer',
      name: 'practitionerQr_close',
      desc: '',
      args: [],
    );
  }

  /// `Cabinet`
  String get practitionerQr_defaultOrganizationName {
    return Intl.message(
      'Cabinet',
      name: 'practitionerQr_defaultOrganizationName',
      desc: '',
      args: [],
    );
  }

  /// `Cette fenêtre affiche le QR code du profil professionnel du praticien, accompagné de son nom et du nom du cabinet.\n\nScannez ce QR code depuis ABAK Mobile pour y identifier le praticien dans cet établissement. Vérifiez que le nom affiché correspond au professionnel concerné.\n\nCe QR code sert à transmettre les informations d’identification du profil professionnel ; son affichage ne déclenche pas de transfert de résultats.\n\nFermez cette fenêtre pour revenir à la liste des praticiens.`
  String get practitionerQr_help {
    return Intl.message(
      'Cette fenêtre affiche le QR code du profil professionnel du praticien, accompagné de son nom et du nom du cabinet.\n\nScannez ce QR code depuis ABAK Mobile pour y identifier le praticien dans cet établissement. Vérifiez que le nom affiché correspond au professionnel concerné.\n\nCe QR code sert à transmettre les informations d’identification du profil professionnel ; son affichage ne déclenche pas de transfert de résultats.\n\nFermez cette fenêtre pour revenir à la liste des praticiens.',
      name: 'practitionerQr_help',
      desc: '',
      args: [],
    );
  }

  /// `Profil professionnel ABAK`
  String get practitionerQr_professionalProfile {
    return Intl.message(
      'Profil professionnel ABAK',
      name: 'practitionerQr_professionalProfile',
      desc: '',
      args: [],
    );
  }

  /// `Scannez ce QR Code depuis ABAK Mobile afin d'ajouter automatiquement ce profil professionnel.`
  String get practitionerQr_scanQrCodeInstruction {
    return Intl.message(
      'Scannez ce QR Code depuis ABAK Mobile afin d\'ajouter automatiquement ce profil professionnel.',
      name: 'practitionerQr_scanQrCodeInstruction',
      desc: '',
      args: [],
    );
  }

  /// `archivé`
  String get practitionerSelector_archived {
    return Intl.message(
      'archivé',
      name: 'practitionerSelector_archived',
      desc: '',
      args: [],
    );
  }

  /// `Erreur : {error}`
  String practitionerSelector_error(Object error) {
    return Intl.message(
      'Erreur : $error',
      name: 'practitionerSelector_error',
      desc: '',
      args: [error],
    );
  }

  /// `Aucune sélection`
  String get practitionerSelector_noSelection {
    return Intl.message(
      'Aucune sélection',
      name: 'practitionerSelector_noSelection',
      desc: '',
      args: [],
    );
  }

  /// `Patients archivés`
  String get preferences_archivedPatients {
    return Intl.message(
      'Patients archivés',
      name: 'preferences_archivedPatients',
      desc: '',
      args: [],
    );
  }

  /// `Cet écran centralise les paramètres généraux de Companion.`
  String get preferences_contextComment {
    return Intl.message(
      'Cet écran centralise les paramètres généraux de Companion.',
      name: 'preferences_contextComment',
      desc: '',
      args: [],
    );
  }

  /// `Paramètres utilisateur`
  String get preferences_contextName {
    return Intl.message(
      'Paramètres utilisateur',
      name: 'preferences_contextName',
      desc: '',
      args: [],
    );
  }

  /// `jours`
  String get preferences_days {
    return Intl.message(
      'jours',
      name: 'preferences_days',
      desc: '',
      args: [],
    );
  }

  /// `Mode Expert`
  String get preferences_expertMode {
    return Intl.message(
      'Mode Expert',
      name: 'preferences_expertMode',
      desc: '',
      args: [],
    );
  }

  /// `Affiche des informations techniques destinées aux développeurs et aux contributeurs.`
  String get preferences_expertModeDescription {
    return Intl.message(
      'Affiche des informations techniques destinées aux développeurs et aux contributeurs.',
      name: 'preferences_expertModeDescription',
      desc: '',
      args: [],
    );
  }

  /// `Paramètre du mode Expert enregistré.`
  String get preferences_expertModeSaved {
    return Intl.message(
      'Paramètre du mode Expert enregistré.',
      name: 'preferences_expertModeSaved',
      desc: '',
      args: [],
    );
  }

  /// `Langue enregistrée.`
  String get preferences_languageSaved {
    return Intl.message(
      'Langue enregistrée.',
      name: 'preferences_languageSaved',
      desc: '',
      args: [],
    );
  }

  /// `Établissement`
  String get preferences_organization {
    return Intl.message(
      'Établissement',
      name: 'preferences_organization',
      desc: '',
      args: [],
    );
  }

  /// `Nom, logo et informations générales.`
  String get preferences_organizationDescription {
    return Intl.message(
      'Nom, logo et informations générales.',
      name: 'preferences_organizationDescription',
      desc: '',
      args: [],
    );
  }

  /// `Durée de conservation`
  String get preferences_retentionDuration {
    return Intl.message(
      'Durée de conservation',
      name: 'preferences_retentionDuration',
      desc: '',
      args: [],
    );
  }

  /// `Les patients archivés peuvent être restaurés pendant cette durée. Ils seront ensuite supprimés automatiquement.`
  String get preferences_retentionExplanation {
    return Intl.message(
      'Les patients archivés peuvent être restaurés pendant cette durée. Ils seront ensuite supprimés automatiquement.',
      name: 'preferences_retentionExplanation',
      desc: '',
      args: [],
    );
  }

  /// `Durée de conservation enregistrée.`
  String get preferences_retentionSaved {
    return Intl.message(
      'Durée de conservation enregistrée.',
      name: 'preferences_retentionSaved',
      desc: '',
      args: [],
    );
  }

  /// `conflit`
  String get recentImportCard_conflict {
    return Intl.message(
      'conflit',
      name: 'recentImportCard_conflict',
      desc: '',
      args: [],
    );
  }

  /// `erreur`
  String get recentImportCard_error {
    return Intl.message(
      'erreur',
      name: 'recentImportCard_error',
      desc: '',
      args: [],
    );
  }

  /// `fichier`
  String get recentImportCard_fichier {
    return Intl.message(
      'fichier',
      name: 'recentImportCard_fichier',
      desc: '',
      args: [],
    );
  }

  /// `fichier`
  String get recentImportCard_file {
    return Intl.message(
      'fichier',
      name: 'recentImportCard_file',
      desc: '',
      args: [],
    );
  }

  /// `ignoré`
  String get recentImportCard_ignored {
    return Intl.message(
      'ignoré',
      name: 'recentImportCard_ignored',
      desc: '',
      args: [],
    );
  }

  /// `Aucun résultat importé`
  String get recentImportCard_no_result_imported {
    return Intl.message(
      'Aucun résultat importé',
      name: 'recentImportCard_no_result_imported',
      desc: '',
      args: [],
    );
  }

  /// `résultat`
  String get recentImportCard_result {
    return Intl.message(
      'résultat',
      name: 'recentImportCard_result',
      desc: '',
      args: [],
    );
  }

  /// `Depuis le {start}`
  String referringPractitionerHistoryDialog_since(Object start) {
    return Intl.message(
      'Depuis le $start',
      name: 'referringPractitionerHistoryDialog_since',
      desc: '',
      args: [start],
    );
  }

  /// `Du {start} au {end}`
  String referringPractitionerHistoryDialog_fromTo(Object start, Object end) {
    return Intl.message(
      'Du $start au $end',
      name: 'referringPractitionerHistoryDialog_fromTo',
      desc: '',
      args: [start, end],
    );
  }

  /// `Erreur lors du chargement de l’historique : {error}`
  String referringPractitionerHistoryDialog_loadHistoryError(Object error) {
    return Intl.message(
      'Erreur lors du chargement de l’historique : $error',
      name: 'referringPractitionerHistoryDialog_loadHistoryError',
      desc: '',
      args: [error],
    );
  }

  /// `Aucun kiné référent n’a encore été enregistré pour cet épisode.`
  String get referringPractitionerHistoryDialog_noHistory {
    return Intl.message(
      'Aucun kiné référent n’a encore été enregistré pour cet épisode.',
      name: 'referringPractitionerHistoryDialog_noHistory',
      desc: '',
      args: [],
    );
  }

  /// `{name} — archivé`
  String referringPractitionerHistoryDialog_archivedPractitioner(Object name) {
    return Intl.message(
      '$name — archivé',
      name: 'referringPractitionerHistoryDialog_archivedPractitioner',
      desc: '',
      args: [name],
    );
  }

  /// `Référent actuel`
  String get referringPractitionerHistoryDialog_currentPractitioner {
    return Intl.message(
      'Référent actuel',
      name: 'referringPractitionerHistoryDialog_currentPractitioner',
      desc: '',
      args: [],
    );
  }

  /// `Fermer`
  String get referringPractitionerHistoryDialog_close {
    return Intl.message(
      'Fermer',
      name: 'referringPractitionerHistoryDialog_close',
      desc: '',
      args: [],
    );
  }

  /// `Historique des kinés référents`
  String get referringPractitionerHistory_title {
    return Intl.message(
      'Historique des kinés référents',
      name: 'referringPractitionerHistory_title',
      desc: '',
      args: [],
    );
  }

  /// `Cette fenêtre présente les praticiens qui ont été désignés comme référents pour cet épisode de soins.\n\nChaque ligne indique le nom du praticien et sa période d’affectation. La mention « Référent actuel » identifie le praticien actuellement associé à l’épisode.\n\nLa mention « archivé » signifie que la fiche du praticien est archivée ; son nom reste visible dans l’historique.\n\nCette fenêtre permet uniquement de consulter l’historique. Fermez-la pour revenir à l’épisode de soins.`
  String get referringPractitionerHistory_help {
    return Intl.message(
      'Cette fenêtre présente les praticiens qui ont été désignés comme référents pour cet épisode de soins.\n\nChaque ligne indique le nom du praticien et sa période d’affectation. La mention « Référent actuel » identifie le praticien actuellement associé à l’épisode.\n\nLa mention « archivé » signifie que la fiche du praticien est archivée ; son nom reste visible dans l’historique.\n\nCette fenêtre permet uniquement de consulter l’historique. Fermez-la pour revenir à l’épisode de soins.',
      name: 'referringPractitionerHistory_help',
      desc: '',
      args: [],
    );
  }

  /// `Actualiser le tableau de bord`
  String get refreshDashboard {
    return Intl.message(
      'Actualiser le tableau de bord',
      name: 'refreshDashboard',
      desc: '',
      args: [],
    );
  }

  /// `Archives des rapports`
  String get reportArchive_title {
    return Intl.message(
      'Archives des rapports',
      name: 'reportArchive_title',
      desc: '',
      args: [],
    );
  }

  /// `Comprendre le brouillon du rapport`
  String get reportDraft_helpTitle {
    return Intl.message(
      'Comprendre le brouillon du rapport',
      name: 'reportDraft_helpTitle',
      desc: '',
      args: [],
    );
  }

  /// `Cette vue présente les rapports enregistrés pour la prise en charge, avec leur titre et leur date.\n\nLes actions de chaque ligne permettent de modifier un rapport, de le dupliquer ou de le déplacer vers les documents archivés.\n\nLorsqu’un rapport est ouvert en modification, utilisez l’action de mise à jour pour enregistrer vos changements. Les commandes disponibles permettent également d’annuler les modifications ou de revenir au brouillon.\n\nLe déplacement vers les documents archivés n’est pas une suppression définitive.\n\nCliquez sur la croix pour fermer la vue agrandie et revenir à l’espace Bilans/Rapports.`
  String get reportHistory_help {
    return Intl.message(
      'Cette vue présente les rapports enregistrés pour la prise en charge, avec leur titre et leur date.\n\nLes actions de chaque ligne permettent de modifier un rapport, de le dupliquer ou de le déplacer vers les documents archivés.\n\nLorsqu’un rapport est ouvert en modification, utilisez l’action de mise à jour pour enregistrer vos changements. Les commandes disponibles permettent également d’annuler les modifications ou de revenir au brouillon.\n\nLe déplacement vers les documents archivés n’est pas une suppression définitive.\n\nCliquez sur la croix pour fermer la vue agrandie et revenir à l’espace Bilans/Rapports.',
      name: 'reportHistory_help',
      desc: '',
      args: [],
    );
  }

  /// `Réinitialiser`
  String get reset {
    return Intl.message(
      'Réinitialiser',
      name: 'reset',
      desc: '',
      args: [],
    );
  }

  /// `Ajouter un commentaire...`
  String get resultDetail_addCommentHint {
    return Intl.message(
      'Ajouter un commentaire...',
      name: 'resultDetail_addCommentHint',
      desc: '',
      args: [],
    );
  }

  /// `Voulez-vous vraiment archiver ce résultat ?`
  String get resultDetail_archiveConfirmation {
    return Intl.message(
      'Voulez-vous vraiment archiver ce résultat ?',
      name: 'resultDetail_archiveConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Archiver le résultat`
  String get resultDetail_archiveTitle {
    return Intl.message(
      'Archiver le résultat',
      name: 'resultDetail_archiveTitle',
      desc: '',
      args: [],
    );
  }

  /// `Naissance`
  String get resultDetail_birthDate {
    return Intl.message(
      'Naissance',
      name: 'resultDetail_birthDate',
      desc: '',
      args: [],
    );
  }

  /// `Appareil`
  String get resultDetail_cancel {
    return Intl.message(
      'Appareil',
      name: 'resultDetail_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Commentaire clinique`
  String get resultDetail_clinicalComment {
    return Intl.message(
      'Commentaire clinique',
      name: 'resultDetail_clinicalComment',
      desc: '',
      args: [],
    );
  }

  /// `Commentaire enregistré`
  String get resultDetail_commentSaved {
    return Intl.message(
      'Commentaire enregistré',
      name: 'resultDetail_commentSaved',
      desc: '',
      args: [],
    );
  }

  /// `Résultat détaillé`
  String get resultDetail_detailedResult {
    return Intl.message(
      'Résultat détaillé',
      name: 'resultDetail_detailedResult',
      desc: '',
      args: [],
    );
  }

  /// `Détail de l'appareil`
  String get resultDetail_device {
    return Intl.message(
      'Détail de l\'appareil',
      name: 'resultDetail_device',
      desc: '',
      args: [],
    );
  }

  /// `Date de l'exercice`
  String get resultDetail_exerciseDate {
    return Intl.message(
      'Date de l\'exercice',
      name: 'resultDetail_exerciseDate',
      desc: '',
      args: [],
    );
  }

  /// `Cet écran présente les informations d’un résultat importé depuis ABAK Mobile : patient, date de réalisation, score et, lorsqu’elles sont disponibles, aide utilisée, identité du praticien et appareil d’origine.\n\nVous pouvez consulter le compte rendu détaillé et les mesures complémentaires transmises par l’exercice.\n\nLa zone « Commentaire clinique » permet d’ajouter ou de modifier vos observations. Cliquez sur « Enregistrer » pour les conserver avant de quitter l’écran.\n\nLa rubrique consacrée à l’import indique l’état de synchronisation et la date de dernière modification du résultat.\n\nL’icône d’archivage permet d’archiver ce résultat après confirmation.`
  String get resultDetail_help {
    return Intl.message(
      'Cet écran présente les informations d’un résultat importé depuis ABAK Mobile : patient, date de réalisation, score et, lorsqu’elles sont disponibles, aide utilisée, identité du praticien et appareil d’origine.\n\nVous pouvez consulter le compte rendu détaillé et les mesures complémentaires transmises par l’exercice.\n\nLa zone « Commentaire clinique » permet d’ajouter ou de modifier vos observations. Cliquez sur « Enregistrer » pour les conserver avant de quitter l’écran.\n\nLa rubrique consacrée à l’import indique l’état de synchronisation et la date de dernière modification du résultat.\n\nL’icône d’archivage permet d’archiver ce résultat après confirmation.',
      name: 'resultDetail_help',
      desc: '',
      args: [],
    );
  }

  /// `Informations générales`
  String get resultDetail_generalInformation {
    return Intl.message(
      'Informations générales',
      name: 'resultDetail_generalInformation',
      desc: '',
      args: [],
    );
  }

  /// `Identité non vérifiée`
  String get resultDetail_identityUnverified {
    return Intl.message(
      'Identité non vérifiée',
      name: 'resultDetail_identityUnverified',
      desc: '',
      args: [],
    );
  }

  /// `Identité vérifiée`
  String get resultDetail_identityVerified {
    return Intl.message(
      'Identité vérifiée',
      name: 'resultDetail_identityVerified',
      desc: '',
      args: [],
    );
  }

  /// `Import`
  String get resultDetail_import {
    return Intl.message(
      'Import',
      name: 'resultDetail_import',
      desc: '',
      args: [],
    );
  }

  /// `Dernière modification`
  String get resultDetail_lastModified {
    return Intl.message(
      'Dernière modification',
      name: 'resultDetail_lastModified',
      desc: '',
      args: [],
    );
  }

  /// `Métriques`
  String get resultDetail_metrics {
    return Intl.message(
      'Métriques',
      name: 'resultDetail_metrics',
      desc: '',
      args: [],
    );
  }

  /// `Aucune métrique enregistrée.`
  String get resultDetail_noMetrics {
    return Intl.message(
      'Aucune métrique enregistrée.',
      name: 'resultDetail_noMetrics',
      desc: '',
      args: [],
    );
  }

  /// `Patient`
  String get resultDetail_patient {
    return Intl.message(
      'Patient',
      name: 'resultDetail_patient',
      desc: '',
      args: [],
    );
  }

  /// `Réalisé par`
  String get resultDetail_performedBy {
    return Intl.message(
      'Réalisé par',
      name: 'resultDetail_performedBy',
      desc: '',
      args: [],
    );
  }

  /// `Enregistrer`
  String get resultDetail_save {
    return Intl.message(
      'Enregistrer',
      name: 'resultDetail_save',
      desc: '',
      args: [],
    );
  }

  /// `Score`
  String get resultDetail_score {
    return Intl.message(
      'Score',
      name: 'resultDetail_score',
      desc: '',
      args: [],
    );
  }

  /// `État sync`
  String get resultDetail_syncState {
    return Intl.message(
      'État sync',
      name: 'resultDetail_syncState',
      desc: '',
      args: [],
    );
  }

  /// `Le texte affiché correspond à un travail en cours sauvegardé automatiquement. Vous pouvez le conserver, le modifier ou le supprimer avant d’enregistrer votre rapport.`
  String get reportDraft_help {
    return Intl.message(
      'Le texte affiché correspond à un travail en cours sauvegardé automatiquement. Vous pouvez le conserver, le modifier ou le supprimer avant d’enregistrer votre rapport.',
      name: 'reportDraft_help',
      desc: '',
      args: [],
    );
  }

  /// `Ces fonctions sont destinées à l’installation, au diagnostic et aux opérations d’assistance technique.\n\nUtilisez-les uniquement lorsqu’un technicien ou la documentation ABAK vous le demande.`
  String get settings_assistanceWarning {
    return Intl.message(
      'Ces fonctions sont destinées à l’installation, au diagnostic et aux opérations d’assistance technique.\n\nUtilisez-les uniquement lorsqu’un technicien ou la documentation ABAK vous le demande.',
      name: 'settings_assistanceWarning',
      desc: '',
      args: [],
    );
  }

  /// `Annuler`
  String get settings_cancel {
    return Intl.message(
      'Annuler',
      name: 'settings_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Configuration`
  String get settings_configuration {
    return Intl.message(
      'Configuration',
      name: 'settings_configuration',
      desc: '',
      args: [],
    );
  }

  /// `Confirmation obligatoire`
  String get settings_confirmationRequired {
    return Intl.message(
      'Confirmation obligatoire',
      name: 'settings_confirmationRequired',
      desc: '',
      args: [],
    );
  }

  /// `Cet écran regroupe les fonctions d’installation, de diagnostic et de maintenance de Companion.`
  String get settings_contextComment {
    return Intl.message(
      'Cet écran regroupe les fonctions d’installation, de diagnostic et de maintenance de Companion.',
      name: 'settings_contextComment',
      desc: '',
      args: [],
    );
  }

  /// `Assistance`
  String get settings_contextName {
    return Intl.message(
      'Assistance',
      name: 'settings_contextName',
      desc: '',
      args: [],
    );
  }

  /// `Continuer`
  String get settings_continue {
    return Intl.message(
      'Continuer',
      name: 'settings_continue',
      desc: '',
      args: [],
    );
  }

  /// `Erreur lors de la réinitialisation : {error}`
  String settings_databaseResetError(Object error) {
    return Intl.message(
      'Erreur lors de la réinitialisation : $error',
      name: 'settings_databaseResetError',
      desc: '',
      args: [error],
    );
  }

  /// `Base réinitialisée. Sauvegarde automatique créée.`
  String get settings_databaseResetSuccess {
    return Intl.message(
      'Base réinitialisée. Sauvegarde automatique créée.',
      name: 'settings_databaseResetSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Diagnostic`
  String get settings_diagnostic {
    return Intl.message(
      'Diagnostic',
      name: 'settings_diagnostic',
      desc: '',
      args: [],
    );
  }

  /// `Modifier`
  String get settings_edit {
    return Intl.message(
      'Modifier',
      name: 'settings_edit',
      desc: '',
      args: [],
    );
  }

  /// `Dossier d’échange ABAK`
  String get settings_exchangeDirectory {
    return Intl.message(
      'Dossier d’échange ABAK',
      name: 'settings_exchangeDirectory',
      desc: '',
      args: [],
    );
  }

  /// `Dossier d’échange réinitialisé`
  String get settings_exchangeDirectoryReset {
    return Intl.message(
      'Dossier d’échange réinitialisé',
      name: 'settings_exchangeDirectoryReset',
      desc: '',
      args: [],
    );
  }

  /// `Dossier d’échange ABAK mis à jour`
  String get settings_exchangeDirectoryUpdated {
    return Intl.message(
      'Dossier d’échange ABAK mis à jour',
      name: 'settings_exchangeDirectoryUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Cet écran regroupe les fonctions d’installation, de diagnostic et de maintenance de Companion. Utilisez-les selon les indications de la documentation ABAK ou d’un technicien.\n\nLa rubrique « Configuration » permet de consulter, ouvrir ou modifier le dossier utilisé pour les échanges de fichiers.\n\nLa rubrique « Diagnostic » donne accès aux vérifications du dispositif de lecture de la carte Vitale.\n\nLa rubrique « Maintenance » permet d’ouvrir l’assistant de résolution des imports, d’importer manuellement un fichier ABAK et d’accéder à la gestion des sauvegardes.\n\nLa réinitialisation de la base supprime les données locales. Cette opération est réservée aux situations d’assistance technique : lisez attentivement les messages de confirmation avant de poursuivre.`
  String get settings_help {
    return Intl.message(
      'Cet écran regroupe les fonctions d’installation, de diagnostic et de maintenance de Companion. Utilisez-les selon les indications de la documentation ABAK ou d’un technicien.\n\nLa rubrique « Configuration » permet de consulter, ouvrir ou modifier le dossier utilisé pour les échanges de fichiers.\n\nLa rubrique « Diagnostic » donne accès aux vérifications du dispositif de lecture de la carte Vitale.\n\nLa rubrique « Maintenance » permet d’ouvrir l’assistant de résolution des imports, d’importer manuellement un fichier ABAK et d’accéder à la gestion des sauvegardes.\n\nLa réinitialisation de la base supprime les données locales. Cette opération est réservée aux situations d’assistance technique : lisez attentivement les messages de confirmation avant de poursuivre.',
      name: 'settings_help',
      desc: '',
      args: [],
    );
  }

  /// `Importer manuellement un fichier .abak`
  String get settings_importAbakFile {
    return Intl.message(
      'Importer manuellement un fichier .abak',
      name: 'settings_importAbakFile',
      desc: '',
      args: [],
    );
  }

  /// `Confirmation invalide.`
  String get settings_invalidConfirmation {
    return Intl.message(
      'Confirmation invalide.',
      name: 'settings_invalidConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Chargement...`
  String get settings_loading {
    return Intl.message(
      'Chargement...',
      name: 'settings_loading',
      desc: '',
      args: [],
    );
  }

  /// `Maintenance`
  String get settings_maintenance {
    return Intl.message(
      'Maintenance',
      name: 'settings_maintenance',
      desc: '',
      args: [],
    );
  }

  /// `Gérer les sauvegardes`
  String get settings_manageBackups {
    return Intl.message(
      'Gérer les sauvegardes',
      name: 'settings_manageBackups',
      desc: '',
      args: [],
    );
  }

  /// `Aucun dossier défini`
  String get settings_noDirectoryDefined {
    return Intl.message(
      'Aucun dossier défini',
      name: 'settings_noDirectoryDefined',
      desc: '',
      args: [],
    );
  }

  /// `Ouvrir`
  String get settings_open {
    return Intl.message(
      'Ouvrir',
      name: 'settings_open',
      desc: '',
      args: [],
    );
  }

  /// `Ouverture du dossier d’échange`
  String get settings_openingExchangeDirectory {
    return Intl.message(
      'Ouverture du dossier d’échange',
      name: 'settings_openingExchangeDirectory',
      desc: '',
      args: [],
    );
  }

  /// `Réinitialiser`
  String get settings_reset {
    return Intl.message(
      'Réinitialiser',
      name: 'settings_reset',
      desc: '',
      args: [],
    );
  }

  /// `Réinitialiser la base`
  String get settings_resetDatabase {
    return Intl.message(
      'Réinitialiser la base',
      name: 'settings_resetDatabase',
      desc: '',
      args: [],
    );
  }

  /// `Réinitialiser la base locale ?`
  String get settings_resetDatabaseTitle {
    return Intl.message(
      'Réinitialiser la base locale ?',
      name: 'settings_resetDatabaseTitle',
      desc: '',
      args: [],
    );
  }

  /// `Cette opération supprimera toutes les données locales (patients, résultats, imports et historiques).\n\nUne sauvegarde automatique sera créée avant la réinitialisation.\n\nUtilisez cette fonction uniquement lors d’une opération d’assistance technique.`
  String get settings_resetDatabaseWarning {
    return Intl.message(
      'Cette opération supprimera toutes les données locales (patients, résultats, imports et historiques).\n\nUne sauvegarde automatique sera créée avant la réinitialisation.\n\nUtilisez cette fonction uniquement lors d’une opération d’assistance technique.',
      name: 'settings_resetDatabaseWarning',
      desc: '',
      args: [],
    );
  }

  /// `RESET`
  String get settings_resetKeyword {
    return Intl.message(
      'RESET',
      name: 'settings_resetKeyword',
      desc: '',
      args: [],
    );
  }

  /// `Réinitialiser`
  String get settings_resetTooltip {
    return Intl.message(
      'Réinitialiser',
      name: 'settings_resetTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Résoudre un problème d’import`
  String get settings_resolveImportProblem {
    return Intl.message(
      'Résoudre un problème d’import',
      name: 'settings_resolveImportProblem',
      desc: '',
      args: [],
    );
  }

  /// `Assistance`
  String get settings_title {
    return Intl.message(
      'Assistance',
      name: 'settings_title',
      desc: '',
      args: [],
    );
  }

  /// `Tapez RESET pour confirmer définitivement.`
  String get settings_typeResetConfirmation {
    return Intl.message(
      'Tapez RESET pour confirmer définitivement.',
      name: 'settings_typeResetConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Diagnostic Carte Vitale`
  String get settings_vitaleDiagnostic {
    return Intl.message(
      'Diagnostic Carte Vitale',
      name: 'settings_vitaleDiagnostic',
      desc: '',
      args: [],
    );
  }

  /// `Diagnostic Carte Vitale`
  String get smartCardDiagnostic {
    return Intl.message(
      'Diagnostic Carte Vitale',
      name: 'smartCardDiagnostic',
      desc: '',
      args: [],
    );
  }

  /// `Aucun enregistrement audio disponible.`
  String get speechDictationButton_audio {
    return Intl.message(
      'Aucun enregistrement audio disponible.',
      name: 'speechDictationButton_audio',
      desc: '',
      args: [],
    );
  }

  /// `Fermer`
  String get speechDictationButton_close {
    return Intl.message(
      'Fermer',
      name: 'speechDictationButton_close',
      desc: '',
      args: [],
    );
  }

  /// `Dicter`
  String get speechDictationButton_dictate {
    return Intl.message(
      'Dicter',
      name: 'speechDictationButton_dictate',
      desc: '',
      args: [],
    );
  }

  /// `Télécharger le module`
  String get speechDictationButton_download {
    return Intl.message(
      'Télécharger le module',
      name: 'speechDictationButton_download',
      desc: '',
      args: [],
    );
  }

  /// `La dictée vocale a échoué : {error}`
  String speechDictationButton_failure(Object error) {
    return Intl.message(
      'La dictée vocale a échoué : $error',
      name: 'speechDictationButton_failure',
      desc: '',
      args: [error],
    );
  }

  /// `La dictée vocale nécessite l’installation du module optionnel ABAK Dictée vocale.\n\nCe module est gratuit et fonctionne localement sur votre ordinateur, sans envoyer les enregistrements vocaux sur Internet.\n\nLe téléchargement représente environ 1,5 Go.`
  String get speechDictationButton_information {
    return Intl.message(
      'La dictée vocale nécessite l’installation du module optionnel ABAK Dictée vocale.\n\nCe module est gratuit et fonctionne localement sur votre ordinateur, sans envoyer les enregistrements vocaux sur Internet.\n\nLe téléchargement représente environ 1,5 Go.',
      name: 'speechDictationButton_information',
      desc: '',
      args: [],
    );
  }

  /// `Arrêter la dictée`
  String get speechDictationButton_stop {
    return Intl.message(
      'Arrêter la dictée',
      name: 'speechDictationButton_stop',
      desc: '',
      args: [],
    );
  }

  /// `Dictée vocale`
  String get speechDictationButton_title {
    return Intl.message(
      'Dictée vocale',
      name: 'speechDictationButton_title',
      desc: '',
      args: [],
    );
  }

  /// `L’accès au microphone n’est pas autorisé.`
  String get speechRecordingService_permission {
    return Intl.message(
      'L’accès au microphone n’est pas autorisé.',
      name: 'speechRecordingService_permission',
      desc: '',
      args: [],
    );
  }

  /// `Patients actifs`
  String get systemOverviewBar_active_patients {
    return Intl.message(
      'Patients actifs',
      name: 'systemOverviewBar_active_patients',
      desc: '',
      args: [],
    );
  }

  /// `Alertes`
  String get systemOverviewBar_alert {
    return Intl.message(
      'Alertes',
      name: 'systemOverviewBar_alert',
      desc: '',
      args: [],
    );
  }

  /// `Patients archivés`
  String get systemOverviewBar_archived_patients {
    return Intl.message(
      'Patients archivés',
      name: 'systemOverviewBar_archived_patients',
      desc: '',
      args: [],
    );
  }

  /// `Chargement du résumé système...`
  String get systemOverviewBar_loading_system_summary {
    return Intl.message(
      'Chargement du résumé système...',
      name: 'systemOverviewBar_loading_system_summary',
      desc: '',
      args: [],
    );
  }

  /// `Erreur supervision`
  String get systemOverviewBar_supervision_error {
    return Intl.message(
      'Erreur supervision',
      name: 'systemOverviewBar_supervision_error',
      desc: '',
      args: [],
    );
  }

  /// `Supervision indisponible`
  String get systemOverviewBar_supervision_unavailable {
    return Intl.message(
      'Supervision indisponible',
      name: 'systemOverviewBar_supervision_unavailable',
      desc: '',
      args: [],
    );
  }

  /// `Aucune`
  String get systemStatusCard_nome {
    return Intl.message(
      'Aucune',
      name: 'systemStatusCard_nome',
      desc: '',
      args: [],
    );
  }

  /// `Paramètres utilisateur`
  String get user_settings {
    return Intl.message(
      'Paramètres utilisateur',
      name: 'user_settings',
      desc: '',
      args: [],
    );
  }

  /// `Paramètres utilisateur`
  String get userPreferences {
    return Intl.message(
      'Paramètres utilisateur',
      name: 'userPreferences',
      desc: '',
      args: [],
    );
  }

  /// `Annuler`
  String get vitaleBeneficiarySelector_cancel {
    return Intl.message(
      'Annuler',
      name: 'vitaleBeneficiarySelector_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Cette fenêtre permet de choisir la personne concernée lorsque plusieurs bénéficiaires sont proposés après la lecture de la carte Vitale.\n\nVérifiez le nom, le prénom et la date de naissance lorsqu’elle est disponible, puis cliquez sur la ligne du bénéficiaire souhaité.\n\nLa sélection ferme cette fenêtre et transmet l’identité choisie à l’étape suivante.\n\n« Annuler » ferme la fenêtre sans sélectionner de bénéficiaire.`
  String get vitaleBeneficiarySelector_help {
    return Intl.message(
      'Cette fenêtre permet de choisir la personne concernée lorsque plusieurs bénéficiaires sont proposés après la lecture de la carte Vitale.\n\nVérifiez le nom, le prénom et la date de naissance lorsqu’elle est disponible, puis cliquez sur la ligne du bénéficiaire souhaité.\n\nLa sélection ferme cette fenêtre et transmet l’identité choisie à l’étape suivante.\n\n« Annuler » ferme la fenêtre sans sélectionner de bénéficiaire.',
      name: 'vitaleBeneficiarySelector_help',
      desc: '',
      args: [],
    );
  }

  /// `Cet écran permet de vérifier le fonctionnement du dispositif de lecture de la carte Vitale.\n\nSous Windows, la rubrique consacrée au module indique son état et permet d’actualiser cette information.\n\nLancez une lecture avec le lecteur connecté et la carte insérée. Si plusieurs bénéficiaires sont proposés, sélectionnez la personne concernée pour consulter les informations lues.\n\nLes messages affichés permettent de comprendre un éventuel échec et peuvent être communiqués à l’assistance.\n\nLa rubrique « Diagnostic avancé » propose un test technique de communication avec la carte. Utilisez-la selon les indications de la documentation ABAK ou d’un technicien.\n\nCet écran sert au diagnostic : la lecture d’une identité ne crée pas de fiche patient.`
  String get vitaleDiagnostic_help {
    return Intl.message(
      'Cet écran permet de vérifier le fonctionnement du dispositif de lecture de la carte Vitale.\n\nSous Windows, la rubrique consacrée au module indique son état et permet d’actualiser cette information.\n\nLancez une lecture avec le lecteur connecté et la carte insérée. Si plusieurs bénéficiaires sont proposés, sélectionnez la personne concernée pour consulter les informations lues.\n\nLes messages affichés permettent de comprendre un éventuel échec et peuvent être communiqués à l’assistance.\n\nLa rubrique « Diagnostic avancé » propose un test technique de communication avec la carte. Utilisez-la selon les indications de la documentation ABAK ou d’un technicien.\n\nCet écran sert au diagnostic : la lecture d’une identité ne crée pas de fiche patient.',
      name: 'vitaleDiagnostic_help',
      desc: '',
      args: [],
    );
  }

  /// `Sélectionnez un bénéficiaire`
  String get vitaleBeneficiarySelector_selectBeneficiary {
    return Intl.message(
      'Sélectionnez un bénéficiaire',
      name: 'vitaleBeneficiarySelector_selectBeneficiary',
      desc: '',
      args: [],
    );
  }

  /// `Date de naissance`
  String get vitaleIdentity_birthDate {
    return Intl.message(
      'Date de naissance',
      name: 'vitaleIdentity_birthDate',
      desc: '',
      args: [],
    );
  }

  /// `donnée masquée`
  String get vitaleIdentity_dataMasked {
    return Intl.message(
      'donnée masquée',
      name: 'vitaleIdentity_dataMasked',
      desc: '',
      args: [],
    );
  }

  /// `détecté`
  String get vitaleIdentity_detected {
    return Intl.message(
      'détecté',
      name: 'vitaleIdentity_detected',
      desc: '',
      args: [],
    );
  }

  /// `Féminin`
  String get vitaleIdentity_female {
    return Intl.message(
      'Féminin',
      name: 'vitaleIdentity_female',
      desc: '',
      args: [],
    );
  }

  /// `Prénom`
  String get vitaleIdentity_firstName {
    return Intl.message(
      'Prénom',
      name: 'vitaleIdentity_firstName',
      desc: '',
      args: [],
    );
  }

  /// `Cet écran permet de lire l’identité d’un bénéficiaire depuis une carte Vitale, lorsque le lecteur et le module de lecture sont disponibles.\n\nLa lecture démarre à l’ouverture de l’écran. Vous pouvez la relancer avec le bouton de lecture. Si plusieurs bénéficiaires sont présents sur la carte, sélectionnez la personne concernée.\n\nVérifiez le nom, le prénom, la date de naissance et les autres informations affichées. Le numéro d’identification est signalé comme détecté ou indisponible, sans être affiché intégralement.\n\nLorsque l’identité est utilisable, le bouton de création du patient permet de transmettre ces informations au formulaire de création.\n\nSi aucune identité n’est disponible, consultez le message affiché et vérifiez le dispositif de lecture avant de réessayer. Vous pouvez revenir à l’écran précédent pour effectuer une saisie manuelle.`
  String get vitaleIdentity_help {
    return Intl.message(
      'Cet écran permet de lire l’identité d’un bénéficiaire depuis une carte Vitale, lorsque le lecteur et le module de lecture sont disponibles.\n\nLa lecture démarre à l’ouverture de l’écran. Vous pouvez la relancer avec le bouton de lecture. Si plusieurs bénéficiaires sont présents sur la carte, sélectionnez la personne concernée.\n\nVérifiez le nom, le prénom, la date de naissance et les autres informations affichées. Le numéro d’identification est signalé comme détecté ou indisponible, sans être affiché intégralement.\n\nLorsque l’identité est utilisable, le bouton de création du patient permet de transmettre ces informations au formulaire de création.\n\nSi aucune identité n’est disponible, consultez le message affiché et vérifiez le dispositif de lecture avant de réessayer. Vous pouvez revenir à l’écran précédent pour effectuer une saisie manuelle.',
      name: 'vitaleIdentity_help',
      desc: '',
      args: [],
    );
  }

  /// `Identité lue`
  String get vitaleIdentity_identityRead {
    return Intl.message(
      'Identité lue',
      name: 'vitaleIdentity_identityRead',
      desc: '',
      args: [],
    );
  }

  /// `identité reçue (données personnelles masquées)`
  String get vitaleIdentity_identityReceivedMasked {
    return Intl.message(
      'identité reçue (données personnelles masquées)',
      name: 'vitaleIdentity_identityReceivedMasked',
      desc: '',
      args: [],
    );
  }

  /// `identité non disponible`
  String get vitaleIdentity_identityUnavailable {
    return Intl.message(
      'identité non disponible',
      name: 'vitaleIdentity_identityUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Nom`
  String get vitaleIdentity_lastName {
    return Intl.message(
      'Nom',
      name: 'vitaleIdentity_lastName',
      desc: '',
      args: [],
    );
  }

  /// `Masculin`
  String get vitaleIdentity_male {
    return Intl.message(
      'Masculin',
      name: 'vitaleIdentity_male',
      desc: '',
      args: [],
    );
  }

  /// `NIR`
  String get vitaleIdentity_nir {
    return Intl.message(
      'NIR',
      name: 'vitaleIdentity_nir',
      desc: '',
      args: [],
    );
  }

  /// `Aucune identité Carte Vitale disponible`
  String get vitaleIdentity_noIdentityAvailable {
    return Intl.message(
      'Aucune identité Carte Vitale disponible',
      name: 'vitaleIdentity_noIdentityAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Non renseigné`
  String get vitaleIdentity_notProvided {
    return Intl.message(
      'Non renseigné',
      name: 'vitaleIdentity_notProvided',
      desc: '',
      args: [],
    );
  }

  /// `Autre`
  String get vitaleIdentity_other {
    return Intl.message(
      'Autre',
      name: 'vitaleIdentity_other',
      desc: '',
      args: [],
    );
  }

  /// `Lecture en cours...`
  String get vitaleIdentity_reading {
    return Intl.message(
      'Lecture en cours...',
      name: 'vitaleIdentity_reading',
      desc: '',
      args: [],
    );
  }

  /// `Sexe`
  String get vitaleIdentity_sex {
    return Intl.message(
      'Sexe',
      name: 'vitaleIdentity_sex',
      desc: '',
      args: [],
    );
  }

  /// `Source`
  String get vitaleIdentity_source {
    return Intl.message(
      'Source',
      name: 'vitaleIdentity_source',
      desc: '',
      args: [],
    );
  }

  /// `Lire identité Carte Vitale`
  String get vitaleIdentity_title {
    return Intl.message(
      'Lire identité Carte Vitale',
      name: 'vitaleIdentity_title',
      desc: '',
      args: [],
    );
  }

  /// `Non disponible`
  String get vitaleIdentity_unavailable {
    return Intl.message(
      'Non disponible',
      name: 'vitaleIdentity_unavailable',
      desc: '',
      args: [],
    );
  }

  /// `Utiliser pour créer un patient`
  String get vitaleIdentity_useForPatientCreation {
    return Intl.message(
      'Utiliser pour créer un patient',
      name: 'vitaleIdentity_useForPatientCreation',
      desc: '',
      args: [],
    );
  }

  /// `Aucune`
  String get walkingAid_none {
    return Intl.message(
      'Aucune',
      name: 'walkingAid_none',
      desc: '',
      args: [],
    );
  }

  /// `Canne`
  String get walkingAid_cane {
    return Intl.message(
      'Canne',
      name: 'walkingAid_cane',
      desc: '',
      args: [],
    );
  }

  /// `Déambulateur 2 roues`
  String get walkingAid_walkerTwoWheels {
    return Intl.message(
      'Déambulateur 2 roues',
      name: 'walkingAid_walkerTwoWheels',
      desc: '',
      args: [],
    );
  }

  /// `Rollator 4 roues`
  String get walkingAid_rollatorFourWheels {
    return Intl.message(
      'Rollator 4 roues',
      name: 'walkingAid_rollatorFourWheels',
      desc: '',
      args: [],
    );
  }

  /// `Autre`
  String get walkingAid_other {
    return Intl.message(
      'Autre',
      name: 'walkingAid_other',
      desc: '',
      args: [],
    );
  }

  /// `Aide utilisée`
  String get walkingAid_label {
    return Intl.message(
      'Aide utilisée',
      name: 'walkingAid_label',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
      Locale.fromSubtags(languageCode: 'de', countryCode: 'DE'),
      Locale.fromSubtags(languageCode: 'en', countryCode: 'GB'),
      Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
      Locale.fromSubtags(languageCode: 'it', countryCode: 'IT'),
      Locale.fromSubtags(languageCode: 'nl', countryCode: 'NL'),
      Locale.fromSubtags(languageCode: 'pt', countryCode: 'PT'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
