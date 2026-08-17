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

  /// `Fermer`
  String get close {
    return Intl.message(
      'Fermer',
      name: 'close',
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

  /// `Chargement...`
  String get loading {
    return Intl.message(
      'Chargement...',
      name: 'loading',
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

  /// `Créer un praticien`
  String get practitionerList_button_create {
    return Intl.message(
      'Créer un praticien',
      name: 'practitionerList_button_create',
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

  /// `Liste des praticiens`
  String get practitionerList_contextName {
    return Intl.message(
      'Liste des praticiens',
      name: 'practitionerList_contextName',
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

  /// `Erreur : {error}`
  String practitionerList_error(Object error) {
    return Intl.message(
      'Erreur : $error',
      name: 'practitionerList_error',
      desc: '',
      args: [error],
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

  /// `Voulez-vous vraiment archiver {practitionerName} ?`
  String practitionerList_archiveConfirmation(Object practitionerName) {
    return Intl.message(
      'Voulez-vous vraiment archiver $practitionerName ?',
      name: 'practitionerList_archiveConfirmation',
      desc: '',
      args: [practitionerName],
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

  /// `Archiver`
  String get practitionerList_archive {
    return Intl.message(
      'Archiver',
      name: 'practitionerList_archive',
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

  /// `Archivés`
  String get practitionerList_archived {
    return Intl.message(
      'Archivés',
      name: 'practitionerList_archived',
      desc: '',
      args: [],
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

  /// `La corbeille des kinés est vide pour le moment.`
  String get practitionerList_archiveEmpty {
    return Intl.message(
      'La corbeille des kinés est vide pour le moment.',
      name: 'practitionerList_archiveEmpty',
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

  /// `Archivé le {date}`
  String practitionerList_archivedOn(Object date) {
    return Intl.message(
      'Archivé le $date',
      name: 'practitionerList_archivedOn',
      desc: '',
      args: [date],
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

  /// `Modifier`
  String get practitionerList_edit {
    return Intl.message(
      'Modifier',
      name: 'practitionerList_edit',
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

  /// `archivé`
  String get practitionerSelector_archived {
    return Intl.message(
      'archivé',
      name: 'practitionerSelector_archived',
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

  /// `Réinitialiser`
  String get reset {
    return Intl.message(
      'Réinitialiser',
      name: 'reset',
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
