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

  /// `Fermer`
  String get close {
    return Intl.message(
      'Fermer',
      name: 'close',
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

  /// `Pathologie`
  String get careEpisodeDetail_pathology {
    return Intl.message(
      'Pathologie',
      name: 'careEpisodeDetail_pathology',
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

  /// `Évolution`
  String get careEpisodeDetail_evolution {
    return Intl.message(
      'Évolution',
      name: 'careEpisodeDetail_evolution',
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

  /// `Score`
  String get careEpisodeDetail_score {
    return Intl.message(
      'Score',
      name: 'careEpisodeDetail_score',
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

  /// `Diagnostic fiche d’entretien`
  String get contactFormTemplateDiagnostic_title {
    return Intl.message(
      'Diagnostic fiche d’entretien',
      name: 'contactFormTemplateDiagnostic_title',
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

  /// `ID modèle`
  String get contactFormTemplateDiagnostic_templateId {
    return Intl.message(
      'ID modèle',
      name: 'contactFormTemplateDiagnostic_templateId',
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

  /// `Modèle système`
  String get contactFormTemplateDiagnostic_systemTemplate {
    return Intl.message(
      'Modèle système',
      name: 'contactFormTemplateDiagnostic_systemTemplate',
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

  /// `Non définie`
  String get contactFormTemplateDiagnostic_notDefined {
    return Intl.message(
      'Non définie',
      name: 'contactFormTemplateDiagnostic_notDefined',
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

  /// `Oui`
  String get contactFormTemplateDiagnostic_yes {
    return Intl.message(
      'Oui',
      name: 'contactFormTemplateDiagnostic_yes',
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

  /// `Type`
  String get contactFormTemplateDiagnostic_type {
    return Intl.message(
      'Type',
      name: 'contactFormTemplateDiagnostic_type',
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

  /// `Obligatoire`
  String get contactFormTemplateDiagnostic_required {
    return Intl.message(
      'Obligatoire',
      name: 'contactFormTemplateDiagnostic_required',
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

  /// `Champs`
  String get contactFormTemplateDiagnostic_fields {
    return Intl.message(
      'Champs',
      name: 'contactFormTemplateDiagnostic_fields',
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

  /// `Aucune donnée à afficher.`
  String get contactFormTemplateDiagnostic_noData {
    return Intl.message(
      'Aucune donnée à afficher.',
      name: 'contactFormTemplateDiagnostic_noData',
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

  /// `Nouvel appareil`
  String get deviceForm_contextName {
    return Intl.message(
      'Nouvel appareil',
      name: 'deviceForm_contextName',
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

  /// `Nouvel appareil`
  String get deviceForm_newDevice {
    return Intl.message(
      'Nouvel appareil',
      name: 'deviceForm_newDevice',
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

  /// `Plateforme`
  String get deviceForm_platform {
    return Intl.message(
      'Plateforme',
      name: 'deviceForm_platform',
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

  /// `Aucun / appareil partagé`
  String get deviceForm_sharedDevice {
    return Intl.message(
      'Aucun / appareil partagé',
      name: 'deviceForm_sharedDevice',
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

  /// `Enregistrer`
  String get deviceForm_save {
    return Intl.message(
      'Enregistrer',
      name: 'deviceForm_save',
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

  /// `Liste des appareils`
  String get deviceList_contextName {
    return Intl.message(
      'Liste des appareils',
      name: 'deviceList_contextName',
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

  /// `Archiver l’appareil`
  String get deviceList_archiveTitle {
    return Intl.message(
      'Archiver l’appareil',
      name: 'deviceList_archiveTitle',
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

  /// `Annuler`
  String get deviceList_cancel {
    return Intl.message(
      'Annuler',
      name: 'deviceList_cancel',
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

  /// `Nouvel appareil`
  String get deviceList_newDevice {
    return Intl.message(
      'Nouvel appareil',
      name: 'deviceList_newDevice',
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

  /// `Liste des appareils`
  String get deviceList_title {
    return Intl.message(
      'Liste des appareils',
      name: 'deviceList_title',
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

  /// `Archivés`
  String get deviceList_archived {
    return Intl.message(
      'Archivés',
      name: 'deviceList_archived',
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

  /// `La corbeille des appareils est vide pour le moment.`
  String get deviceList_archivedDevicesEmpty {
    return Intl.message(
      'La corbeille des appareils est vide pour le moment.',
      name: 'deviceList_archivedDevicesEmpty',
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

  /// `Archivé le`
  String get deviceList_archivedOn {
    return Intl.message(
      'Archivé le',
      name: 'deviceList_archivedOn',
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

  /// `Praticien associé`
  String get deviceList_associatedPractitioner {
    return Intl.message(
      'Praticien associé',
      name: 'deviceList_associatedPractitioner',
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

  /// `Modifier`
  String get deviceList_edit {
    return Intl.message(
      'Modifier',
      name: 'deviceList_edit',
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

  /// `Modifier le formulaire`
  String get episodeFormEditor_title {
    return Intl.message(
      'Modifier le formulaire',
      name: 'episodeFormEditor_title',
      desc: '',
      args: [],
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

  /// `Le champ "{fieldName}" est obligatoire.`
  String episodeFormEditor_requiredField(Object fieldName) {
    return Intl.message(
      'Le champ "$fieldName" est obligatoire.',
      name: 'episodeFormEditor_requiredField',
      desc: '',
      args: [fieldName],
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

  /// `Dossier d'échange réinitialisé`
  String get exchangeDirectoryReset {
    return Intl.message(
      'Dossier d\'échange réinitialisé',
      name: 'exchangeDirectoryReset',
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

  /// `Documents de la prise en charge`
  String get episodeDocuments_title {
    return Intl.message(
      'Documents de la prise en charge',
      name: 'episodeDocuments_title',
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

  /// `Impossible d’ajouter le document`
  String get episodeDocuments_addError {
    return Intl.message(
      'Impossible d’ajouter le document',
      name: 'episodeDocuments_addError',
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

  /// `Ouverture non prise en charge sur cette plateforme.`
  String get episodeDocuments_platformNotSupported {
    return Intl.message(
      'Ouverture non prise en charge sur cette plateforme.',
      name: 'episodeDocuments_platformNotSupported',
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

  /// `Document texte`
  String get episodeDocuments_textDocument {
    return Intl.message(
      'Document texte',
      name: 'episodeDocuments_textDocument',
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

  /// `Image`
  String get episodeDocuments_image {
    return Intl.message(
      'Image',
      name: 'episodeDocuments_image',
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

  /// `Ajouté le`
  String get episodeDocuments_addedOn {
    return Intl.message(
      'Ajouté le',
      name: 'episodeDocuments_addedOn',
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

  /// `Aucun document associé à cette prise en charge.`
  String get episodeDocuments_noDocument {
    return Intl.message(
      'Aucun document associé à cette prise en charge.',
      name: 'episodeDocuments_noDocument',
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

  /// `Vous pouvez associer à cette prise en charge des documents créés avec vos applications habituelles : traitement de texte, tableur, lecteur PDF ou logiciel d’image.\n\nLes fichiers ajoutés sont copiés dans l’espace de stockage de Companion. Un clic sur un document l’ouvre avec l’application correspondante installée sur cet ordinateur.`
  String get episodeDocuments_help {
    return Intl.message(
      'Vous pouvez associer à cette prise en charge des documents créés avec vos applications habituelles : traitement de texte, tableur, lecteur PDF ou logiciel d’image.\n\nLes fichiers ajoutés sont copiés dans l’espace de stockage de Companion. Un clic sur un document l’ouvre avec l’application correspondante installée sur cet ordinateur.',
      name: 'episodeDocuments_help',
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

  /// `Impossible de charger les documents associés.`
  String get episodeDocuments_loadError {
    return Intl.message(
      'Impossible de charger les documents associés.',
      name: 'episodeDocuments_loadError',
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

  /// `Catégorie`
  String get episodeForms_category {
    return Intl.message(
      'Catégorie',
      name: 'episodeForms_category',
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

  /// `Modèle personnalisé`
  String get episodeForms_customTemplate {
    return Intl.message(
      'Modèle personnalisé',
      name: 'episodeForms_customTemplate',
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

  /// `Formulaire`
  String get episodeForms_form {
    return Intl.message(
      'Formulaire',
      name: 'episodeForms_form',
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

  /// `État`
  String get episodeForms_state {
    return Intl.message(
      'État',
      name: 'episodeForms_state',
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

  /// `en cours`
  String get episodeForms_inProgress {
    return Intl.message(
      'en cours',
      name: 'episodeForms_inProgress',
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

  /// `Aucun formulaire créé pour cet épisode.`
  String get episodeForms_noCreatedForm {
    return Intl.message(
      'Aucun formulaire créé pour cet épisode.',
      name: 'episodeForms_noCreatedForm',
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

  /// `Aucun modèle de formulaire disponible.`
  String get episodeForms_noAvailableTemplate {
    return Intl.message(
      'Aucun modèle de formulaire disponible.',
      name: 'episodeForms_noAvailableTemplate',
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

  /// `Actualiser`
  String get episodeForms_refresh {
    return Intl.message(
      'Actualiser',
      name: 'episodeForms_refresh',
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

  /// `Aucune donnée à afficher.`
  String get episodeForms_noData {
    return Intl.message(
      'Aucune donnée à afficher.',
      name: 'episodeForms_noData',
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

  /// `Actualiser`
  String get episodeNotes_refresh {
    return Intl.message(
      'Actualiser',
      name: 'episodeNotes_refresh',
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

  /// `Archiver la note ?`
  String get episodeNotes_archiveTitle {
    return Intl.message(
      'Archiver la note ?',
      name: 'episodeNotes_archiveTitle',
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

  /// `Annuler`
  String get episodeNotes_cancel {
    return Intl.message(
      'Annuler',
      name: 'episodeNotes_cancel',
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

  /// `Erreur`
  String get episodeNotes_error {
    return Intl.message(
      'Erreur',
      name: 'episodeNotes_error',
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

  /// `Le titre est obligatoire.`
  String get episodeNotes_titleRequired {
    return Intl.message(
      'Le titre est obligatoire.',
      name: 'episodeNotes_titleRequired',
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

  /// `Enregistrer`
  String get episodeNotes_save {
    return Intl.message(
      'Enregistrer',
      name: 'episodeNotes_save',
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

  /// `Contenu`
  String get episodeNotes_content {
    return Intl.message(
      'Contenu',
      name: 'episodeNotes_content',
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

  /// `Actualiser`
  String get episodeReport_refresh {
    return Intl.message(
      'Actualiser',
      name: 'episodeReport_refresh',
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

  /// `Aucune donnée à afficher.`
  String get episodeReport_noData {
    return Intl.message(
      'Aucune donnée à afficher.',
      name: 'episodeReport_noData',
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

  /// `Aperçu du rapport généré`
  String get episodeReport_generatedPreview {
    return Intl.message(
      'Aperçu du rapport généré',
      name: 'episodeReport_generatedPreview',
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

  /// `Nom`
  String get episodeReport_name {
    return Intl.message(
      'Nom',
      name: 'episodeReport_name',
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

  /// `Email`
  String get episodeReport_email {
    return Intl.message(
      'Email',
      name: 'episodeReport_email',
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

  /// `Profession`
  String get episodeReport_profession {
    return Intl.message(
      'Profession',
      name: 'episodeReport_profession',
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

  /// `Formulaires`
  String get episodeReport_forms {
    return Intl.message(
      'Formulaires',
      name: 'episodeReport_forms',
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

  /// `Résultats ABAK`
  String get episodeReport_results {
    return Intl.message(
      'Résultats ABAK',
      name: 'episodeReport_results',
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

  /// `Score`
  String get episodeReport_score {
    return Intl.message(
      'Score',
      name: 'episodeReport_score',
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

  /// `Documents`
  String get episodeReport_documents {
    return Intl.message(
      'Documents',
      name: 'episodeReport_documents',
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

  /// `Type inconnu`
  String get episodeReport_unknownType {
    return Intl.message(
      'Type inconnu',
      name: 'episodeReport_unknownType',
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

  /// `Aucune note associée`
  String get episodeReport_noNote {
    return Intl.message(
      'Aucune note associée',
      name: 'episodeReport_noNote',
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

  /// `Aucune conclusion renseignée.`
  String get episodeReport_noConclusion {
    return Intl.message(
      'Aucune conclusion renseignée.',
      name: 'episodeReport_noConclusion',
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

  /// `Modifier la conclusion`
  String get episodeReport_editConclusion {
    return Intl.message(
      'Modifier la conclusion',
      name: 'episodeReport_editConclusion',
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

  /// `Enregistrer`
  String get episodeReport_save {
    return Intl.message(
      'Enregistrer',
      name: 'episodeReport_save',
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

  /// `Vous pouvez créer, modifier, archiver un appareil.\n\nPour des raisons de traçabilité il n'est pas possible de supprimer un appareil\nVous pouvez si nécessaire le restaurer.\n\nLe QR Code est utilisé pour appairer un téléphone ou une tablette.`
  String get help_device_list_content {
    return Intl.message(
      'Vous pouvez créer, modifier, archiver un appareil.\n\nPour des raisons de traçabilité il n\'est pas possible de supprimer un appareil\nVous pouvez si nécessaire le restaurer.\n\nLe QR Code est utilisé pour appairer un téléphone ou une tablette.',
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

  /// `Vous trouvez ici les différentes prises en charge de votre patient\Vous pouvez utiliser un épisode existant\Vous pouvez en créer un nouveau`
  String get help_prise_en_charge {
    return Intl.message(
      'Vous trouvez ici les différentes prises en charge de votre patient\\Vous pouvez utiliser un épisode existant\\Vous pouvez en créer un nouveau',
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

  /// `Modifier les données cliniques`
  String get patientClinicalDataEdit_title {
    return Intl.message(
      'Modifier les données cliniques',
      name: 'patientClinicalDataEdit_title',
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

  /// `Identité administrative`
  String get patientClinicalDataEdit_administrativeIdentity {
    return Intl.message(
      'Identité administrative',
      name: 'patientClinicalDataEdit_administrativeIdentity',
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

  /// `Pays du système de santé`
  String get patientClinicalDataEdit_healthSystemCountry {
    return Intl.message(
      'Pays du système de santé',
      name: 'patientClinicalDataEdit_healthSystemCountry',
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

  /// `Saisie manuelle`
  String get patientClinicalDataEdit_manualEntry {
    return Intl.message(
      'Saisie manuelle',
      name: 'patientClinicalDataEdit_manualEntry',
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

  /// `Téléphone`
  String get patientClinicalDataEdit_phone {
    return Intl.message(
      'Téléphone',
      name: 'patientClinicalDataEdit_phone',
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

  /// `Adresse`
  String get patientClinicalDataEdit_address {
    return Intl.message(
      'Adresse',
      name: 'patientClinicalDataEdit_address',
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

  /// `Côté dominant`
  String get patientClinicalDataEdit_dominantSide {
    return Intl.message(
      'Côté dominant',
      name: 'patientClinicalDataEdit_dominantSide',
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

  /// `Gauche`
  String get patientClinicalDataEdit_left {
    return Intl.message(
      'Gauche',
      name: 'patientClinicalDataEdit_left',
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

  /// `Non précisé`
  String get patientClinicalDataEdit_unspecified {
    return Intl.message(
      'Non précisé',
      name: 'patientClinicalDataEdit_unspecified',
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

  /// `Activité sportive habituelle`
  String get patientClinicalDataEdit_sportActivity {
    return Intl.message(
      'Activité sportive habituelle',
      name: 'patientClinicalDataEdit_sportActivity',
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

  /// `En centimètres`
  String get patientClinicalDataEdit_centimeters {
    return Intl.message(
      'En centimètres',
      name: 'patientClinicalDataEdit_centimeters',
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

  /// `En kilogrammes`
  String get patientClinicalDataEdit_kilograms {
    return Intl.message(
      'En kilogrammes',
      name: 'patientClinicalDataEdit_kilograms',
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

  /// `ans`
  String get patientDetail_years {
    return Intl.message(
      'ans',
      name: 'patientDetail_years',
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

  /// `Non renseigné`
  String get patientDetail_noBirthdate {
    return Intl.message(
      'Non renseigné',
      name: 'patientDetail_noBirthdate',
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

  /// `Compte rendu initial`
  String get patientDetail_initialReport {
    return Intl.message(
      'Compte rendu initial',
      name: 'patientDetail_initialReport',
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

  /// `Annuler`
  String get patientDetail_cancel {
    return Intl.message(
      'Annuler',
      name: 'patientDetail_cancel',
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

  /// `Nouvelle prise en charge`
  String get patientDetail_newCareEpisode {
    return Intl.message(
      'Nouvelle prise en charge',
      name: 'patientDetail_newCareEpisode',
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

  /// `Prise en charge ouverte en`
  String get patientDetail_careEpisodeOpenedIn {
    return Intl.message(
      'Prise en charge ouverte en',
      name: 'patientDetail_careEpisodeOpenedIn',
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

  /// `Né(e) le`
  String get patientDetail_bornOn {
    return Intl.message(
      'Né(e) le',
      name: 'patientDetail_bornOn',
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

  /// `Identité de santé — France`
  String get patientDetail_frHealthIdentity {
    return Intl.message(
      'Identité de santé — France',
      name: 'patientDetail_frHealthIdentity',
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

  /// `Statut`
  String get patientDetail_status {
    return Intl.message(
      'Statut',
      name: 'patientDetail_status',
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

  /// `Récupérée`
  String get patientDetail_retrieved {
    return Intl.message(
      'Récupérée',
      name: 'patientDetail_retrieved',
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

  /// `Qualifiée`
  String get patientDetail_qualified {
    return Intl.message(
      'Qualifiée',
      name: 'patientDetail_qualified',
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

  /// `INS obtenue, identité à contrôler`
  String get patientDetail_retrievedDescription {
    return Intl.message(
      'INS obtenue, identité à contrôler',
      name: 'patientDetail_retrievedDescription',
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

  /// `Identité conforme`
  String get patientDetail_qualifiedDescription {
    return Intl.message(
      'Identité conforme',
      name: 'patientDetail_qualifiedDescription',
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

  /// `Non renseigné`
  String get patientDetail_notProvided {
    return Intl.message(
      'Non renseigné',
      name: 'patientDetail_notProvided',
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

  /// `Identité administrative`
  String get patientDetail_administrativeIdentity {
    return Intl.message(
      'Identité administrative',
      name: 'patientDetail_administrativeIdentity',
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

  /// `Pays système santé`
  String get patientDetail_healthSystemCountry {
    return Intl.message(
      'Pays système santé',
      name: 'patientDetail_healthSystemCountry',
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

  /// `Téléphone`
  String get patientDetail_phone {
    return Intl.message(
      'Téléphone',
      name: 'patientDetail_phone',
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

  /// `Adresse`
  String get patientDetail_address {
    return Intl.message(
      'Adresse',
      name: 'patientDetail_address',
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

  /// `Côté dominant`
  String get patientDetail_dominantSide {
    return Intl.message(
      'Côté dominant',
      name: 'patientDetail_dominantSide',
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

  /// `Activité sportive`
  String get patientDetail_sportActivity {
    return Intl.message(
      'Activité sportive',
      name: 'patientDetail_sportActivity',
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

  /// `Poids`
  String get patientDetail_weight {
    return Intl.message(
      'Poids',
      name: 'patientDetail_weight',
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

  /// `Aucune prise en charge créée pour ce patient.`
  String get patientDetail_noCareEpisode {
    return Intl.message(
      'Aucune prise en charge créée pour ce patient.',
      name: 'patientDetail_noCareEpisode',
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

  /// `Modifier`
  String get patientDetail_edit {
    return Intl.message(
      'Modifier',
      name: 'patientDetail_edit',
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

  /// `Nouveau patient`
  String get patientForm_newPatient {
    return Intl.message(
      'Nouveau patient',
      name: 'patientForm_newPatient',
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

  /// `Le nom est obligatoire`
  String get patientForm_lastNameRequired {
    return Intl.message(
      'Le nom est obligatoire',
      name: 'patientForm_lastNameRequired',
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

  /// `Date de naissance`
  String get patientForm_birthDate {
    return Intl.message(
      'Date de naissance',
      name: 'patientForm_birthDate',
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

  /// `Femme`
  String get patientForm_female {
    return Intl.message(
      'Femme',
      name: 'patientForm_female',
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

  /// `Autre`
  String get patientForm_other {
    return Intl.message(
      'Autre',
      name: 'patientForm_other',
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

  /// `Enregistrer`
  String get patientForm_save {
    return Intl.message(
      'Enregistrer',
      name: 'patientForm_save',
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

  /// `Nouveau patient`
  String get patientNew_contextName {
    return Intl.message(
      'Nouveau patient',
      name: 'patientNew_contextName',
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

  /// `Patient déjà existant ?`
  String get patientNew_existingPatientTitle {
    return Intl.message(
      'Patient déjà existant ?',
      name: 'patientNew_existingPatientTitle',
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

  /// `Date de naissance`
  String get patientNew_birthDate {
    return Intl.message(
      'Date de naissance',
      name: 'patientNew_birthDate',
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

  /// `Voulez-vous rattacher les informations de la Carte Vitale à ce patient ?`
  String get patientNew_attachVitaleQuestion {
    return Intl.message(
      'Voulez-vous rattacher les informations de la Carte Vitale à ce patient ?',
      name: 'patientNew_attachVitaleQuestion',
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

  /// `Rattacher`
  String get patientNew_attach {
    return Intl.message(
      'Rattacher',
      name: 'patientNew_attach',
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

  /// `Annuler`
  String get patientNew_cancel {
    return Intl.message(
      'Annuler',
      name: 'patientNew_cancel',
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

  /// `Souhaitez-vous restaurer ce dossier plutôt que créer un nouveau patient ?`
  String get patientNew_restoreInsteadOfCreate {
    return Intl.message(
      'Souhaitez-vous restaurer ce dossier plutôt que créer un nouveau patient ?',
      name: 'patientNew_restoreInsteadOfCreate',
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

  /// `Le patient {patientName} a été restauré.`
  String patientNew_restoreSuccess(Object patientName) {
    return Intl.message(
      'Le patient $patientName a été restauré.',
      name: 'patientNew_restoreSuccess',
      desc: '',
      args: [patientName],
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

  /// `Cette Carte Vitale correspond au patient :`
  String get patientNew_vitaleMatchesPatient {
    return Intl.message(
      'Cette Carte Vitale correspond au patient :',
      name: 'patientNew_vitaleMatchesPatient',
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

  /// `Retour à la liste`
  String get patientNew_backToList {
    return Intl.message(
      'Retour à la liste',
      name: 'patientNew_backToList',
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

  /// `Carte Vitale rattachée au patient {patientName}.`
  String patientNew_attachVitaleSuccess(Object patientName) {
    return Intl.message(
      'Carte Vitale rattachée au patient $patientName.',
      name: 'patientNew_attachVitaleSuccess',
      desc: '',
      args: [patientName],
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

  /// `Fermer`
  String get patientNew_close {
    return Intl.message(
      'Fermer',
      name: 'patientNew_close',
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

  /// `Télécharger`
  String get patientNew_download {
    return Intl.message(
      'Télécharger',
      name: 'patientNew_download',
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

  /// `La configuration du module Carte Vitale est absente ou incorrecte. Réinstallez le module puis réessayez.`
  String get patientNew_vitaleModuleConfigurationError {
    return Intl.message(
      'La configuration du module Carte Vitale est absente ou incorrecte. Réinstallez le module puis réessayez.',
      name: 'patientNew_vitaleModuleConfigurationError',
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

  /// `Informations patient préremplies depuis la Carte Vitale.`
  String get patientNew_vitalePrefilled {
    return Intl.message(
      'Informations patient préremplies depuis la Carte Vitale.',
      name: 'patientNew_vitalePrefilled',
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

  /// `Féminin`
  String get patientNew_female {
    return Intl.message(
      'Féminin',
      name: 'patientNew_female',
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

  /// `Autre`
  String get patientNew_other {
    return Intl.message(
      'Autre',
      name: 'patientNew_other',
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

  /// `Identité lue depuis la Carte Vitale`
  String get patientNew_vitaleIdentityRead {
    return Intl.message(
      'Identité lue depuis la Carte Vitale',
      name: 'patientNew_vitaleIdentityRead',
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

  /// `Prénom`
  String get patientNew_firstName {
    return Intl.message(
      'Prénom',
      name: 'patientNew_firstName',
      desc: '',
      args: [],
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

  /// `NIR`
  String get patientNew_nir {
    return Intl.message(
      'NIR',
      name: 'patientNew_nir',
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

  /// `détecté et protégé`
  String get patientNew_nirDetectedProtected {
    return Intl.message(
      'détecté et protégé',
      name: 'patientNew_nirDetectedProtected',
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

  /// `Identité du patient`
  String get patientNew_patientIdentity {
    return Intl.message(
      'Identité du patient',
      name: 'patientNew_patientIdentity',
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

  /// `Lire Carte Vitale`
  String get patientNew_readVitale {
    return Intl.message(
      'Lire Carte Vitale',
      name: 'patientNew_readVitale',
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

  /// `Le prénom est obligatoire`
  String get patientNew_firstNameRequired {
    return Intl.message(
      'Le prénom est obligatoire',
      name: 'patientNew_firstNameRequired',
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

  /// `non disponible`
  String get vitaleIdentity_unavailable {
    return Intl.message(
      'non disponible',
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
