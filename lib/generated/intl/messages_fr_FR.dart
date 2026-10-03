// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fr_FR locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'fr_FR';

  static String m0(careEpisodeId) =>
      "Patient introuvable pour la prise en charge ${careEpisodeId}.";

  static String m1(height) => "${height} cm";

  static String m2(weight) => "${weight} kg";

  static String m3(age) => "${age} ans";

  static String m4(path) => "Autoriser l’accès au dossier : ${path}";

  static String m5(path) =>
      "Choisir le dossier où restaurer les documents de : ${path}";

  static String m6(size) => "${size}";

  static String m7(date) => "Archivée le ${date}";

  static String m8(monthYear) => "Prise en charge ouverte en ${monthYear}";

  static String m9(title) =>
      "Le bilan « ${title} » ne sera plus affiché dans l’historique.";

  static String m10(title) =>
      "Le rapport « ${title} » sera placé dans la corbeille. Il pourra être restauré ultérieurement.";

  static String m11(patientName, title) => "Bilan_${patientName}_${title}";

  static String m12(title) => "Copie de ${title}";

  static String m13(title) =>
      "Le bilan « ${title} » sera définitivement supprimé. Cette action est irréversible.";

  static String m14(title) =>
      "Le rapport « ${title} » sera définitivement supprimé. Cette action est irréversible.";

  static String m15(path) =>
      "\"careEpisodeReportsWorkspaceScreen_directoryAccessMessage\": \"Le dossier configuré n’est pas accessible ou son autorisation doit être renouvelée.\n\n${path}\n\nReconnectez son volume si nécessaire, puis sélectionnez ce dossier pour autoriser son accès. Le dossier sélectionné sera enregistré dans vos préférences.\",\n\"@careEpisodeReportsWorkspaceScreen_directoryAccessMessage\": {\n  \"placeholders\": {\n    \"path\": {\n      \"type\": \"String\"\n    }\n  }\n}";

  static String m16(documentLabel) =>
      "Un brouillon existe déjà pour ce modèle de ${documentLabel}.";

  static String m17(documentLabel) =>
      "Souhaitez-vous ajouter le contenu généré à la suite du ${documentLabel} actuel ou remplacer le contenu existant ?";

  static String m18(documentLabel) => "Nouveau ${documentLabel}";

  static String m19(patientName, title) => "Rapport_${patientName}_${title}";

  static String m20(path) => "Document Word créé : ${path}";

  static String m21(error) =>
      "Erreur lors de la création du document Word : ${error}";

  static String m22(patientName) => "${patientName} — Bilans et rapports";

  static String m23(deviceName) =>
      "Voulez-vous vraiment archiver ${deviceName} ?";

  static String m24(fieldName) => "Le champ \"${fieldName}\" est obligatoire.";

  static String m25(noteTitle) =>
      "La note \"${noteTitle}\" ne sera plus affichée.";

  static String m26(error) => "Erreur lors de la sauvegarde : ${error}";

  static String m27(count) => "${count} autre(s) exercice(s)";

  static String m28(count) => "${count} association(s) en attente";

  static String m29(count) => "${count} sauvegardes";

  static String m30(size) => "Taille : ${size}";

  static String m31(size) => "Taille totale : ${size}";

  static String m32(version) => "Version ${version}";

  static String m33(integrityStatus) =>
      "La base restaurée présente une anomalie : ${integrityStatus}";

  static String m34(error) => "Échec de la restauration : ${error}";

  static String m35(integrityStatus) =>
      "Restauration effectuée mais integrity_check a retourné : ${integrityStatus}";

  static String m36(patientName) =>
      "Voulez-vous vraiment archiver ${patientName} ? Il ne sera plus affiché dans la liste active.";

  static String m37(patientName) => "${patientName} archivé.";

  static String m38(error) => "Erreur : ${error}";

  static String m39(patientName) =>
      "${patientName} restauré dans la liste active.";

  static String m40(patientName) =>
      "Carte Vitale rattachée au patient ${patientName}.";

  static String m41(patientName) => "Le patient ${patientName} a été restauré.";

  static String m42(practitionerName) =>
      "Voulez-vous vraiment archiver ${practitionerName} ?";

  static String m43(date) => "Archivé le ${date}";

  static String m44(error) => "Erreur : ${error}";

  static String m45(professionalId) => "ID pro : ${professionalId}";

  static String m46(error) => "Erreur : ${error}";

  static String m47(name) => "${name} — archivé";

  static String m48(start, end) => "Du ${start} au ${end}";

  static String m49(error) =>
      "Erreur lors du chargement de l’historique : ${error}";

  static String m50(start) => "Depuis le ${start}";

  static String m51(error) => "Erreur lors de la réinitialisation : ${error}";

  static String m52(patientCount, fileCount) =>
      "Export terminé : ${patientCount} patient(s), ${fileCount} fichier(s).";

  static String m53(errorCount, patientCount, fileCount) =>
      "Export terminé avec ${errorCount} erreur(s) : ${patientCount} patient(s), ${fileCount} fichier(s) exporté(s).";

  static String m54(error) => "La dictée vocale a échoué : ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "abakWhisperSpeechProvider_name":
            MessageLookupByLibrary.simpleMessage("ABAK Dictée vocale"),
        "archivedDocuments_help": MessageLookupByLibrary.simpleMessage(
            "Cette vue regroupe les bilans et les rapports archivés de la prise en charge. Chaque ligne indique le type de document, son titre et sa date d’archivage.\n\nL’action de restauration permet de remettre le document dans l’historique des bilans ou des rapports.\n\nL’action de suppression définitive retire le document de Companion. Lisez attentivement le message de confirmation avant de valider : le document ne pourra plus être restauré depuis cette liste.\n\nCliquez sur la croix pour fermer la vue agrandie et revenir à l’espace Bilans/Rapports."),
        "assessmentChartImageService_insufficientPoints":
            MessageLookupByLibrary.simpleMessage(
                "Une série graphique doit contenir au moins deux points."),
        "assessmentChartImageService_pngConversionError":
            MessageLookupByLibrary.simpleMessage(
                "Impossible de convertir le graphique en image PNG."),
        "assessmentDocumentDataBuilder_female":
            MessageLookupByLibrary.simpleMessage("Féminin"),
        "assessmentDocumentDataBuilder_male":
            MessageLookupByLibrary.simpleMessage("Masculin"),
        "assessmentDocumentDataBuilder_patient": m0,
        "assessmentDocxService_age":
            MessageLookupByLibrary.simpleMessage("Âge"),
        "assessmentDocxService_assessment":
            MessageLookupByLibrary.simpleMessage("Bilan"),
        "assessmentDocxService_attachment":
            MessageLookupByLibrary.simpleMessage(
                "Pathologie lors du rattachement"),
        "assessmentDocxService_author":
            MessageLookupByLibrary.simpleMessage("Rédacteur"),
        "assessmentDocxService_centimetres": m1,
        "assessmentDocxService_chart":
            MessageLookupByLibrary.simpleMessage("Graphique"),
        "assessmentDocxService_declared":
            MessageLookupByLibrary.simpleMessage("Âge déclaré lors du test"),
        "assessmentDocxService_diagnosis":
            MessageLookupByLibrary.simpleMessage("Pathologie lors du test"),
        "assessmentDocxService_dominance":
            MessageLookupByLibrary.simpleMessage("Côté dominant"),
        "assessmentDocxService_establishment":
            MessageLookupByLibrary.simpleMessage("Établissement"),
        "assessmentDocxService_firstname":
            MessageLookupByLibrary.simpleMessage("Prénom"),
        "assessmentDocxService_height":
            MessageLookupByLibrary.simpleMessage("Taille"),
        "assessmentDocxService_information":
            MessageLookupByLibrary.simpleMessage("Informations sur le patient"),
        "assessmentDocxService_kilograms": m2,
        "assessmentDocxService_notes": MessageLookupByLibrary.simpleMessage(
            "Notes de suivi sélectionnées"),
        "assessmentDocxService_opened":
            MessageLookupByLibrary.simpleMessage("Prise en charge ouverte le"),
        "assessmentDocxService_pathology":
            MessageLookupByLibrary.simpleMessage("Pathologie"),
        "assessmentDocxService_patient":
            MessageLookupByLibrary.simpleMessage("Patient"),
        "assessmentDocxService_performed":
            MessageLookupByLibrary.simpleMessage("Réalisé le"),
        "assessmentDocxService_practitioner":
            MessageLookupByLibrary.simpleMessage("Kiné référent"),
        "assessmentDocxService_printed":
            MessageLookupByLibrary.simpleMessage("Imprimé le"),
        "assessmentDocxService_profession":
            MessageLookupByLibrary.simpleMessage("Profession"),
        "assessmentDocxService_recipients":
            MessageLookupByLibrary.simpleMessage("Destinataire(s)"),
        "assessmentDocxService_results":
            MessageLookupByLibrary.simpleMessage("Résultats des tests"),
        "assessmentDocxService_sex":
            MessageLookupByLibrary.simpleMessage("Sexe"),
        "assessmentDocxService_sport":
            MessageLookupByLibrary.simpleMessage("Activité sportive"),
        "assessmentDocxService_surname":
            MessageLookupByLibrary.simpleMessage("Nom"),
        "assessmentDocxService_title":
            MessageLookupByLibrary.simpleMessage("BILAN"),
        "assessmentDocxService_weight":
            MessageLookupByLibrary.simpleMessage("Poids"),
        "assessmentDocxService_years": m3,
        "assessmentDraft_help": MessageLookupByLibrary.simpleMessage(
            "Le texte affiché correspond à un travail en cours sauvegardé automatiquement. Vous pouvez le conserver, le modifier ou le supprimer avant d’enregistrer votre bilan."),
        "assessmentDraft_helpTitle": MessageLookupByLibrary.simpleMessage(
            "Comprendre le brouillon du bilan"),
        "assessmentHistory_help": MessageLookupByLibrary.simpleMessage(
            "Cette vue présente les bilans enregistrés pour la prise en charge, avec leur titre et leur date.\n\nLes actions de chaque ligne permettent de modifier un bilan, de le dupliquer ou de le déplacer vers les documents archivés.\n\nLorsqu’un bilan est ouvert en modification, utilisez l’action de mise à jour pour enregistrer vos changements. Les commandes disponibles permettent également d’annuler les modifications ou de revenir au brouillon.\n\nLe déplacement vers les documents archivés n’est pas une suppression définitive.\n\nCliquez sur la croix pour fermer la vue agrandie et revenir à l’espace Bilans/Rapports."),
        "backupArchive_authorizeFolder": m4,
        "backupArchive_busy": MessageLookupByLibrary.simpleMessage(
            "Une sauvegarde ou une restauration est déjà en cours.\""),
        "backupArchive_chooseFile":
            MessageLookupByLibrary.simpleMessage("Ouvrir une sauvegarde…"),
        "backupArchive_legacy": MessageLookupByLibrary.simpleMessage(
            "Cette ancienne sauvegarde contient uniquement la base. Les fichiers des dossiers patients n’ont pas été restaurés."),
        "backupArchive_restoreFolder": m5,
        "backupArchive_resultTitle":
            MessageLookupByLibrary.simpleMessage("Résultat de la restauration"),
        "backupArchive_safetyCopies": MessageLookupByLibrary.simpleMessage(
            "Copies de sécurité conservées :"),
        "backupArchive_working": MessageLookupByLibrary.simpleMessage(
            "Sauvegarde ou restauration en cours… Veuillez patienter."),
        "backupHistory_cancel": MessageLookupByLibrary.simpleMessage("Annuler"),
        "backupHistory_empty": MessageLookupByLibrary.simpleMessage(
            "Aucune sauvegarde enregistrée."),
        "backupHistory_fileSize": m6,
        "backupHistory_help": MessageLookupByLibrary.simpleMessage(
            "Cet écran présente les sauvegardes enregistrées dans Companion. Chaque ligne indique le nom du fichier, sa date de création, sa taille et son emplacement.\n\nLe bouton « Restaurer » permet de remplacer la base actuelle par celle de la sauvegarde choisie. Les données ajoutées ou modifiées après cette sauvegarde ne seront donc pas présentes dans la base restaurée.\n\nVérifiez la date de la sauvegarde et lisez le message de confirmation avant de poursuivre. Une copie de sécurité de la base actuelle est créée avant son remplacement.\n\nLe fichier de sauvegarde doit toujours être accessible à l’emplacement indiqué. S’il a été déplacé ou supprimé, la restauration ne pourra pas être effectuée.\n\nPour créer une nouvelle sauvegarde, utilisez l’action « Créer une sauvegarde » sur la page d’accueil."),
        "backupHistory_restore":
            MessageLookupByLibrary.simpleMessage("Restaurer"),
        "backupHistory_restoreTitle": MessageLookupByLibrary.simpleMessage(
            "Restaurer cette sauvegarde ?"),
        "backupHistory_restoreWarning": MessageLookupByLibrary.simpleMessage(
            "Cette opération remplacera totalement la base actuelle.\n\nUne sauvegarde automatique de sécurité sera créée avant restauration.\n\nContinuer ?"),
        "backupHistory_title":
            MessageLookupByLibrary.simpleMessage("Historique des sauvegardes"),
        "bodymap_help": MessageLookupByLibrary.simpleMessage(
            "La carte des douleurs permet de repérer les zones douloureuses du patient pour l’épisode de soins en cours.\n\nChoisissez une vue, puis cliquez sur une zone de la silhouette ou sélectionnez-la dans la liste. Vous pouvez ajouter une observation et, si nécessaire, une intensité de 0 à 10. Utilisez la corbeille pour retirer une zone du relevé.\n\nCliquez sur « Enregistrer » pour conserver votre relevé dans Companion. Lorsque vous quittez l’écran avec des modifications non enregistrées, un choix vous permet de les enregistrer ou de les abandonner.\n\n« Exporter les deux cartes » crée une image PNG à l’emplacement choisi sur votre ordinateur. Cet export ne remplace pas l’enregistrement du relevé.\n\nCe module est une première proposition, destinée à évoluer selon vos retours. Testez-le dans votre pratique et indiquez les possibilités que vous souhaiteriez voir ajoutées ou améliorées."),
        "bodymap_title":
            MessageLookupByLibrary.simpleMessage("Carte des douleurs"),
        "careEpisodeDetail_abakOrigin":
            MessageLookupByLibrary.simpleMessage("Origine ABAK"),
        "careEpisodeDetail_detail_de_la_prise_en_charge":
            MessageLookupByLibrary.simpleMessage(
                "Détail de la prise en charge"),
        "careEpisodeDetail_evolution":
            MessageLookupByLibrary.simpleMessage("Évolution"),
        "careEpisodeDetail_noResult": MessageLookupByLibrary.simpleMessage(
            "Aucun résultat rattaché pour le moment."),
        "careEpisodeDetail_pathology":
            MessageLookupByLibrary.simpleMessage("Pathologie"),
        "careEpisodeDetail_reportsWorkspaceTooltip":
            MessageLookupByLibrary.simpleMessage(
                "Nouvelle interface bilans et rapports"),
        "careEpisodeDetail_results":
            MessageLookupByLibrary.simpleMessage("Résultats ABAK"),
        "careEpisodeDetail_score":
            MessageLookupByLibrary.simpleMessage("Score"),
        "careEpisodePanel_archive":
            MessageLookupByLibrary.simpleMessage("Archiver"),
        "careEpisodePanel_archiveCareEpisode":
            MessageLookupByLibrary.simpleMessage("Archiver la prise en charge"),
        "careEpisodePanel_archiveCareEpisodeError":
            MessageLookupByLibrary.simpleMessage(
                "Impossible d’archiver la prise en charge. Veuillez réessayer."),
        "careEpisodePanel_archiveCareEpisodeMessage":
            MessageLookupByLibrary.simpleMessage(
                "Cette prise en charge sera retirée de la liste. Ses données seront conservées par archivage."),
        "careEpisodePanel_archiveCareEpisodeTitle":
            MessageLookupByLibrary.simpleMessage(
                "Archiver cette prise en charge ?"),
        "careEpisodePanel_archivedCareEpisodes":
            MessageLookupByLibrary.simpleMessage("Prises en charge archivées"),
        "careEpisodePanel_archivedCareEpisodesHelp":
            MessageLookupByLibrary.simpleMessage(
                "Vous trouvez ici vos épisodes de soins archivés."),
        "careEpisodePanel_archivedOn": m7,
        "careEpisodePanel_careEpisodeArchived":
            MessageLookupByLibrary.simpleMessage("Prise en charge archivée."),
        "careEpisodePanel_careEpisodeOpenedIn": m8,
        "careEpisodePanel_careEpisodeRestored":
            MessageLookupByLibrary.simpleMessage("Prise en charge restaurée."),
        "careEpisodePanel_careEpisodes":
            MessageLookupByLibrary.simpleMessage("Prises en charge"),
        "careEpisodePanel_choose":
            MessageLookupByLibrary.simpleMessage("Choisir"),
        "careEpisodePanel_edit":
            MessageLookupByLibrary.simpleMessage("Modifier"),
        "careEpisodePanel_loadCareEpisodesError":
            MessageLookupByLibrary.simpleMessage(
                "Impossible de charger les prises en charge."),
        "careEpisodePanel_newCareEpisode":
            MessageLookupByLibrary.simpleMessage("Nouvelle prise en charge"),
        "careEpisodePanel_noArchivedCareEpisodes":
            MessageLookupByLibrary.simpleMessage(
                "Aucune prise en charge archivée pour ce patient."),
        "careEpisodePanel_noCareEpisodes": MessageLookupByLibrary.simpleMessage(
            "Aucune prise en charge créée pour ce patient."),
        "careEpisodePanel_prescribingDoctor":
            MessageLookupByLibrary.simpleMessage("Médecin prescripteur"),
        "careEpisodePanel_restore":
            MessageLookupByLibrary.simpleMessage("Restaurer"),
        "careEpisodePanel_restoreCareEpisodeError":
            MessageLookupByLibrary.simpleMessage(
                "Impossible de restaurer la prise en charge. Veuillez réessayer."),
        "careEpisodeReportsWorkspaceScreen_add":
            MessageLookupByLibrary.simpleMessage("Ajouter"),
        "careEpisodeReportsWorkspaceScreen_append":
            MessageLookupByLibrary.simpleMessage("Ajouter à la suite"),
        "careEpisodeReportsWorkspaceScreen_archiveAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Impossible de mettre le bilan à la corbeille."),
        "careEpisodeReportsWorkspaceScreen_archiveAssessmentMessage": m9,
        "careEpisodeReportsWorkspaceScreen_archiveReportError":
            MessageLookupByLibrary.simpleMessage(
                "Impossible de mettre le rapport à la corbeille."),
        "careEpisodeReportsWorkspaceScreen_archiveReportMessage": m10,
        "careEpisodeReportsWorkspaceScreen_assessmentFileName": m11,
        "careEpisodeReportsWorkspaceScreen_assessmentLabel":
            MessageLookupByLibrary.simpleMessage("bilan"),
        "careEpisodeReportsWorkspaceScreen_assessmentNotFound":
            MessageLookupByLibrary.simpleMessage("Le bilan est introuvable."),
        "careEpisodeReportsWorkspaceScreen_assessmentReadyMessage":
            MessageLookupByLibrary.simpleMessage(
                "Votre bilan est prêt. Le DOCX regroupera les informations saisies et les éléments sélectionnés."),
        "careEpisodeReportsWorkspaceScreen_assessmentTitle":
            MessageLookupByLibrary.simpleMessage("Titre du bilan"),
        "careEpisodeReportsWorkspaceScreen_assessmentsAndReports":
            MessageLookupByLibrary.simpleMessage("Bilans et rapports"),
        "careEpisodeReportsWorkspaceScreen_author":
            MessageLookupByLibrary.simpleMessage("Rédacteur"),
        "careEpisodeReportsWorkspaceScreen_authorizeDirectory":
            MessageLookupByLibrary.simpleMessage("Autoriser un dossier"),
        "careEpisodeReportsWorkspaceScreen_cancel":
            MessageLookupByLibrary.simpleMessage("Annuler"),
        "careEpisodeReportsWorkspaceScreen_cancelChangesError":
            MessageLookupByLibrary.simpleMessage(
                "Impossible d’annuler les modifications."),
        "careEpisodeReportsWorkspaceScreen_cancelReportChangesError":
            MessageLookupByLibrary.simpleMessage(
                "Impossible d’annuler les modifications du rapport."),
        "careEpisodeReportsWorkspaceScreen_close":
            MessageLookupByLibrary.simpleMessage("Fermer"),
        "careEpisodeReportsWorkspaceScreen_confirm":
            MessageLookupByLibrary.simpleMessage("Valider"),
        "careEpisodeReportsWorkspaceScreen_copyTitle": m12,
        "careEpisodeReportsWorkspaceScreen_createNew":
            MessageLookupByLibrary.simpleMessage("Créer un nouveau"),
        "careEpisodeReportsWorkspaceScreen_deleteAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Impossible de supprimer définitivement le bilan."),
        "careEpisodeReportsWorkspaceScreen_deleteAssessmentMessage": m13,
        "careEpisodeReportsWorkspaceScreen_deleteAssessmentTitle":
            MessageLookupByLibrary.simpleMessage(
                "Supprimer définitivement le bilan ?"),
        "careEpisodeReportsWorkspaceScreen_deletePermanently":
            MessageLookupByLibrary.simpleMessage("Supprimer définitivement"),
        "careEpisodeReportsWorkspaceScreen_deleteReportError":
            MessageLookupByLibrary.simpleMessage(
                "Impossible de supprimer définitivement le rapport."),
        "careEpisodeReportsWorkspaceScreen_deleteReportMessage": m14,
        "careEpisodeReportsWorkspaceScreen_deleteReportTitle":
            MessageLookupByLibrary.simpleMessage(
                "Supprimer définitivement le rapport ?"),
        "careEpisodeReportsWorkspaceScreen_directoryAccessMessage": m15,
        "careEpisodeReportsWorkspaceScreen_duplicate":
            MessageLookupByLibrary.simpleMessage("Dupliquer"),
        "careEpisodeReportsWorkspaceScreen_duplicateAssessment":
            MessageLookupByLibrary.simpleMessage("Dupliquer le bilan"),
        "careEpisodeReportsWorkspaceScreen_duplicateAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Impossible de dupliquer le bilan."),
        "careEpisodeReportsWorkspaceScreen_duplicateReport":
            MessageLookupByLibrary.simpleMessage("Dupliquer le rapport"),
        "careEpisodeReportsWorkspaceScreen_duplicateReportError":
            MessageLookupByLibrary.simpleMessage(
                "Impossible de dupliquer le rapport."),
        "careEpisodeReportsWorkspaceScreen_existingAssessmentDocx":
            MessageLookupByLibrary.simpleMessage(
                "Un DOCX est déjà associé à ce bilan. Voulez-vous remplacer le fichier existant ou créer un nouveau fichier ?"),
        "careEpisodeReportsWorkspaceScreen_existingReportDocx":
            MessageLookupByLibrary.simpleMessage(
                "Un DOCX est déjà associé à ce rapport. Voulez-vous remplacer le fichier existant ou créer un nouveau fichier ?"),
        "careEpisodeReportsWorkspaceScreen_existingTemplateDraftMessage": m16,
        "careEpisodeReportsWorkspaceScreen_generate":
            MessageLookupByLibrary.simpleMessage("Générer"),
        "careEpisodeReportsWorkspaceScreen_generateDocx":
            MessageLookupByLibrary.simpleMessage("Générer le DOCX"),
        "careEpisodeReportsWorkspaceScreen_insertTextMessage": m17,
        "careEpisodeReportsWorkspaceScreen_managePractitioners":
            MessageLookupByLibrary.simpleMessage("Gérer les kinés"),
        "careEpisodeReportsWorkspaceScreen_managePrescribingDoctors":
            MessageLookupByLibrary.simpleMessage(
                "Gérer les médecins prescripteurs"),
        "careEpisodeReportsWorkspaceScreen_moveToTrash":
            MessageLookupByLibrary.simpleMessage("Mettre à la corbeille"),
        "careEpisodeReportsWorkspaceScreen_newAssessment":
            MessageLookupByLibrary.simpleMessage("Nouveau bilan"),
        "careEpisodeReportsWorkspaceScreen_newAssessmentTitle":
            MessageLookupByLibrary.simpleMessage("Titre du nouveau bilan"),
        "careEpisodeReportsWorkspaceScreen_newDocument": m18,
        "careEpisodeReportsWorkspaceScreen_newReport":
            MessageLookupByLibrary.simpleMessage("Nouveau rapport"),
        "careEpisodeReportsWorkspaceScreen_newReportTitle":
            MessageLookupByLibrary.simpleMessage("Titre du nouveau rapport"),
        "careEpisodeReportsWorkspaceScreen_note":
            MessageLookupByLibrary.simpleMessage("Note"),
        "careEpisodeReportsWorkspaceScreen_openReportDraftError":
            MessageLookupByLibrary.simpleMessage(
                "Impossible d’ouvrir le brouillon du rapport."),
        "careEpisodeReportsWorkspaceScreen_openReportError":
            MessageLookupByLibrary.simpleMessage(
                "Impossible d’ouvrir le rapport."),
        "careEpisodeReportsWorkspaceScreen_prescribingDoctor":
            MessageLookupByLibrary.simpleMessage("Médecin prescripteur"),
        "careEpisodeReportsWorkspaceScreen_recipients":
            MessageLookupByLibrary.simpleMessage("Destinataire(s)"),
        "careEpisodeReportsWorkspaceScreen_referringPractitioner":
            MessageLookupByLibrary.simpleMessage("Kiné référent"),
        "careEpisodeReportsWorkspaceScreen_replace":
            MessageLookupByLibrary.simpleMessage("Remplacer"),
        "careEpisodeReportsWorkspaceScreen_reportFileName": m19,
        "careEpisodeReportsWorkspaceScreen_reportLabel":
            MessageLookupByLibrary.simpleMessage("rapport"),
        "careEpisodeReportsWorkspaceScreen_reportNotFound":
            MessageLookupByLibrary.simpleMessage("Le rapport est introuvable."),
        "careEpisodeReportsWorkspaceScreen_reportOptionsTitle":
            MessageLookupByLibrary.simpleMessage("Options du rapport"),
        "careEpisodeReportsWorkspaceScreen_reportReadyMessage":
            MessageLookupByLibrary.simpleMessage(
                "Votre rapport est prêt. Le DOCX regroupera les informations du patient, du rédacteur et du correspondant."),
        "careEpisodeReportsWorkspaceScreen_reportTitle":
            MessageLookupByLibrary.simpleMessage("Titre du rapport"),
        "careEpisodeReportsWorkspaceScreen_restoreAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Impossible de restaurer le bilan"),
        "careEpisodeReportsWorkspaceScreen_restoreReportError":
            MessageLookupByLibrary.simpleMessage(
                "Impossible de restaurer le rapport."),
        "careEpisodeReportsWorkspaceScreen_resumeAssessmentDraftMessage":
            MessageLookupByLibrary.simpleMessage(
                "Un travail en cours a déjà été sauvegardé automatiquement.<br><br>Souhaitez-vous reprendre ce brouillon ou commencer un nouveau bilan ?"),
        "careEpisodeReportsWorkspaceScreen_resumeDraft":
            MessageLookupByLibrary.simpleMessage("Reprendre le brouillon"),
        "careEpisodeReportsWorkspaceScreen_resumeReportDraftMessage":
            MessageLookupByLibrary.simpleMessage(
                "Un travail en cours a déjà été sauvegardé automatiquement.<br><br>Souhaitez-vous reprendre ce brouillon ou commencer un nouveau rapport ?"),
        "careEpisodeReportsWorkspaceScreen_returnToDraftError":
            MessageLookupByLibrary.simpleMessage(
                "Impossible de revenir au brouillon."),
        "careEpisodeReportsWorkspaceScreen_returnToReportDraftError":
            MessageLookupByLibrary.simpleMessage(
                "Impossible de revenir au brouillon du rapport."),
        "careEpisodeReportsWorkspaceScreen_save":
            MessageLookupByLibrary.simpleMessage("Enregistrer"),
        "careEpisodeReportsWorkspaceScreen_saveAssessment":
            MessageLookupByLibrary.simpleMessage("Enregistrer le bilan"),
        "careEpisodeReportsWorkspaceScreen_saveAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Impossible d’enregistrer le bilan."),
        "careEpisodeReportsWorkspaceScreen_saveNoteSelectionError":
            MessageLookupByLibrary.simpleMessage(
                "Impossible d’enregistrer la sélection de la note."),
        "careEpisodeReportsWorkspaceScreen_saveReport":
            MessageLookupByLibrary.simpleMessage("Enregistrer le rapport"),
        "careEpisodeReportsWorkspaceScreen_saveReportError":
            MessageLookupByLibrary.simpleMessage(
                "Impossible d’enregistrer le rapport."),
        "careEpisodeReportsWorkspaceScreen_saveTestSelectionError":
            MessageLookupByLibrary.simpleMessage(
                "Impossible d’enregistrer la sélection du test."),
        "careEpisodeReportsWorkspaceScreen_showPrescriber":
            MessageLookupByLibrary.simpleMessage("Afficher le prescripteur"),
        "careEpisodeReportsWorkspaceScreen_showReferringPractitioner":
            MessageLookupByLibrary.simpleMessage("Afficher le kiné référent"),
        "careEpisodeReportsWorkspaceScreen_soapEditorHint":
            MessageLookupByLibrary.simpleMessage(
                "Zone de rédaction du bilan SOAP.<br><br>S — Subjectif<br><br>O — Objectif<br><br>A — Analyse<br><br>P — Plan"),
        "careEpisodeReportsWorkspaceScreen_title":
            MessageLookupByLibrary.simpleMessage("Titre"),
        "careEpisodeReportsWorkspaceScreen_update":
            MessageLookupByLibrary.simpleMessage("Mettre à jour"),
        "careEpisodeReportsWorkspaceScreen_updateAssessment":
            MessageLookupByLibrary.simpleMessage("Mettre à jour le bilan"),
        "careEpisodeReportsWorkspaceScreen_updateAssessmentError":
            MessageLookupByLibrary.simpleMessage(
                "Impossible de mettre à jour le bilan."),
        "careEpisodeReportsWorkspaceScreen_updateReport":
            MessageLookupByLibrary.simpleMessage("Mettre à jour le rapport"),
        "careEpisodeReportsWorkspaceScreen_updateReportError":
            MessageLookupByLibrary.simpleMessage(
                "Impossible de mettre à jour le rapport."),
        "careEpisodeReportsWorkspaceScreen_wordDocumentCreated": m20,
        "careEpisodeReportsWorkspaceScreen_wordDocumentCreationError": m21,
        "careEpisodeReportsWorkspaceScreen_workspaceTitle": m22,
        "careEpisodeReportsWorkspace_addFollowUpNote":
            MessageLookupByLibrary.simpleMessage("Ajouter une note de suivi"),
        "careEpisodeReportsWorkspace_archived":
            MessageLookupByLibrary.simpleMessage("archivé"),
        "careEpisodeReportsWorkspace_archivedDocuments":
            MessageLookupByLibrary.simpleMessage("Documents archivés"),
        "careEpisodeReportsWorkspace_archivedDocumentsCount":
            MessageLookupByLibrary.simpleMessage("Documents archivés"),
        "careEpisodeReportsWorkspace_assessment":
            MessageLookupByLibrary.simpleMessage("Bilan"),
        "careEpisodeReportsWorkspace_assessmentCount":
            MessageLookupByLibrary.simpleMessage("Nombre de bilans"),
        "careEpisodeReportsWorkspace_assessmentHistory":
            MessageLookupByLibrary.simpleMessage("Historique des bilans"),
        "careEpisodeReportsWorkspace_assessmentsLoadError":
            MessageLookupByLibrary.simpleMessage(
                "Impossible de charger les bilans."),
        "careEpisodeReportsWorkspace_cancel":
            MessageLookupByLibrary.simpleMessage("Annuler"),
        "careEpisodeReportsWorkspace_cancelChanges":
            MessageLookupByLibrary.simpleMessage("Annuler les modifications"),
        "careEpisodeReportsWorkspace_createOrResumeAssessment":
            MessageLookupByLibrary.simpleMessage("Créer ou reprendre un bilan"),
        "careEpisodeReportsWorkspace_createOrResumeReport":
            MessageLookupByLibrary.simpleMessage(
                "Créer ou reprendre un rapport"),
        "careEpisodeReportsWorkspace_date":
            MessageLookupByLibrary.simpleMessage("Date"),
        "careEpisodeReportsWorkspace_deletePermanently":
            MessageLookupByLibrary.simpleMessage("Supprimer définitivement"),
        "careEpisodeReportsWorkspace_duplicate":
            MessageLookupByLibrary.simpleMessage("Dupliquer"),
        "careEpisodeReportsWorkspace_edit":
            MessageLookupByLibrary.simpleMessage("Modifier"),
        "careEpisodeReportsWorkspace_editReferringPractitioner":
            MessageLookupByLibrary.simpleMessage("Modifier le kiné référent"),
        "careEpisodeReportsWorkspace_episodeDocuments":
            MessageLookupByLibrary.simpleMessage(
                "Documents de la prise en charge"),
        "careEpisodeReportsWorkspace_episodeSummary":
            MessageLookupByLibrary.simpleMessage("Résumé de l’épisode"),
        "careEpisodeReportsWorkspace_expand":
            MessageLookupByLibrary.simpleMessage("Agrandir"),
        "careEpisodeReportsWorkspace_expandEditor":
            MessageLookupByLibrary.simpleMessage(
                "Agrandir la zone de rédaction"),
        "careEpisodeReportsWorkspace_followUpNoteDefaultTitle":
            MessageLookupByLibrary.simpleMessage("Note de suivi"),
        "careEpisodeReportsWorkspace_followUpNotes":
            MessageLookupByLibrary.simpleMessage("Notes de suivi"),
        "careEpisodeReportsWorkspace_followUpNotesLoadError":
            MessageLookupByLibrary.simpleMessage(
                "Impossible de charger les notes de suivi."),
        "careEpisodeReportsWorkspace_include":
            MessageLookupByLibrary.simpleMessage("Inclure"),
        "careEpisodeReportsWorkspace_latestTests":
            MessageLookupByLibrary.simpleMessage(
                "Tests réalisés (dernier résultat)"),
        "careEpisodeReportsWorkspace_loading":
            MessageLookupByLibrary.simpleMessage("Chargement…"),
        "careEpisodeReportsWorkspace_moveToTrash":
            MessageLookupByLibrary.simpleMessage("Mettre à la corbeille"),
        "careEpisodeReportsWorkspace_name":
            MessageLookupByLibrary.simpleMessage("Nom"),
        "careEpisodeReportsWorkspace_newAssessment":
            MessageLookupByLibrary.simpleMessage("Bilan (nouveau)"),
        "careEpisodeReportsWorkspace_noAssessments":
            MessageLookupByLibrary.simpleMessage("Aucun bilan enregistré."),
        "careEpisodeReportsWorkspace_noDocument":
            MessageLookupByLibrary.simpleMessage("Aucun document"),
        "careEpisodeReportsWorkspace_noFollowUpNotes":
            MessageLookupByLibrary.simpleMessage("Aucune note de suivi."),
        "careEpisodeReportsWorkspace_noReports":
            MessageLookupByLibrary.simpleMessage("Aucun rapport enregistré."),
        "careEpisodeReportsWorkspace_noTests":
            MessageLookupByLibrary.simpleMessage(
                "Aucun test réalisé pour cet épisode."),
        "careEpisodeReportsWorkspace_notProvided":
            MessageLookupByLibrary.simpleMessage("Non renseigné"),
        "careEpisodeReportsWorkspace_note":
            MessageLookupByLibrary.simpleMessage("Note"),
        "careEpisodeReportsWorkspace_pathology":
            MessageLookupByLibrary.simpleMessage("Pathologie"),
        "careEpisodeReportsWorkspace_referringPractitioner":
            MessageLookupByLibrary.simpleMessage("Kiné référent"),
        "careEpisodeReportsWorkspace_referringPractitionerHistory":
            MessageLookupByLibrary.simpleMessage(
                "Historique des kinés référents"),
        "careEpisodeReportsWorkspace_report":
            MessageLookupByLibrary.simpleMessage("Rapport"),
        "careEpisodeReportsWorkspace_reportCount":
            MessageLookupByLibrary.simpleMessage("Nombre de rapports"),
        "careEpisodeReportsWorkspace_reportHistory":
            MessageLookupByLibrary.simpleMessage("Historique des rapports"),
        "careEpisodeReportsWorkspace_reportsLoadError":
            MessageLookupByLibrary.simpleMessage(
                "Impossible de charger les rapports."),
        "careEpisodeReportsWorkspace_restore":
            MessageLookupByLibrary.simpleMessage("Restaurer"),
        "careEpisodeReportsWorkspace_result":
            MessageLookupByLibrary.simpleMessage("Résultat"),
        "careEpisodeReportsWorkspace_returnToDraft":
            MessageLookupByLibrary.simpleMessage("Retour au brouillon"),
        "careEpisodeReportsWorkspace_returnToReportDraft":
            MessageLookupByLibrary.simpleMessage(
                "Retour au brouillon du rapport"),
        "careEpisodeReportsWorkspace_saveAssessment":
            MessageLookupByLibrary.simpleMessage("Enregistrer le bilan"),
        "careEpisodeReportsWorkspace_saveReport":
            MessageLookupByLibrary.simpleMessage("Enregistrer le rapport"),
        "careEpisodeReportsWorkspace_soapEditorHint":
            MessageLookupByLibrary.simpleMessage(
                "Zone de rédaction du bilan SOAP.\n\nS — Subjectif\n\nO — Objectif\n\nA — Analyse\n\nP — Plan"),
        "careEpisodeReportsWorkspace_test":
            MessageLookupByLibrary.simpleMessage("Test"),
        "careEpisodeReportsWorkspace_testCount":
            MessageLookupByLibrary.simpleMessage("Nombre de tests"),
        "careEpisodeReportsWorkspace_testsLoadError":
            MessageLookupByLibrary.simpleMessage(
                "Impossible de charger les tests."),
        "careEpisodeReportsWorkspace_title":
            MessageLookupByLibrary.simpleMessage("Titre"),
        "careEpisodeReportsWorkspace_trashLoadError":
            MessageLookupByLibrary.simpleMessage(
                "Impossible de charger la corbeille."),
        "careEpisodeReportsWorkspace_updateAssessment":
            MessageLookupByLibrary.simpleMessage("Mettre à jour le bilan"),
        "careEpisodeReportsWorkspace_updateReport":
            MessageLookupByLibrary.simpleMessage("Mettre à jour le rapport"),
        "careEpisode_assessment":
            MessageLookupByLibrary.simpleMessage("Aucune analyse clinique."),
        "careEpisode_evaluation":
            MessageLookupByLibrary.simpleMessage("Aucune évaluation clinique."),
        "careEpisode_report":
            MessageLookupByLibrary.simpleMessage("Aucun compte rendu initial."),
        "careEpisode_title":
            MessageLookupByLibrary.simpleMessage("Prise en charge"),
        "careEpisode_treatment":
            MessageLookupByLibrary.simpleMessage("Aucun plan de traitement."),
        "clinicalDocuments_help": MessageLookupByLibrary.simpleMessage(
            "Cet écran permet de préparer et d’enregistrer les bilans et rapports liés à la prise en charge.\n\nPour un bilan, vous pouvez rédiger le texte principal, sélectionner les résultats de tests et les notes de suivi à inclure, puis générer un document DOCX une fois le bilan enregistré.\n\nLes brouillons sont sauvegardés automatiquement tant qu’ils ne sont pas enregistrés comme bilan ou rapport.\n\nL’historique permet de retrouver les bilans et rapports déjà enregistrés."),
        "clinicalDocuments_title":
            MessageLookupByLibrary.simpleMessage("Bilans et rapports"),
        "close": MessageLookupByLibrary.simpleMessage("Fermer"),
        "contactFormTemplateDiagnostic_category":
            MessageLookupByLibrary.simpleMessage("Catégorie"),
        "contactFormTemplateDiagnostic_defaultTemplate":
            MessageLookupByLibrary.simpleMessage("Modèle par défaut"),
        "contactFormTemplateDiagnostic_error":
            MessageLookupByLibrary.simpleMessage("Erreur"),
        "contactFormTemplateDiagnostic_fields":
            MessageLookupByLibrary.simpleMessage("Champs"),
        "contactFormTemplateDiagnostic_no":
            MessageLookupByLibrary.simpleMessage("Non"),
        "contactFormTemplateDiagnostic_noData":
            MessageLookupByLibrary.simpleMessage("Aucune donnée à afficher."),
        "contactFormTemplateDiagnostic_noTemplate":
            MessageLookupByLibrary.simpleMessage(
                "Aucun modèle de fiche d’entretien initial trouvé."),
        "contactFormTemplateDiagnostic_notDefined":
            MessageLookupByLibrary.simpleMessage("Non définie"),
        "contactFormTemplateDiagnostic_order":
            MessageLookupByLibrary.simpleMessage("Ordre"),
        "contactFormTemplateDiagnostic_practitioner":
            MessageLookupByLibrary.simpleMessage("Praticien"),
        "contactFormTemplateDiagnostic_refresh":
            MessageLookupByLibrary.simpleMessage("Actualiser"),
        "contactFormTemplateDiagnostic_required":
            MessageLookupByLibrary.simpleMessage("Obligatoire"),
        "contactFormTemplateDiagnostic_systemTemplate":
            MessageLookupByLibrary.simpleMessage("Modèle système"),
        "contactFormTemplateDiagnostic_templateId":
            MessageLookupByLibrary.simpleMessage("ID modèle"),
        "contactFormTemplateDiagnostic_title":
            MessageLookupByLibrary.simpleMessage(
                "Diagnostic fiche d’entretien"),
        "contactFormTemplateDiagnostic_type":
            MessageLookupByLibrary.simpleMessage("Type"),
        "contactFormTemplateDiagnostic_yes":
            MessageLookupByLibrary.simpleMessage("Oui"),
        "dashboardTitle": MessageLookupByLibrary.simpleMessage(
            "Station clinique locale ABAK"),
        "desktopAddress": MessageLookupByLibrary.simpleMessage("Adresse"),
        "desktopPort": MessageLookupByLibrary.simpleMessage("Port"),
        "deviceForm_associatedPractitioner":
            MessageLookupByLibrary.simpleMessage("Praticien associé"),
        "deviceForm_cancel": MessageLookupByLibrary.simpleMessage("Annuler"),
        "deviceForm_contextName":
            MessageLookupByLibrary.simpleMessage("Nouvel appareil"),
        "deviceForm_create": MessageLookupByLibrary.simpleMessage("Créer"),
        "deviceForm_deviceName":
            MessageLookupByLibrary.simpleMessage("Nom de l’appareil"),
        "deviceForm_deviceNameHint":
            MessageLookupByLibrary.simpleMessage("iPhone Claire, Pixel Marc…"),
        "deviceForm_deviceNameRequired": MessageLookupByLibrary.simpleMessage(
            "Le nom de l’appareil est obligatoire"),
        "deviceForm_editDevice":
            MessageLookupByLibrary.simpleMessage("Modifier l’appareil"),
        "deviceForm_help": MessageLookupByLibrary.simpleMessage(
            "Cette fenêtre permet de créer ou de modifier la fiche d’un appareil dans Companion.\n\nSaisissez un nom permettant de reconnaître facilement le téléphone ou la tablette. Ce nom est obligatoire.\n\nSélectionnez la plateforme de l’appareil : iOS ou Android.\n\nVous pouvez associer l’appareil à un praticien de la liste ou choisir l’option d’appareil partagé pour ne pas l’affecter à un praticien particulier.\n\nCliquez sur « Créer » pour ajouter l’appareil ou sur « Enregistrer » pour valider les modifications. « Annuler » ferme la fenêtre sans appliquer les modifications.\n\nL’ouverture et la fermeture de cette aide conservent votre saisie dans le formulaire."),
        "deviceForm_loadingPractitionersError":
            MessageLookupByLibrary.simpleMessage(
                "Erreur lors du chargement des praticiens"),
        "deviceForm_newDevice":
            MessageLookupByLibrary.simpleMessage("Nouvel appareil"),
        "deviceForm_platform":
            MessageLookupByLibrary.simpleMessage("Plateforme"),
        "deviceForm_save": MessageLookupByLibrary.simpleMessage("Enregistrer"),
        "deviceForm_sharedDevice":
            MessageLookupByLibrary.simpleMessage("Aucun / appareil partagé"),
        "deviceList_active": MessageLookupByLibrary.simpleMessage("Actifs"),
        "deviceList_archive": MessageLookupByLibrary.simpleMessage("Archiver"),
        "deviceList_archiveConfirmation": m23,
        "deviceList_archiveTitle":
            MessageLookupByLibrary.simpleMessage("Archiver l’appareil"),
        "deviceList_archived": MessageLookupByLibrary.simpleMessage("Archivés"),
        "deviceList_archivedDevicesEmpty": MessageLookupByLibrary.simpleMessage(
            "La corbeille des appareils est vide pour le moment."),
        "deviceList_archivedOn":
            MessageLookupByLibrary.simpleMessage("Archivé le"),
        "deviceList_associatedPractitioner":
            MessageLookupByLibrary.simpleMessage("Praticien associé"),
        "deviceList_cancel": MessageLookupByLibrary.simpleMessage("Annuler"),
        "deviceList_contextComment": MessageLookupByLibrary.simpleMessage(
            "Cet écran montre la liste des appareils connectés à l’établissement"),
        "deviceList_contextName":
            MessageLookupByLibrary.simpleMessage("Liste des appareils"),
        "deviceList_edit": MessageLookupByLibrary.simpleMessage("Modifier"),
        "deviceList_error": MessageLookupByLibrary.simpleMessage("Erreur"),
        "deviceList_newDevice":
            MessageLookupByLibrary.simpleMessage("Nouvel appareil"),
        "deviceList_noArchivedDevices":
            MessageLookupByLibrary.simpleMessage("Aucun appareil archivé"),
        "deviceList_noPairedDevices":
            MessageLookupByLibrary.simpleMessage("Aucun appareil associé"),
        "deviceList_pairedDevicesExplanation":
            MessageLookupByLibrary.simpleMessage(
                "Les appareils ABAK associés à l’établissement apparaîtront ici."),
        "deviceList_platform":
            MessageLookupByLibrary.simpleMessage("Plateforme"),
        "deviceList_restore": MessageLookupByLibrary.simpleMessage("Restaurer"),
        "deviceList_showQrCode":
            MessageLookupByLibrary.simpleMessage("Afficher le QR Code"),
        "deviceList_title":
            MessageLookupByLibrary.simpleMessage("Liste des appareils"),
        "deviceQr_help": MessageLookupByLibrary.simpleMessage(
            "Cette fenêtre affiche le QR code d’identification de l’appareil, accompagné de son nom, du nom du cabinet et de sa plateforme.\n\nScannez ce QR code depuis ABAK Mobile pour identifier cet appareil dans cet établissement. Vérifiez que le nom affiché correspond bien au téléphone ou à la tablette concernée.\n\nCe QR code sert à identifier l’appareil ; son affichage ne déclenche pas de transfert de résultats.\n\nFermez cette fenêtre pour revenir à la liste des appareils."),
        "deviceQr_title": MessageLookupByLibrary.simpleMessage("Appareil ABAK"),
        "documentArchiveConfirm_help": MessageLookupByLibrary.simpleMessage(
            "La mise à la corbeille retire le bilan ou le rapport de son historique habituel.\n\nLe document reste conservé dans Companion. Vous pouvez le retrouver dans les documents archivés et le restaurer pour le faire réapparaître dans l’historique.\n\nLes fichiers DOCX déjà exportés sur votre ordinateur ne sont pas supprimés par cette action.\n\nCliquez sur « Mettre à la corbeille » pour confirmer, ou sur « Annuler » pour conserver le document dans l’historique."),
        "documentArchiveConfirm_title": MessageLookupByLibrary.simpleMessage(
            "Mettre le document à la corbeille ?"),
        "documentAuthor_help": MessageLookupByLibrary.simpleMessage(
            "Cette fenêtre permet de choisir le praticien désigné comme rédacteur du bilan ou du rapport en cours.\n\nSélectionnez le praticien dans la liste, puis cliquez sur « Valider » pour enregistrer cette association au document.\n\nCe choix concerne le rédacteur du document ; il ne modifie pas le praticien référent de l’épisode de soins.\n\n« Annuler » ferme la fenêtre sans changer le rédacteur."),
        "documentAuthor_title":
            MessageLookupByLibrary.simpleMessage("Choisir le rédacteur"),
        "documentDirectoryAccess_help": MessageLookupByLibrary.simpleMessage(
            "Companion ne peut pas accéder au dossier prévu pour enregistrer les documents, ou son autorisation d’accès doit être renouvelée.\n\nSi ce dossier se trouve sur un disque externe ou un emplacement réseau, vérifiez d’abord qu’il est connecté et accessible.\n\nCliquez sur « Autoriser un dossier », puis sélectionnez le dossier dans la fenêtre qui s’ouvre. Vous pouvez sélectionner le dossier habituel ou choisir une autre destination.\n\nLe dossier sélectionné est enregistré dans vos préférences pour les prochains exports. Les fichiers déjà présents dans l’ancien dossier ne sont pas déplacés.\n\n« Annuler » interrompt l’export en cours sans modifier votre bilan ou votre rapport."),
        "documentDirectoryAccess_title": MessageLookupByLibrary.simpleMessage(
            "Autoriser le dossier des documents"),
        "documentDocxExisting_help": MessageLookupByLibrary.simpleMessage(
            "Un fichier DOCX a déjà été associé à ce bilan ou à ce rapport.\n\n« Créer un nouveau » génère un nouveau fichier avec le contenu actuel du document. Si son nom existe déjà dans le dossier de destination, un numéro est ajouté pour conserver le fichier précédent. Le nouveau fichier devient celui associé au document dans Companion.\n\n« Remplacer » réécrit le fichier portant le nom associé au document dans le dossier de destination. Les éventuelles modifications apportées directement à ce fichier dans Word ou LibreOffice seront écrasées.\n\n« Annuler » abandonne l’export sans modifier les fichiers."),
        "documentDocxExisting_title":
            MessageLookupByLibrary.simpleMessage("Un DOCX existe déjà"),
        "documentDraftChoice_help": MessageLookupByLibrary.simpleMessage(
            "Un texte en cours de rédaction a déjà été sauvegardé automatiquement pour ce type de document.\n\n« Reprendre le brouillon » vous permet de retrouver ce texte et de poursuivre votre rédaction.\n\n« Nouveau bilan » ou « Nouveau rapport » efface le titre et le texte de ce brouillon pour recommencer. Le brouillon précédent n’est pas conservé comme un document séparé. Si vous souhaitez garder votre travail, reprenez-le et enregistrez-le avant de commencer un nouveau document.\n\n« Annuler » ferme cette fenêtre sans modifier le brouillon."),
        "documentDraftChoice_title":
            MessageLookupByLibrary.simpleMessage("Un brouillon existe"),
        "documentExpandedEditor_help": MessageLookupByLibrary.simpleMessage(
            "Cette fenêtre offre davantage d’espace pour rédiger ou modifier le texte du bilan ou du rapport en cours.\n\nVos modifications sont répercutées au fur et à mesure dans la zone de rédaction principale. Fermer la fenêtre ne les annule pas.\n\nCliquez sur la croix pour revenir à l’espace Bilans/Rapports, puis poursuivez la préparation et l’enregistrement de votre document.\n\nL’ouverture et la fermeture de cette aide conservent le texte saisi."),
        "documentExpandedEditor_helpTitle":
            MessageLookupByLibrary.simpleMessage(
                "Rédiger dans la vue agrandie"),
        "documentRecipient_help": MessageLookupByLibrary.simpleMessage(
            "Cette fenêtre permet de renseigner les destinataires du bilan ou du rapport en cours.\n\nSaisissez librement le nom du destinataire ou les noms des différents destinataires, puis cliquez sur « Valider » pour conserver cette information dans le document.\n\nPour supprimer une mention existante, effacez le contenu du champ puis validez.\n\nCette saisie renseigne les destinataires du document ; elle ne déclenche aucun envoi.\n\n« Annuler » ferme la fenêtre sans appliquer les modifications. L’ouverture et la fermeture de cette aide conservent votre saisie."),
        "documentRecipient_title":
            MessageLookupByLibrary.simpleMessage("Destinataire(s)"),
        "documentTemplateDraft_help": MessageLookupByLibrary.simpleMessage(
            "Des réponses ont déjà été enregistrées pour ce modèle de guide dans l’épisode de soins en cours.\n\n« Reprendre le brouillon » ouvre le guide avec ces réponses pour vous permettre de poursuivre ou de modifier votre saisie.\n\n« Nouveau bilan » ou « Nouveau rapport » efface les réponses enregistrées pour ce modèle et ouvre le guide sans reprendre ces réponses. Ce choix ne supprime pas le texte déjà présent dans la zone de rédaction du document.\n\n« Annuler » conserve les réponses enregistrées et revient à l’écran précédent sans ouvrir le guide."),
        "documentTemplateDraft_title":
            MessageLookupByLibrary.simpleMessage("Brouillon existant"),
        "documentTemplateGuide_help": MessageLookupByLibrary.simpleMessage(
            "Ce guide vous aide à préparer le contenu d’un bilan ou d’un rapport à partir du modèle sélectionné.\n\nUtilisez la liste des rubriques à gauche pour accéder aux différentes sections. Selon les champs proposés, saisissez du texte, sélectionnez des réponses ou complétez les tableaux.\n\nLe bouton de prévisualisation, situé en bas du formulaire, permet de consulter le texte produit à partir de vos réponses.\n\nDepuis l’aperçu, vous pouvez revenir au guide pour poursuivre votre saisie ou demander l’insertion du texte dans le bilan ou le rapport. Suivez les éventuelles propositions d’ajout ou de remplacement affichées par Companion.\n\nL’insertion du texte ne remplace pas l’enregistrement final du bilan ou du rapport.\n\nL’ouverture et la fermeture de cette aide conservent votre saisie."),
        "documentTemplateGuide_helpTitle":
            MessageLookupByLibrary.simpleMessage("Utiliser le guide de saisie"),
        "documentTemplatePreview_help": MessageLookupByLibrary.simpleMessage(
            "Cette fenêtre permet de relire le texte généré à partir des réponses saisies dans le guide.\n\nLe texte est consultable et sélectionnable. Pour modifier vos réponses, cliquez sur « Fermer » afin de revenir au guide, puis relancez la prévisualisation.\n\nCliquez sur « Insérer dans le bilan » ou « Insérer dans le rapport » pour transmettre le texte au document en cours. Suivez les éventuelles propositions d’ajout ou de remplacement affichées par Companion.\n\nSi aucun texte n’a été généré, le bouton d’insertion reste désactivé.\n\nAprès insertion, vérifiez le contenu du document et enregistrez votre bilan ou votre rapport."),
        "documentTemplatePreview_title":
            MessageLookupByLibrary.simpleMessage("Aperçu du texte généré"),
        "documentTemplate_assessmentTitle":
            MessageLookupByLibrary.simpleMessage("Choisir un modèle de bilan"),
        "documentTemplate_help": MessageLookupByLibrary.simpleMessage(
            "Cette fenêtre présente les modèles disponibles pour le type de document en cours : bilan ou rapport.\n\nCliquez sur un modèle pour ouvrir le guide de saisie correspondant. Le choix du modèle ne crée pas immédiatement un document enregistré.\n\nSi un brouillon existe déjà pour ce modèle dans l’épisode de soins, Companion vous propose de le reprendre ou de commencer une nouvelle saisie."),
        "documentTemplate_reportTitle": MessageLookupByLibrary.simpleMessage(
            "Choisir un modèle de rapport"),
        "documentTests_help": MessageLookupByLibrary.simpleMessage(
            "Cette vue agrandie permet de consulter les tests réalisés dans la prise en charge et de choisir ceux à inclure dans le bilan ou le rapport en cours.\n\nUtilisez les cases de sélection pour inclure ou retirer un test du document. Cette sélection ne supprime pas les résultats enregistrés dans Companion.\n\nLes actions proposées dans la liste permettent de consulter le détail des résultats. La sélection est disponible lorsqu’un bilan ou un rapport est ouvert et que le chargement est terminé.\n\nCliquez sur la croix pour revenir à l’espace Bilans/Rapports."),
        "documentTextInsertion_help": MessageLookupByLibrary.simpleMessage(
            "Votre bilan ou votre rapport contient déjà du texte. Choisissez comment y intégrer le contenu généré par le guide de saisie.\n\n« Ajouter à la suite » conserve le texte existant et ajoute le contenu généré à la fin.\n\n« Remplacer » remplace tout le texte de la zone de rédaction par le contenu généré. Les passages que vous aviez saisis dans cette zone seront donc remplacés eux aussi.\n\n« Annuler » abandonne cette insertion et conserve le texte actuel.\n\nVous pouvez consulter puis fermer cette aide avant de faire votre choix."),
        "documentTextInsertion_title":
            MessageLookupByLibrary.simpleMessage("Insérer le texte généré"),
        "documentTitle_help": MessageLookupByLibrary.simpleMessage(
            "Cette fenêtre permet de renseigner le titre du bilan ou du rapport.\n\nConservez le titre proposé ou remplacez-le par un intitulé permettant de reconnaître facilement le document. Le titre ne peut pas être vide.\n\nCliquez sur le bouton de validation ou appuyez sur Entrée pour confirmer. « Annuler » ferme la fenêtre sans valider le titre.\n\nL’ouverture et la fermeture de cette aide conservent le texte saisi."),
        "episodeDashboard_documents":
            MessageLookupByLibrary.simpleMessage("Documents"),
        "episodeDashboard_documentsDescription":
            MessageLookupByLibrary.simpleMessage(
                "Documents associés à cet épisode"),
        "episodeDashboard_forms":
            MessageLookupByLibrary.simpleMessage("Formulaires"),
        "episodeDashboard_formsDescription":
            MessageLookupByLibrary.simpleMessage(
                "Questionnaires spécifiques à cet épisode"),
        "episodeDashboard_notes": MessageLookupByLibrary.simpleMessage("Notes"),
        "episodeDashboard_notesDescription":
            MessageLookupByLibrary.simpleMessage(
                "Observations et commentaires du kiné"),
        "episodeDashboard_report":
            MessageLookupByLibrary.simpleMessage("Rapport"),
        "episodeDashboard_reportDescription":
            MessageLookupByLibrary.simpleMessage("Synthèse de l’épisode"),
        "episodeDocuments_addDocument":
            MessageLookupByLibrary.simpleMessage("Ajouter un document"),
        "episodeDocuments_addError": MessageLookupByLibrary.simpleMessage(
            "Impossible d’ajouter le document"),
        "episodeDocuments_addedOn":
            MessageLookupByLibrary.simpleMessage("Ajouté le"),
        "episodeDocuments_document":
            MessageLookupByLibrary.simpleMessage("Document"),
        "episodeDocuments_documentAdded": MessageLookupByLibrary.simpleMessage(
            "Le document a été ajouté à la prise en charge."),
        "episodeDocuments_emptyDescription": MessageLookupByLibrary.simpleMessage(
            "Vous pouvez ajouter un document texte, une feuille de calcul, un PDF, une image ou tout autre fichier utile."),
        "episodeDocuments_fileNotFound": MessageLookupByLibrary.simpleMessage(
            "Le fichier associé est introuvable."),
        "episodeDocuments_help": MessageLookupByLibrary.simpleMessage(
            "Vous pouvez associer à cette prise en charge des documents créés avec vos applications habituelles : traitement de texte, tableur, lecteur PDF ou logiciel d’image.\n\nLes fichiers ajoutés sont copiés dans l’espace de stockage de Companion. Un clic sur un document l’ouvre avec l’application correspondante installée sur cet ordinateur."),
        "episodeDocuments_image": MessageLookupByLibrary.simpleMessage("Image"),
        "episodeDocuments_loadError": MessageLookupByLibrary.simpleMessage(
            "Impossible de charger les documents associés."),
        "episodeDocuments_noDocument": MessageLookupByLibrary.simpleMessage(
            "Aucun document associé à cette prise en charge."),
        "episodeDocuments_openDocument":
            MessageLookupByLibrary.simpleMessage("Ouvrir le document"),
        "episodeDocuments_openError": MessageLookupByLibrary.simpleMessage(
            "Impossible d’ouvrir le fichier"),
        "episodeDocuments_pdfDocument":
            MessageLookupByLibrary.simpleMessage("Document PDF"),
        "episodeDocuments_platformNotSupported":
            MessageLookupByLibrary.simpleMessage(
                "Ouverture non prise en charge sur cette plateforme."),
        "episodeDocuments_refresh":
            MessageLookupByLibrary.simpleMessage("Actualiser"),
        "episodeDocuments_spreadsheet":
            MessageLookupByLibrary.simpleMessage("Feuille de calcul"),
        "episodeDocuments_textDocument":
            MessageLookupByLibrary.simpleMessage("Document texte"),
        "episodeDocuments_title": MessageLookupByLibrary.simpleMessage(
            "Documents de la prise en charge"),
        "episodeEvolution_evaluation":
            MessageLookupByLibrary.simpleMessage("évaluation"),
        "episodeEvolution_evaluations":
            MessageLookupByLibrary.simpleMessage("évaluations"),
        "episodeEvolution_first":
            MessageLookupByLibrary.simpleMessage("Première"),
        "episodeEvolution_followedExercises":
            MessageLookupByLibrary.simpleMessage("Exercices suivis"),
        "episodeEvolution_last":
            MessageLookupByLibrary.simpleMessage("Dernière"),
        "episodeEvolution_noResults": MessageLookupByLibrary.simpleMessage(
            "Aucun résultat disponible pour cet épisode."),
        "episodeEvolution_singleNumericValue":
            MessageLookupByLibrary.simpleMessage(
                "Une seule valeur chiffrée disponible"),
        "episodeEvolution_title":
            MessageLookupByLibrary.simpleMessage("Évolution de l\'épisode"),
        "episodeEvolution_viewEvolution":
            MessageLookupByLibrary.simpleMessage("Voir l\'évolution"),
        "episodeFormEditor_error":
            MessageLookupByLibrary.simpleMessage("Erreur"),
        "episodeFormEditor_noField":
            MessageLookupByLibrary.simpleMessage("Aucun champ à afficher."),
        "episodeFormEditor_requiredField": m24,
        "episodeFormEditor_save":
            MessageLookupByLibrary.simpleMessage("Enregistrer"),
        "episodeFormEditor_title":
            MessageLookupByLibrary.simpleMessage("Modifier le formulaire"),
        "episodeForms_availableTemplates":
            MessageLookupByLibrary.simpleMessage("Modèles disponibles"),
        "episodeForms_category":
            MessageLookupByLibrary.simpleMessage("Catégorie"),
        "episodeForms_completed":
            MessageLookupByLibrary.simpleMessage("complété"),
        "episodeForms_create": MessageLookupByLibrary.simpleMessage("Créer"),
        "episodeForms_createdForms":
            MessageLookupByLibrary.simpleMessage("Formulaires créés"),
        "episodeForms_createdOn":
            MessageLookupByLibrary.simpleMessage("Créé le"),
        "episodeForms_customTemplate":
            MessageLookupByLibrary.simpleMessage("Modèle personnalisé"),
        "episodeForms_error": MessageLookupByLibrary.simpleMessage("Erreur"),
        "episodeForms_form": MessageLookupByLibrary.simpleMessage("Formulaire"),
        "episodeForms_inProgress":
            MessageLookupByLibrary.simpleMessage("en cours"),
        "episodeForms_noAvailableTemplate":
            MessageLookupByLibrary.simpleMessage(
                "Aucun modèle de formulaire disponible."),
        "episodeForms_noCreatedForm": MessageLookupByLibrary.simpleMessage(
            "Aucun formulaire créé pour cet épisode."),
        "episodeForms_noData":
            MessageLookupByLibrary.simpleMessage("Aucune donnée à afficher."),
        "episodeForms_refresh":
            MessageLookupByLibrary.simpleMessage("Actualiser"),
        "episodeForms_state": MessageLookupByLibrary.simpleMessage("État"),
        "episodeForms_systemTemplate":
            MessageLookupByLibrary.simpleMessage("Modèle système"),
        "episodeForms_title":
            MessageLookupByLibrary.simpleMessage("Formulaires"),
        "episodeNotes_archive":
            MessageLookupByLibrary.simpleMessage("Archiver"),
        "episodeNotes_archiveConfirmation": m25,
        "episodeNotes_archiveTitle":
            MessageLookupByLibrary.simpleMessage("Archiver la note ?"),
        "episodeNotes_cancel": MessageLookupByLibrary.simpleMessage("Annuler"),
        "episodeNotes_content": MessageLookupByLibrary.simpleMessage("Contenu"),
        "episodeNotes_editNote":
            MessageLookupByLibrary.simpleMessage("Modifier la note"),
        "episodeNotes_error": MessageLookupByLibrary.simpleMessage("Erreur"),
        "episodeNotes_modifiedOn":
            MessageLookupByLibrary.simpleMessage("Modifiée le"),
        "episodeNotes_newNote":
            MessageLookupByLibrary.simpleMessage("Nouvelle note"),
        "episodeNotes_noNote": MessageLookupByLibrary.simpleMessage(
            "Aucune note associée à cet épisode."),
        "episodeNotes_noteTitle": MessageLookupByLibrary.simpleMessage("Titre"),
        "episodeNotes_refresh":
            MessageLookupByLibrary.simpleMessage("Actualiser"),
        "episodeNotes_save":
            MessageLookupByLibrary.simpleMessage("Enregistrer"),
        "episodeNotes_title": MessageLookupByLibrary.simpleMessage("Notes"),
        "episodeNotes_titleRequired":
            MessageLookupByLibrary.simpleMessage("Le titre est obligatoire."),
        "episodeReferents_help": MessageLookupByLibrary.simpleMessage(
            "Cette fenêtre permet de choisir le kiné référent et le médecin prescripteur associés à la prise en charge.\n\nSélectionnez les professionnels dans les listes. Vous pouvez également retirer une association en choisissant l’option sans professionnel.\n\nLes boutons de gestion situés à droite des listes permettent d’accéder aux fiches des praticiens et des correspondants externes, notamment pour ajouter un professionnel manquant.\n\nCliquez sur « Enregistrer » pour appliquer les associations choisies. Les changements de kiné référent sont conservés dans l’historique de la prise en charge.\n\n« Annuler » abandonne les changements d’association dans cette fenêtre. Les fiches éventuellement créées depuis les écrans de gestion restent enregistrées."),
        "episodeReferents_title":
            MessageLookupByLibrary.simpleMessage("Modifier les référents"),
        "episodeReport_abakOrigin":
            MessageLookupByLibrary.simpleMessage("Origine ABAK"),
        "episodeReport_addConclusion":
            MessageLookupByLibrary.simpleMessage("Ajouter une conclusion"),
        "episodeReport_clinicalConclusion":
            MessageLookupByLibrary.simpleMessage("Conclusion clinique"),
        "episodeReport_conclusionRequired":
            MessageLookupByLibrary.simpleMessage(
                "La conclusion ne peut pas être vide."),
        "episodeReport_documents":
            MessageLookupByLibrary.simpleMessage("Documents"),
        "episodeReport_dominantSide":
            MessageLookupByLibrary.simpleMessage("Côté dominant"),
        "episodeReport_editConclusion":
            MessageLookupByLibrary.simpleMessage("Modifier la conclusion"),
        "episodeReport_email": MessageLookupByLibrary.simpleMessage("Email"),
        "episodeReport_error": MessageLookupByLibrary.simpleMessage("Erreur"),
        "episodeReport_forms":
            MessageLookupByLibrary.simpleMessage("Formulaires"),
        "episodeReport_generatedPreview":
            MessageLookupByLibrary.simpleMessage("Aperçu du rapport généré"),
        "episodeReport_generatingPreview": MessageLookupByLibrary.simpleMessage(
            "Génération de l’aperçu texte..."),
        "episodeReport_name": MessageLookupByLibrary.simpleMessage("Nom"),
        "episodeReport_noConclusion": MessageLookupByLibrary.simpleMessage(
            "Aucune conclusion renseignée."),
        "episodeReport_noData":
            MessageLookupByLibrary.simpleMessage("Aucune donnée à afficher."),
        "episodeReport_noDocument":
            MessageLookupByLibrary.simpleMessage("Aucun document associé"),
        "episodeReport_noForm":
            MessageLookupByLibrary.simpleMessage("Aucun formulaire associé"),
        "episodeReport_noNote":
            MessageLookupByLibrary.simpleMessage("Aucune note associée"),
        "episodeReport_noResult":
            MessageLookupByLibrary.simpleMessage("Aucun résultat associé"),
        "episodeReport_notProvided":
            MessageLookupByLibrary.simpleMessage("Non renseigné"),
        "episodeReport_notes": MessageLookupByLibrary.simpleMessage("Notes"),
        "episodeReport_patient":
            MessageLookupByLibrary.simpleMessage("Patient"),
        "episodeReport_phone":
            MessageLookupByLibrary.simpleMessage("Téléphone"),
        "episodeReport_profession":
            MessageLookupByLibrary.simpleMessage("Profession"),
        "episodeReport_refresh":
            MessageLookupByLibrary.simpleMessage("Actualiser"),
        "episodeReport_results":
            MessageLookupByLibrary.simpleMessage("Résultats ABAK"),
        "episodeReport_save":
            MessageLookupByLibrary.simpleMessage("Enregistrer"),
        "episodeReport_score": MessageLookupByLibrary.simpleMessage("Score"),
        "episodeReport_sportActivity":
            MessageLookupByLibrary.simpleMessage("Activité sportive"),
        "episodeReport_title": MessageLookupByLibrary.simpleMessage("Rapport"),
        "episodeReport_unknownType":
            MessageLookupByLibrary.simpleMessage("Type inconnu"),
        "exchangeDirectoryReset": MessageLookupByLibrary.simpleMessage(
            "Dossier d\'échange réinitialisé"),
        "exchangeDirectoryService_choose": MessageLookupByLibrary.simpleMessage(
            "Choisir le dossier d’échange ABAK"),
        "exchangeDirectoryUpdated": MessageLookupByLibrary.simpleMessage(
            "Dossier d\'échange ABAK mis à jour"),
        "externalCorrespondentForm_addTitle":
            MessageLookupByLibrary.simpleMessage("Ajouter un correspondant"),
        "externalCorrespondentForm_editTitle":
            MessageLookupByLibrary.simpleMessage("Modifier le correspondant"),
        "externalCorrespondentForm_help": MessageLookupByLibrary.simpleMessage(
            "Cette fenêtre permet de renseigner la fiche d’un correspondant externe.\n\nLe nom est obligatoire. Vous pouvez compléter le prénom, la profession, la spécialité, l’adresse, le code postal, la ville, l’adresse électronique et le téléphone.\n\nCliquez sur « Enregistrer » pour valider la fiche. « Annuler » ferme la fenêtre sans appliquer les modifications.\n\nL’ouverture et la fermeture de cette aide conservent votre saisie dans le formulaire."),
        "externalCorrespondents_help": MessageLookupByLibrary.simpleMessage(
            "Cet écran présente les correspondants externes enregistrés dans Companion. Chaque ligne indique le nom du correspondant et, lorsqu’elles sont renseignées, sa profession, sa spécialité et sa ville.\n\nCliquez sur « Ajouter » pour créer un correspondant. Renseignez son identité et les coordonnées utiles, puis cliquez sur « Enregistrer » pour l’ajouter à la liste. « Annuler » ferme le formulaire sans créer de correspondant.\n\nCes correspondants peuvent notamment être sélectionnés comme prescripteurs dans les épisodes de soins."),
        "externalCorrespondents_title":
            MessageLookupByLibrary.simpleMessage("Correspondants externes"),
        "externalSpeechToTextProvider_empty":
            MessageLookupByLibrary.simpleMessage(
                "L’add-on n’a retourné aucune réponse."),
        "externalSpeechToTextProvider_failure":
            MessageLookupByLibrary.simpleMessage(
                "Échec de l’add-on de reconnaissance vocale."),
        "externalSpeechToTextProvider_invalid":
            MessageLookupByLibrary.simpleMessage(
                "Réponse invalide de l’add-on de reconnaissance vocale."),
        "externalSpeechToTextProvider_noText":
            MessageLookupByLibrary.simpleMessage(
                "L’add-on n’a retourné aucun texte."),
        "externalSpeechToTextProvider_transcription":
            MessageLookupByLibrary.simpleMessage("La transcription a échoué."),
        "followUpNoteForm_createTitle":
            MessageLookupByLibrary.simpleMessage("Nouvelle note de suivi"),
        "followUpNoteForm_editTitle":
            MessageLookupByLibrary.simpleMessage("Modifier la note de suivi"),
        "followUpNoteForm_help": MessageLookupByLibrary.simpleMessage(
            "Cette fenêtre permet de créer ou de modifier une note de suivi rattachée à l’épisode de soins.\n\nRenseignez un titre et le contenu de la note. Ces deux champs doivent contenir du texte pour que la note soit enregistrée.\n\nLors de la création, cliquez sur « Ajouter ». Lors d’une modification, cliquez sur « Enregistrer » pour conserver vos changements.\n\n« Annuler » ferme la fenêtre sans enregistrer votre saisie. Vous pouvez ouvrir puis fermer cette aide sans perdre le texte en cours de rédaction."),
        "followUpNotes_help": MessageLookupByLibrary.simpleMessage(
            "Cette vue présente les notes de suivi de la prise en charge, avec leur date, leur titre et un aperçu de leur contenu.\n\nLe bouton d’ajout permet de créer une note. L’icône de modification permet d’ouvrir une note existante pour la consulter ou la modifier.\n\nUtilisez les cases de sélection pour choisir les notes à inclure dans le bilan ou le rapport en cours. Décocher une note la retire de cette sélection sans supprimer la note de suivi.\n\nLa sélection est disponible lorsqu’un bilan ou un rapport est ouvert et que le chargement est terminé.\n\nCliquez sur la croix pour fermer la vue agrandie et revenir à l’espace Bilans/Rapports."),
        "g_arb_prefix": MessageLookupByLibrary.simpleMessage("Préfix ARB"),
        "g_close": MessageLookupByLibrary.simpleMessage("Fermer"),
        "g_comment": MessageLookupByLibrary.simpleMessage("Commentaire"),
        "g_context": MessageLookupByLibrary.simpleMessage("Contexte"),
        "g_copy": MessageLookupByLibrary.simpleMessage("Copier"),
        "g_file": MessageLookupByLibrary.simpleMessage("Fichier"),
        "g_helpTooltip":
            MessageLookupByLibrary.simpleMessage("Afficher l’aide"),
        "g_learn_more": MessageLookupByLibrary.simpleMessage("En savoir plus"),
        "g_technical_informations":
            MessageLookupByLibrary.simpleMessage("Informations techniques"),
        "g_technical_informations_copied": MessageLookupByLibrary.simpleMessage(
            "Informations techniques copiées"),
        "help_archived_patient": MessageLookupByLibrary.simpleMessage(
            "Les patients archivés peuvent être restaurés jusqu\'à la date indiquée.\nAprès cette date, ils sont supprimés automatiquement afin de ne pas conserver indéfiniment des dossiers inutilisés.\nLa durée de conservation peut être modifiée dans les paramètres de Companion."),
        "help_device_list_content": MessageLookupByLibrary.simpleMessage(
            "Il s\'agit des appareils (téléphone, tablette) utilisés pour réaliser les tests.\n- Un appareil peut être utilisé par des personnes différentes.\n- Une personne peut posséder plusieurs appareils.\n\nCette information permet de savoir quelle est la source matérielle de l\'information qui est transférée vers Companion.\nVous pouvez créer, modifier, archiver un appareil.\n\nPour des raisons de traçabilité il n\'est pas possible de supprimer un appareil\nVous pouvez si nécessaire restaurer un appareil archivé.\n\nC\'est un QR Code qui est utilisé pour appairer un téléphone ou une tablette. Il faut afficher le QR Code sur le poste fixe (Appareil > icone correspondant de l\'appareil) et sur le téléphone (ou la tablette) accéder aux paramètres > Organisation professionnelle > Appareils enregistrés > Ajouter un appareil.\n\nApprochez l\'appareil de l\'écran pour lire le QR Code.Un message vous informe de la réussite de l\'opération."),
        "help_device_list_title":
            MessageLookupByLibrary.simpleMessage("Liste des appareils"),
        "help_donnees_cliniques_patient": MessageLookupByLibrary.simpleMessage(
            "Vous trouvez ici les données complémentaires concernant votre patient"),
        "help_home": MessageLookupByLibrary.simpleMessage(
            "Cet écran est l\'écran principal d\'ABAK Companion.\n\nIl est constitué :\n\n1) d\'un bandeau qui vous informe : \n - sur le nombre de patients actifs et archivés.\n  - du nombre d\'alertes en cours.\n\nVous pouvez dans les paramètres renseigner le nom de votre établissement et ajouter votre logo.\n\n2) \"Imports récents\" vous indique les dernier dossier de résultats importés depuis ABAK Mobile.\n\n3) \"Etat système\" vous indique un éventuel problème et la date de la dernière sauvegarde.\n\n4) \"Nouveau résultats ABAK à associer\", vous montre les résultats qui ont été envoyé depuis ABAK Mobile mais qui ne sont pas encore attribués à un patient dans ABAK Companion.\n\n5) \"Alerte système\" vous renseigne sur la nature d\'un problème.\n\n6) \"Action rapide\", vous permet d\'accéder à l\'historique de tous vos imports et de créer une nouvelle sauvegarde."),
        "help_home_active_archived_patients_content":
            MessageLookupByLibrary.simpleMessage(
                "Les patients actifs sont ceux à qui vous pouvez attribuer un résultat de test ou questionnaire.\n\nLes patients archivés sont des patients dont les informations seront prochainement supprimées de l\'ordinateur.\n\nLa suppression intervient automatiquement aprsès la date indiquée.\n\nVous pouvez :\n  - Gérer le délai de conservation dans Paramètres.\n. -Réactiver un patient archivé pour le rendre actif.\n\nLa durée de conservation est paramètrable entre 30 et 365 jours."),
        "help_home_active_archived_patients_title":
            MessageLookupByLibrary.simpleMessage("Patients actifs et archivés"),
        "help_home_import_assignment_content": MessageLookupByLibrary.simpleMessage(
            "Les tests et exercices sont réalisés sur votre téléphone (ou tablette) avecABAK Mobile.\nUne fois le test terminé, si vous avez enregistré le résultat, l\'option Dossier > Envoyer vers Desktop vous permet de transférer les informations vers ABAK Companion\n\nUn message dans Companion vous informe qu\'un dossier est arrivé et qu\'il faut l\'attribuer à un patient. Cette attribution vous conduit à sélectionner le patient puis à sélectionner l\'épisode de soin.\n\nPourquoi un tel mécanisme ?\nABAK mobile ne gère pas les dossiers patients. Sur ABAK Mobile, vous pouvez identifier le patient par un pseudo et celui ci peut être différent selon le praticien. Ce pseudo vous sert ensuite à attribuer le résultat au bon patient. Ce mécanisme permet de conserver une indépendance de fonctionnemnent entre les deux applications et préserve, autant que possible, l\'anonymat des patients sur le téléphone ou la tablette qui peuvent êtr partagés."),
        "help_home_import_assignment_title":
            MessageLookupByLibrary.simpleMessage(
                "Récupération d\'un résultats et affectation à un patient"),
        "help_information_patient": MessageLookupByLibrary.simpleMessage(
            "Vous trouvez ici l\'identification de votre patient"),
        "help_parametres_utilisateur": MessageLookupByLibrary.simpleMessage(
            "Cet écran permet :\n - La sélection de la langue.\n - La définition de la duré de consevation des dossiers patients archivés.\n - L\'activation du mode expertı\n - L\'accession à l\'écrran Etablissement pour saisir le nom de votre établisement et son logo"),
        "help_practitionerList_helpText": MessageLookupByLibrary.simpleMessage(
            "Cet écran vous permet d\'ajouter un nouveau praticien, de modifier les informations le concernant.\n\nLa mise dans la corbeille ne supprime pas le praticien. Pour des raisons de traçabilité il n\'est pas possible de supprimer un praticien.\n\nL\'affichage du QR Code vous permet de créer atutomatiquement le profil du praticien pour votre établissement dans le téléphone ou la tablette de celui-ci."),
        "help_prise_en_charge": MessageLookupByLibrary.simpleMessage(
            "Une prise en charge correspond à un épisode de soin.\nVous trouvez ici les différentes prises en charge  actives de votre patient.\nPour rattacher un résultat, vous pouvez utiliser un épisode existant ou en créer un nouveau.\nUne fois l\'épisode terminé vous pouvez l\'archiver."),
        "homeImportSummary_conflicts":
            MessageLookupByLibrary.simpleMessage("Conflits"),
        "homeImportSummary_failedFiles":
            MessageLookupByLibrary.simpleMessage("Fichiers en erreur"),
        "homeImportSummary_importDate":
            MessageLookupByLibrary.simpleMessage("Date import"),
        "homeImportSummary_importedMetrics":
            MessageLookupByLibrary.simpleMessage("Métriques importées"),
        "homeImportSummary_importedResults":
            MessageLookupByLibrary.simpleMessage("Résultats importés"),
        "homeImportSummary_open":
            MessageLookupByLibrary.simpleMessage("Ouvrir"),
        "homeImportSummary_patients":
            MessageLookupByLibrary.simpleMessage("Patients concernés"),
        "homeImportSummary_processedFiles":
            MessageLookupByLibrary.simpleMessage("Fichiers traités"),
        "homeImportSummary_skippedResults":
            MessageLookupByLibrary.simpleMessage("Résultats ignorés"),
        "homeImportSummary_title":
            MessageLookupByLibrary.simpleMessage("Dernier import ABAK"),
        "home_abak_exercice":
            MessageLookupByLibrary.simpleMessage("Exercice ABAK"),
        "home_abak_file": MessageLookupByLibrary.simpleMessage("Fichier ABAK"),
        "home_accueil": MessageLookupByLibrary.simpleMessage("Accueil"),
        "home_action_required": MessageLookupByLibrary.simpleMessage(
            "Action requise : associer ce dossier à un patient."),
        "home_already_imported":
            MessageLookupByLibrary.simpleMessage("Déjà importé"),
        "home_an_intervention_is_necessary":
            MessageLookupByLibrary.simpleMessage(
                "Une intervention est nécessaire"),
        "home_archives": MessageLookupByLibrary.simpleMessage("Archives"),
        "home_attention": MessageLookupByLibrary.simpleMessage("Attention"),
        "home_backup_successfully_created":
            MessageLookupByLibrary.simpleMessage(
                "Sauvegarde créée avec succès."),
        "home_balance_sheet_date":
            MessageLookupByLibrary.simpleMessage("Date du bilan"),
        "home_conflict_detected":
            MessageLookupByLibrary.simpleMessage("Conflit détecté"),
        "home_correspondents":
            MessageLookupByLibrary.simpleMessage("Correspondants"),
        "home_create_a_backup":
            MessageLookupByLibrary.simpleMessage("Créer une sauvegarde"),
        "home_date_not_specified":
            MessageLookupByLibrary.simpleMessage("Date non renseignée"),
        "home_devices": MessageLookupByLibrary.simpleMessage("Appareils"),
        "home_error_while_saving": m26,
        "home_everything_is_working_normally":
            MessageLookupByLibrary.simpleMessage("Tout fonctionne normalement"),
        "home_expert_comment": MessageLookupByLibrary.simpleMessage(
            "Cet écran est l\'écran principal de Companion."),
        "home_failure": MessageLookupByLibrary.simpleMessage("Échec"),
        "home_fermer": MessageLookupByLibrary.simpleMessage("Fermer"),
        "home_file": MessageLookupByLibrary.simpleMessage("Fichier"),
        "home_historique": MessageLookupByLibrary.simpleMessage("Historique"),
        "home_home": MessageLookupByLibrary.simpleMessage("Accueil"),
        "home_import_history":
            MessageLookupByLibrary.simpleMessage("Historique des imports"),
        "home_imports_interrupted_or_in_progress":
            MessageLookupByLibrary.simpleMessage(
                "Imports interrompus ou en cours"),
        "home_imports_with_errors":
            MessageLookupByLibrary.simpleMessage("Imports en erreur"),
        "home_information": MessageLookupByLibrary.simpleMessage("A propos"),
        "home_invalid_file_path": MessageLookupByLibrary.simpleMessage(
            "Chemin du fichier invalide :"),
        "home_ipAddressNotFound":
            MessageLookupByLibrary.simpleMessage("Adresse IP introuvable"),
        "home_ipAddressNotFoundMessage": MessageLookupByLibrary.simpleMessage(
            "Impossible de déterminer l\'adresse IP locale du Desktop.\n\nVérifiez que l\'ordinateur est connecté au réseau local."),
        "home_large_number_of_archived_patients":
            MessageLookupByLibrary.simpleMessage(
                "Nombre important de patients archivés"),
        "home_large_sqlite_database":
            MessageLookupByLibrary.simpleMessage("Base SQLite volumineuse"),
        "home_last_backup":
            MessageLookupByLibrary.simpleMessage("Dernière sauvegarde"),
        "home_last_old_backup": MessageLookupByLibrary.simpleMessage(
            "Dernière sauvegarde ancienne"),
        "home_link_to_a_care_plan": MessageLookupByLibrary.simpleMessage(
            "Associer à une prise en charge"),
        "home_more_7_days":
            MessageLookupByLibrary.simpleMessage("Plus de 7 jours"),
        "home_new_abak_results_to_be_linked":
            MessageLookupByLibrary.simpleMessage(
                "Nouveaux résultats ABAK à associer à un patient"),
        "home_no_abak_result_to_associate":
            MessageLookupByLibrary.simpleMessage(
                "Aucun résultat ABAK à associer."),
        "home_no_alert_detected":
            MessageLookupByLibrary.simpleMessage("Aucune alerte détectée"),
        "home_no_imports_recorded":
            MessageLookupByLibrary.simpleMessage("Aucun import enregistré."),
        "home_no_pending_imports":
            MessageLookupByLibrary.simpleMessage("Aucun import en attente"),
        "home_no_saved_backup": MessageLookupByLibrary.simpleMessage(
            "Aucune sauvegarde enregistrée"),
        "home_not_specified":
            MessageLookupByLibrary.simpleMessage("renseignée"),
        "home_octets": MessageLookupByLibrary.simpleMessage("Octets"),
        "home_other_exercises": m27,
        "home_parameters": MessageLookupByLibrary.simpleMessage("Paramètres"),
        "home_pathway": MessageLookupByLibrary.simpleMessage("Chemin"),
        "home_patient_abak":
            MessageLookupByLibrary.simpleMessage("Patient ABAK"),
        "home_patients": MessageLookupByLibrary.simpleMessage("Patients"),
        "home_pending_association": m28,
        "home_practitioners":
            MessageLookupByLibrary.simpleMessage("praticiens"),
        "home_quick_actions":
            MessageLookupByLibrary.simpleMessage("Actions rapides"),
        "home_receents_imports":
            MessageLookupByLibrary.simpleMessage("Imports récents"),
        "home_recent_restoration_detected":
            MessageLookupByLibrary.simpleMessage(
                "Restauration récente détectée"),
        "home_results": MessageLookupByLibrary.simpleMessage("Résultats"),
        "home_select_qr_code": MessageLookupByLibrary.simpleMessage(
            "Scannez ce QR code depuis ABAK Mobile pour configurer automatiquement la connexion au Desktop."),
        "home_settings": MessageLookupByLibrary.simpleMessage("Assistance"),
        "home_size": MessageLookupByLibrary.simpleMessage("Taille"),
        "home_solve": MessageLookupByLibrary.simpleMessage("Résoudre"),
        "home_success": MessageLookupByLibrary.simpleMessage("Succès"),
        "home_system_alert":
            MessageLookupByLibrary.simpleMessage("Alerte système"),
        "home_system_status":
            MessageLookupByLibrary.simpleMessage("État système"),
        "home_technical_information":
            MessageLookupByLibrary.simpleMessage("Informations techniques"),
        "home_this_file_had_already_been_imported":
            MessageLookupByLibrary.simpleMessage(
                "Ce fichier avait déjà été importé. Aucune donnée n\'a été ajoutée."),
        "home_to_be_verified":
            MessageLookupByLibrary.simpleMessage("à vérifier"),
        "home_to_do_list": MessageLookupByLibrary.simpleMessage("À faire"),
        "home_unable_to_load_recent_imports":
            MessageLookupByLibrary.simpleMessage(
                "Impossible de charger les imports récents."),
        "home_unreadable_abak_import":
            MessageLookupByLibrary.simpleMessage("Import ABAK illisible."),
        "home_unsuccessful": MessageLookupByLibrary.simpleMessage("En échec"),
        "home_verify": MessageLookupByLibrary.simpleMessage("Vérifier"),
        "home_very_large_backups": MessageLookupByLibrary.simpleMessage(
            "Sauvegardes très volumineuses"),
        "importHistory_help": MessageLookupByLibrary.simpleMessage(
            "Cet écran présente l’historique des sessions d’import enregistrées dans Companion.\n\nChaque ligne indique la date de la session, son état, le nombre de fichiers traités et le nombre de résultats importés, ignorés ou en conflit.\n\nL’icône signale notamment un import en cours, un échec, des erreurs ou des conflits nécessitant votre attention.\n\nCliquez sur une session pour consulter son détail et mieux comprendre le traitement des résultats."),
        "importPatientForm_help": MessageLookupByLibrary.simpleMessage(
            "Cette fenêtre permet de créer un patient pour lui rattacher les résultats importés depuis ABAK Mobile.\n\nSaisissez son nom et son prénom. Vous pouvez compléter sa date de naissance au format AAAA-MM-JJ et renseigner son sexe, ou conserver « Non renseigné ».\n\nSi vous avez utilisé la lecture de la carte Vitale, vérifiez les informations préremplies et corrigez-les si nécessaire.\n\nCliquez sur « Créer » pour enregistrer le patient et le sélectionner. Choisissez ensuite la prise en charge à laquelle rattacher les résultats : la création du patient ne termine pas, à elle seule, le rattachement de l’import.\n\n« Annuler » ferme cette fenêtre sans créer de patient. L’ouverture puis la fermeture de cette aide conserve votre saisie."),
        "importPatientForm_title":
            MessageLookupByLibrary.simpleMessage("Nouveau patient"),
        "importResolutionAssistant_file":
            MessageLookupByLibrary.simpleMessage("fichier"),
        "importResolutionAssistant_files":
            MessageLookupByLibrary.simpleMessage("fichiers"),
        "importResolutionAssistant_help": MessageLookupByLibrary.simpleMessage(
            "Cet écran regroupe les imports qui nécessitent votre attention : association à un patient à compléter, échec de l’import, erreurs, résultats ignorés ou conflits à examiner.\n\nChaque ligne indique la date de l’import et les informations disponibles pour identifier le dossier concerné.\n\nCliquez sur un import pour ouvrir son suivi, consulter les explications et accéder aux actions proposées selon sa situation.\n\nLa liste est actualisée à votre retour depuis le suivi de l’import. Si aucun import ne répond à ces critères, un message indique qu’aucun problème n’a été détecté."),
        "importResolutionAssistant_import":
            MessageLookupByLibrary.simpleMessage("Import"),
        "importResolutionAssistant_importFailed":
            MessageLookupByLibrary.simpleMessage("Import en échec"),
        "importResolutionAssistant_importToComplete":
            MessageLookupByLibrary.simpleMessage("Import à terminer"),
        "importResolutionAssistant_importToReview":
            MessageLookupByLibrary.simpleMessage("Import à vérifier"),
        "importResolutionAssistant_inError":
            MessageLookupByLibrary.simpleMessage("en erreur"),
        "importResolutionAssistant_interventionRequired":
            MessageLookupByLibrary.simpleMessage(
                "Une intervention est nécessaire pour terminer cet import."),
        "importResolutionAssistant_loadingError":
            MessageLookupByLibrary.simpleMessage(
                "Impossible de charger les imports"),
        "importResolutionAssistant_noProblem":
            MessageLookupByLibrary.simpleMessage(
                "Aucun problème d’import détecté."),
        "importResolutionAssistant_result":
            MessageLookupByLibrary.simpleMessage("résultat"),
        "importResolutionAssistant_results":
            MessageLookupByLibrary.simpleMessage("résultats"),
        "importResolutionAssistant_selectImportInstruction":
            MessageLookupByLibrary.simpleMessage(
                "Sélectionnez un import pour afficher son détail et suivre les étapes proposées."),
        "importResolutionAssistant_title": MessageLookupByLibrary.simpleMessage(
            "Résolution des problèmes d’import"),
        "importResolutionAssistant_toReview":
            MessageLookupByLibrary.simpleMessage("à vérifier"),
        "importResolution_help": MessageLookupByLibrary.simpleMessage(
            "Cet écran permet de rattacher les résultats reçus depuis ABAK Mobile au bon patient et à la bonne prise en charge dans Companion.\n\nConsultez les informations de l’import reçu, puis sélectionnez le patient concerné dans la liste. Si nécessaire, créez sa fiche avec « Nouveau patient » ou « Depuis Carte Vitale », lorsque le dispositif de lecture est disponible.\n\nAprès avoir sélectionné le patient, choisissez une prise en charge active ou créez-en une. Une prise en charge archivée doit être restaurée avant de pouvoir être sélectionnée.\n\nVérifiez le patient et la prise en charge avant de choisir cette dernière : sa sélection valide le rattachement et permet de poursuivre l’import."),
        "importResolution_title":
            MessageLookupByLibrary.simpleMessage("Rattacher l\'import"),
        "importSessionDetail_help": MessageLookupByLibrary.simpleMessage(
            "Cet écran présente le suivi d’un import reçu dans Companion. Le message principal indique si l’import a réussi, nécessite une association à un patient ou comporte un problème.\n\nLorsqu’une association est nécessaire, cliquez sur « Associer à un patient » pour choisir le dossier auquel rattacher les résultats.\n\nLe compte rendu et la liste des fichiers permettent de consulter le détail du traitement et les éventuels avertissements.\n\nSi le fichier reçu est incomplet ou endommagé, demandez un nouvel envoi depuis ABAK Mobile.\n\nSelon la situation, le bouton « Supprimer cet import » est proposé. Consultez le message de confirmation avant de valider la suppression."),
        "importSessionDetail_title":
            MessageLookupByLibrary.simpleMessage("Suivi de l’import"),
        "information_backupCount": m29,
        "information_backups":
            MessageLookupByLibrary.simpleMessage("Sauvegardes"),
        "information_configured":
            MessageLookupByLibrary.simpleMessage("Configuré"),
        "information_contextComment": MessageLookupByLibrary.simpleMessage(
            "Cet écran affiche les informations générales, techniques et légales de Companion."),
        "information_contextName":
            MessageLookupByLibrary.simpleMessage("Informations"),
        "information_database":
            MessageLookupByLibrary.simpleMessage("Base de données"),
        "information_help": MessageLookupByLibrary.simpleMessage(
            "Cette page présente les informations générales de votre installation de Companion : version de l’application, cabinet configuré, présence du logo, système utilisé et langue.\n\nLa rubrique consacrée au stockage local indique la taille de la base de données ainsi que le nombre et la taille totale des sauvegardes enregistrées.\n\nLes boutons permettent de consulter les nouveautés, la licence et les avertissements relatifs à l’utilisation de l’application.\n\nLors d’un échange avec l’assistance, la version de Companion et le système affichés ici peuvent aider à identifier votre configuration."),
        "information_language": MessageLookupByLibrary.simpleMessage("Langue"),
        "information_legalNotice":
            MessageLookupByLibrary.simpleMessage("Avertissement légal"),
        "information_loading":
            MessageLookupByLibrary.simpleMessage("Chargement..."),
        "information_localStorage":
            MessageLookupByLibrary.simpleMessage("Stockage local"),
        "information_logo": MessageLookupByLibrary.simpleMessage("Logo"),
        "information_new": MessageLookupByLibrary.simpleMessage(
            "Version 1.1.0 build 3\nPossibilité de dictée vocale pour les bilans et rapports, nécessite le module gratuit.\nSauvegarde automatique Bilan et Rapport.\nBouton duplication Bilan et Rapport.\nNotes modifiables.\nBouton pour voir tous les tests d\'un patient pour un épisode.\nModèles de bilans.\nGraphique automatique si plusieurs résultats pour un test\nCréation d\'un document au format docx.\nAffichage de l\'aide utilisée pour E72 et E76"),
        "information_newHelp": MessageLookupByLibrary.simpleMessage(
            "Cette page présente les nouveautés et les évolutions décrites pour Companion.\n\nFaites défiler le texte pour consulter l’ensemble des informations. Vous pouvez sélectionner et copier un passage si nécessaire.\n\nUtilisez la flèche de retour pour revenir à la page « À propos »."),
        "information_newTitle":
            MessageLookupByLibrary.simpleMessage("Nouveautés de la version"),
        "information_notConfigured":
            MessageLookupByLibrary.simpleMessage("Non configuré"),
        "information_notProvided":
            MessageLookupByLibrary.simpleMessage("Non renseigné"),
        "information_office": MessageLookupByLibrary.simpleMessage("Cabinet"),
        "information_size": m30,
        "information_system": MessageLookupByLibrary.simpleMessage("Système"),
        "information_title":
            MessageLookupByLibrary.simpleMessage("Informations"),
        "information_totalSize": m31,
        "information_version": m32,
        "information_versionLoading":
            MessageLookupByLibrary.simpleMessage("Version..."),
        "information_viewLicense":
            MessageLookupByLibrary.simpleMessage("Consulter la licence"),
        "initialReportDocumentService_associate":
            MessageLookupByLibrary.simpleMessage(
                "Associer un bilan initial Word"),
        "initialReportDocumentService_unsupported":
            MessageLookupByLibrary.simpleMessage("Plateforme non supportée"),
        "kobus_archived":
            MessageLookupByLibrary.simpleMessage("Companion — archivé"),
        "kobus_archives":
            MessageLookupByLibrary.simpleMessage("Archives importées"),
        "kobus_attach":
            MessageLookupByLibrary.simpleMessage("Rattacher au patient choisi"),
        "kobus_backupNotice": MessageLookupByLibrary.simpleMessage(
            "La sauvegarde actuelle de la base ne sauvegarde pas les fichiers KOBUS."),
        "kobus_cancel": MessageLookupByLibrary.simpleMessage("Annuler"),
        "kobus_candidate":
            MessageLookupByLibrary.simpleMessage("Patient proposé"),
        "kobus_chooseCandidate": MessageLookupByLibrary.simpleMessage(
            "Sélectionnez une ligne ci-dessous"),
        "kobus_confirm": MessageLookupByLibrary.simpleMessage(
            "Vérifier et confirmer l’import"),
        "kobus_confirmBody": MessageLookupByLibrary.simpleMessage(
            "Importer les dossiers prêts selon vos décisions ? Les rapprochements non résolus et les dossiers exclus resteront de côté. Les fiches existantes ne seront pas modifiées."),
        "kobus_consult":
            MessageLookupByLibrary.simpleMessage("Consulter les données KOBUS"),
        "kobus_create": MessageLookupByLibrary.simpleMessage("Créer une fiche"),
        "kobus_creations":
            MessageLookupByLibrary.simpleMessage("Fiches créées / à créer"),
        "kobus_distinct": MessageLookupByLibrary.simpleMessage(
            "Confirmer une personne distincte"),
        "kobus_editRejected": MessageLookupByLibrary.simpleMessage(
            "Éditer la liste des dossiers rejetés"),
        "kobus_existing": MessageLookupByLibrary.simpleMessage(
            "Patients existants concernés"),
        "kobus_failed":
            MessageLookupByLibrary.simpleMessage("Échecs techniques"),
        "kobus_history":
            MessageLookupByLibrary.simpleMessage("Compte rendu KOBUS"),
        "kobus_imported": MessageLookupByLibrary.simpleMessage("Importés"),
        "kobus_interrupted": MessageLookupByLibrary.simpleMessage(
            "Non traités après interruption"),
        "kobus_intro": MessageLookupByLibrary.simpleMessage(
            "Les dossiers sont conservés à l’identique. Aucun épisode ni document clinique natif n’est créé."),
        "kobus_matches":
            MessageLookupByLibrary.simpleMessage("Rapprochements à vérifier"),
        "kobus_noShared": MessageLookupByLibrary.simpleMessage(
            "Aucun dossier partagé dans cet export"),
        "kobus_ownOrigin": MessageLookupByLibrary.simpleMessage("Mes patients"),
        "kobus_print": MessageLookupByLibrary.simpleMessage("Imprimer"),
        "kobus_provenance":
            MessageLookupByLibrary.simpleMessage("Provenance / statut"),
        "kobus_reason": MessageLookupByLibrary.simpleMessage("Motif"),
        "kobus_rejected": MessageLookupByLibrary.simpleMessage("Rejetés"),
        "kobus_savePdf":
            MessageLookupByLibrary.simpleMessage("Enregistrer le PDF"),
        "kobus_scopeReset": MessageLookupByLibrary.simpleMessage(
            "Changer cette option réinitialise les décisions de rapprochement."),
        "kobus_select":
            MessageLookupByLibrary.simpleMessage("Choisir le ZIP KOBUS"),
        "kobus_shared": MessageLookupByLibrary.simpleMessage(
            "Récupérer également les dossiers partagés si présents"),
        "kobus_sharedOrigin":
            MessageLookupByLibrary.simpleMessage("Patients partagés"),
        "kobus_skip": MessageLookupByLibrary.simpleMessage("Laisser de côté"),
        "kobus_source": MessageLookupByLibrary.simpleMessage("Identité KOBUS"),
        "kobus_start": MessageLookupByLibrary.simpleMessage("Lancer l’import"),
        "kobus_stop": MessageLookupByLibrary.simpleMessage(
            "Arrêter après le dossier en cours"),
        "kobus_stopping":
            MessageLookupByLibrary.simpleMessage("Arrêt demandé…"),
        "kobus_title": MessageLookupByLibrary.simpleMessage("Importer KOBUS"),
        "kobus_unavailable": MessageLookupByLibrary.simpleMessage(
            "Les données KOBUS sont indisponibles ou le dossier est introuvable."),
        "kobus_unresolved": MessageLookupByLibrary.simpleMessage("À décider"),
        "languageSaved":
            MessageLookupByLibrary.simpleMessage("Langue enregistrée."),
        "language_choice":
            MessageLookupByLibrary.simpleMessage("Langue de l\'application"),
        "legalNotice_appBarTitle":
            MessageLookupByLibrary.simpleMessage("Avertissement"),
        "legalNotice_content": MessageLookupByLibrary.simpleMessage(
            "ABAK Desktop Companion est un logiciel d’aide à l’organisation, à l’importation et à la consultation de résultats cliniques issus de l’écosystème ABAK.\n\nIl ne constitue pas un dispositif médical certifié et ne remplace pas le jugement du professionnel de santé.\n\nLes résultats, scores, comptes rendus et indicateurs affichés doivent toujours être interprétés par un professionnel qualifié, en tenant compte de l’examen clinique, du contexte du patient et des recommandations en vigueur.\n\nL’utilisateur reste seul responsable de ses décisions cliniques, de la vérification des données importées et de la conformité de leur utilisation avec les règles professionnelles, réglementaires et déontologiques applicables.\n\nABAK Desktop Companion ne réalise pas de diagnostic autonome, ne prescrit aucun traitement et ne se substitue en aucun cas à une consultation médicale ou paramédicale."),
        "legalNotice_help": MessageLookupByLibrary.simpleMessage(
            "Cette page présente les avertissements et les informations relatifs à l’utilisation de Companion.\n\nFaites défiler la page pour lire l’intégralité du texte.\n\nUtilisez la flèche de retour pour revenir à la page « À propos »."),
        "legalNotice_title":
            MessageLookupByLibrary.simpleMessage("Avertissement Légal"),
        "loading": MessageLookupByLibrary.simpleMessage("Chargement..."),
        "localDatabaseBackup_cancelled":
            MessageLookupByLibrary.simpleMessage("Sauvegarde annulée."),
        "localDatabaseBackup_chooseBackupFolder":
            MessageLookupByLibrary.simpleMessage(
                "Choisir le dossier de sauvegarde ABAK"),
        "localDatabaseBackup_databaseNotFound":
            MessageLookupByLibrary.simpleMessage("Base SQLite introuvable."),
        "localDatabaseReset_backupFailed": MessageLookupByLibrary.simpleMessage(
            "Sauvegarde préalable impossible"),
        "localDatabaseRestoreService_anomaly": m33,
        "localDatabaseRestoreService_failure": m34,
        "localDatabaseRestoreService_integrity": m35,
        "localDatabaseRestoreService_missing":
            MessageLookupByLibrary.simpleMessage(
                "Le fichier de sauvegarde est introuvable."),
        "localDatabaseRestoreService_success":
            MessageLookupByLibrary.simpleMessage(
                "Restauration effectuée avec succès."),
        "main_alreadyRunningMessage": MessageLookupByLibrary.simpleMessage(
            "Une seule instance peut être ouverte à la fois.\n\nUtilisez la fenêtre Companion déjà ouverte."),
        "main_alreadyRunningTitle": MessageLookupByLibrary.simpleMessage(
            "ABAK Desktop Companion est déjà ouvert"),
        "main_close": MessageLookupByLibrary.simpleMessage(""),
        "modify": MessageLookupByLibrary.simpleMessage("Modifier"),
        "noDirectoryDefined":
            MessageLookupByLibrary.simpleMessage("Aucun dossier défini"),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "open": MessageLookupByLibrary.simpleMessage("Ouvrir"),
        "organization_chooseLogo":
            MessageLookupByLibrary.simpleMessage("Choisir un logo"),
        "organization_chooseReportHeader": MessageLookupByLibrary.simpleMessage(
            "Choisir un en-tête personnalisé"),
        "organization_help": MessageLookupByLibrary.simpleMessage(
            "Cet écran permet de renseigner le nom et les coordonnées de votre cabinet : adresse, code postal, ville, téléphone et adresse électronique.\n\nCliquez sur « Enregistrer les coordonnées » pour conserver vos modifications avant de quitter l’écran.\n\nVous pouvez également choisir une image sur votre ordinateur pour définir le logo du cabinet. Le choix du logo est enregistré immédiatement, indépendamment des coordonnées.\n\nLe bouton de suppression du logo permet de retirer le logo utilisé dans Companion."),
        "organization_identityTitle":
            MessageLookupByLibrary.simpleMessage("Identité de l’établissement"),
        "organization_logoRecommendation": MessageLookupByLibrary.simpleMessage(
            "Taille recommandée : image carrée d’au moins 300 × 300 px. Format recommandé : PNG."),
        "organization_logoRemoved": MessageLookupByLibrary.simpleMessage(
            "Logo de l’établissement supprimé."),
        "organization_logoSaved": MessageLookupByLibrary.simpleMessage(
            "Logo de l’établissement enregistré."),
        "organization_nameLabel":
            MessageLookupByLibrary.simpleMessage("Nom de l’établissement"),
        "organization_nameSaved": MessageLookupByLibrary.simpleMessage(
            "Nom de l’établissement enregistré."),
        "organization_removeLogo":
            MessageLookupByLibrary.simpleMessage("Supprimer le logo"),
        "organization_removeReportHeader":
            MessageLookupByLibrary.simpleMessage("Supprimer l’en-tête"),
        "organization_reportHeaderHelpAi": MessageLookupByLibrary.simpleMessage(
            "Vous pouvez également demander à un outil d’intelligence artificielle de générer l’image de votre en-tête à partir de vos indications."),
        "organization_reportHeaderHelpClose":
            MessageLookupByLibrary.simpleMessage("Fermer"),
        "organization_reportHeaderHelpContent":
            MessageLookupByLibrary.simpleMessage(
                "L’image peut contenir librement votre logo, le nom de l’établissement, vos coordonnées et tout autre élément graphique que vous souhaitez faire apparaître sur vos rapports."),
        "organization_reportHeaderHelpFormat": MessageLookupByLibrary.simpleMessage(
            "Pour un résultat optimal dans les rapports ABAK, utilisez une image au format 200 × 30 mm, soit environ 2362 × 354 px à 300 dpi. Le format PNG est recommandé."),
        "organization_reportHeaderHelpIntro": MessageLookupByLibrary.simpleMessage(
            "Vous pouvez créer librement votre en-tête avec l’outil de votre choix, puis l’enregistrer sous forme d’image."),
        "organization_reportHeaderHelpReplacement":
            MessageLookupByLibrary.simpleMessage(
                "Les informations présentes dans l’image remplacent l’en-tête standard généré par ABAK (logo et coordonnées de l’établissement)."),
        "organization_reportHeaderHelpTitle":
            MessageLookupByLibrary.simpleMessage(
                "Créer un en-tête personnalisé"),
        "organization_reportHeaderHelpTools": MessageLookupByLibrary.simpleMessage(
            "Si vous n’avez pas l’habitude des outils graphiques, vous pouvez par exemple utiliser LibreOffice Draw, Microsoft PowerPoint, Apple Keynote ou Canva. Cette liste est donnée uniquement à titre d’exemple et n’est pas exhaustive."),
        "organization_reportHeaderHelpTooltip":
            MessageLookupByLibrary.simpleMessage(
                "Aide pour créer un en-tête personnalisé"),
        "organization_reportHeaderRecommendation":
            MessageLookupByLibrary.simpleMessage(
                "Taille recommandée : 200 × 30 mm (environ 2362 × 354 px à 300 dpi). Format recommandé : PNG."),
        "organization_reportHeaderRemoved":
            MessageLookupByLibrary.simpleMessage(
                "En-tête personnalisé supprimé."),
        "organization_reportHeaderSaved": MessageLookupByLibrary.simpleMessage(
            "En-tête personnalisé enregistré."),
        "organization_reportHeaderTitle": MessageLookupByLibrary.simpleMessage(
            "En-tête personnalisé des rapports"),
        "organization_reportIntroductionHelp": MessageLookupByLibrary.simpleMessage(
            "Texte libre utilisé au début des rapports. Si ce champ est vide, « Docteur » sera utilisé."),
        "organization_reportIntroductionHint":
            MessageLookupByLibrary.simpleMessage("Docteur"),
        "organization_reportIntroductionLabel":
            MessageLookupByLibrary.simpleMessage(
                "Formule introductive des rapports"),
        "organization_saveName":
            MessageLookupByLibrary.simpleMessage("Enregistrer le nom"),
        "organization_title":
            MessageLookupByLibrary.simpleMessage("Établissement"),
        "pairPhone":
            MessageLookupByLibrary.simpleMessage("Associer un téléphone"),
        "pairPhoneDialogTitle":
            MessageLookupByLibrary.simpleMessage("Associer un téléphone"),
        "pairPhoneInstructions": MessageLookupByLibrary.simpleMessage(
            "Scannez ce QR code depuis ABAK Mobile pour configurer automatiquement la connexion au Desktop."),
        "pairPhone_help": MessageLookupByLibrary.simpleMessage(
            "Cette fenêtre affiche les informations permettant à ABAK Mobile de trouver Companion sur le réseau local.\n\nConnectez le téléphone ou la tablette et l’ordinateur au même réseau local, puis scannez ce QR code depuis la fonction d’association à Companion dans ABAK Mobile.\n\nLe QR code contient l’adresse réseau et le port de communication de cet ordinateur. Ces informations sont également affichées sous le code.\n\nGardez Companion ouvert sur l’ordinateur lors des échanges. Si l’adresse réseau de l’ordinateur change, ouvrez à nouveau cette fenêtre et scannez le nouveau code.\n\nL’affichage de ce QR code ne déclenche pas à lui seul l’envoi de résultats."),
        "patientClinicalDataEdit_address":
            MessageLookupByLibrary.simpleMessage("Adresse"),
        "patientClinicalDataEdit_administrativeIdentity":
            MessageLookupByLibrary.simpleMessage("Identité administrative"),
        "patientClinicalDataEdit_ambidextrous":
            MessageLookupByLibrary.simpleMessage("Ambidextre"),
        "patientClinicalDataEdit_centimeters":
            MessageLookupByLibrary.simpleMessage("En centimètres"),
        "patientClinicalDataEdit_dominantSide":
            MessageLookupByLibrary.simpleMessage("Côté dominant"),
        "patientClinicalDataEdit_email":
            MessageLookupByLibrary.simpleMessage("Email"),
        "patientClinicalDataEdit_healthSystemCountry":
            MessageLookupByLibrary.simpleMessage("Pays du système de santé"),
        "patientClinicalDataEdit_height":
            MessageLookupByLibrary.simpleMessage("Taille"),
        "patientClinicalDataEdit_help": MessageLookupByLibrary.simpleMessage(
            "Cet écran permet de compléter les informations administratives et le profil du patient.\n\nVous pouvez renseigner son identifiant de santé, la source de son identité, son téléphone, son adresse électronique et son adresse postale.\n\nLe profil comprend le côté dominant, la profession, l’activité sportive, la taille en centimètres et le poids en kilogrammes.\n\nCliquez sur « Enregistrer » pour sauvegarder vos modifications et revenir à la fiche du patient. Revenir en arrière sans enregistrer abandonne les modifications."),
        "patientClinicalDataEdit_identitySource":
            MessageLookupByLibrary.simpleMessage("Source de l’identité"),
        "patientClinicalDataEdit_kilograms":
            MessageLookupByLibrary.simpleMessage("En kilogrammes"),
        "patientClinicalDataEdit_left":
            MessageLookupByLibrary.simpleMessage("Gauche"),
        "patientClinicalDataEdit_manualEntry":
            MessageLookupByLibrary.simpleMessage("Saisie manuelle"),
        "patientClinicalDataEdit_nationalHealthId":
            MessageLookupByLibrary.simpleMessage(
                "Identifiant national de santé"),
        "patientClinicalDataEdit_nationalHealthIdHelper":
            MessageLookupByLibrary.simpleMessage(
                "Exemple France : numéro de sécurité sociale"),
        "patientClinicalDataEdit_patientProfile":
            MessageLookupByLibrary.simpleMessage("Profil patient"),
        "patientClinicalDataEdit_phone":
            MessageLookupByLibrary.simpleMessage("Téléphone"),
        "patientClinicalDataEdit_profession":
            MessageLookupByLibrary.simpleMessage("Profession"),
        "patientClinicalDataEdit_right":
            MessageLookupByLibrary.simpleMessage("Droite"),
        "patientClinicalDataEdit_save":
            MessageLookupByLibrary.simpleMessage("Enregistrer"),
        "patientClinicalDataEdit_sportActivity":
            MessageLookupByLibrary.simpleMessage(
                "Activité sportive habituelle"),
        "patientClinicalDataEdit_title": MessageLookupByLibrary.simpleMessage(
            "Modifier les données cliniques"),
        "patientClinicalDataEdit_unspecified":
            MessageLookupByLibrary.simpleMessage("Non précisé"),
        "patientClinicalDataEdit_vitaleCard":
            MessageLookupByLibrary.simpleMessage("Carte Vitale"),
        "patientClinicalDataEdit_weight":
            MessageLookupByLibrary.simpleMessage("Poids"),
        "patientDetail_address":
            MessageLookupByLibrary.simpleMessage("Adresse"),
        "patientDetail_administrativeIdentity":
            MessageLookupByLibrary.simpleMessage("Identité administrative"),
        "patientDetail_archived":
            MessageLookupByLibrary.simpleMessage("archivé"),
        "patientDetail_bornOn":
            MessageLookupByLibrary.simpleMessage("Né(e) le"),
        "patientDetail_cancel": MessageLookupByLibrary.simpleMessage("Annuler"),
        "patientDetail_careEpisodeOpenedIn":
            MessageLookupByLibrary.simpleMessage("Prise en charge ouverte en"),
        "patientDetail_careEpisodes":
            MessageLookupByLibrary.simpleMessage("Prises en charge"),
        "patientDetail_create": MessageLookupByLibrary.simpleMessage("Créer"),
        "patientDetail_dominantSide":
            MessageLookupByLibrary.simpleMessage("Côté dominant"),
        "patientDetail_edit": MessageLookupByLibrary.simpleMessage("Modifier"),
        "patientDetail_editCareEpisode":
            MessageLookupByLibrary.simpleMessage("Modifier la prise en charge"),
        "patientDetail_editCareEpisodeHelp": MessageLookupByLibrary.simpleMessage(
            "Cette fenêtre permet de modifier les informations de la prise en charge du patient.\n\nVous pouvez corriger la pathologie ou le motif de la prise en charge, compléter le texte initial et choisir le praticien référent ainsi que le médecin prescripteur.\n\nLa pathologie doit être renseignée pour que les modifications soient enregistrées.\n\nCliquez sur « Enregistrer » pour valider les modifications. « Annuler » ferme la fenêtre sans les appliquer.\n\nL’ouverture et la fermeture de cette aide conservent votre saisie dans le formulaire."),
        "patientDetail_editClinicalData": MessageLookupByLibrary.simpleMessage(
            "Modifier les données cliniques"),
        "patientDetail_email": MessageLookupByLibrary.simpleMessage("Email"),
        "patientDetail_error": MessageLookupByLibrary.simpleMessage("Erreur"),
        "patientDetail_frHealthIdentity":
            MessageLookupByLibrary.simpleMessage("Identité de santé — France"),
        "patientDetail_healthSystemCountry":
            MessageLookupByLibrary.simpleMessage("Pays système santé"),
        "patientDetail_height": MessageLookupByLibrary.simpleMessage("Taille"),
        "patientDetail_identitySource":
            MessageLookupByLibrary.simpleMessage("Source identité"),
        "patientDetail_initialReport":
            MessageLookupByLibrary.simpleMessage("Compte rendu initial"),
        "patientDetail_nationalIdentifier":
            MessageLookupByLibrary.simpleMessage("Identifiant national"),
        "patientDetail_newCareEpisode":
            MessageLookupByLibrary.simpleMessage("Nouvelle prise en charge"),
        "patientDetail_newCareEpisodeHelp": MessageLookupByLibrary.simpleMessage(
            "Cette fenêtre permet de créer une nouvelle prise en charge pour le patient sélectionné.\n\nRenseignez la pathologie ou le motif de la prise en charge. Cette information est nécessaire pour créer l’épisode.\n\nVous pouvez compléter le texte initial et sélectionner un praticien référent. Ces informations sont facultatives.\n\nCliquez sur « Créer » pour enregistrer l’épisode. « Annuler » ferme la fenêtre sans le créer.\n\nL’ouverture et la fermeture de cette aide conservent votre saisie dans le formulaire."),
        "patientDetail_noBirthdate":
            MessageLookupByLibrary.simpleMessage("Non renseigné"),
        "patientDetail_noCareEpisode": MessageLookupByLibrary.simpleMessage(
            "Aucune prise en charge créée pour ce patient."),
        "patientDetail_notProvided":
            MessageLookupByLibrary.simpleMessage("Non renseigné"),
        "patientDetail_notProvidedFemale":
            MessageLookupByLibrary.simpleMessage("Non renseignée"),
        "patientDetail_pathology":
            MessageLookupByLibrary.simpleMessage("Pathologie"),
        "patientDetail_patientInformation":
            MessageLookupByLibrary.simpleMessage("Informations patient"),
        "patientDetail_patientProfile":
            MessageLookupByLibrary.simpleMessage("Profil patient"),
        "patientDetail_phone":
            MessageLookupByLibrary.simpleMessage("Téléphone"),
        "patientDetail_profession":
            MessageLookupByLibrary.simpleMessage("Profession"),
        "patientDetail_provisional":
            MessageLookupByLibrary.simpleMessage("Provisoire"),
        "patientDetail_provisionalDescription":
            MessageLookupByLibrary.simpleMessage("Identité à compléter"),
        "patientDetail_qualified":
            MessageLookupByLibrary.simpleMessage("Qualifiée"),
        "patientDetail_qualifiedDescription":
            MessageLookupByLibrary.simpleMessage("Identité conforme"),
        "patientDetail_referringPractitioner":
            MessageLookupByLibrary.simpleMessage("Kiné référent"),
        "patientDetail_retrieved":
            MessageLookupByLibrary.simpleMessage("Récupérée"),
        "patientDetail_retrievedDescription":
            MessageLookupByLibrary.simpleMessage(
                "INS obtenue, identité à contrôler"),
        "patientDetail_save":
            MessageLookupByLibrary.simpleMessage("Enregistrer"),
        "patientDetail_sex": MessageLookupByLibrary.simpleMessage("Sexe"),
        "patientDetail_sportActivity":
            MessageLookupByLibrary.simpleMessage("Activité sportive"),
        "patientDetail_state": MessageLookupByLibrary.simpleMessage("État"),
        "patientDetail_status": MessageLookupByLibrary.simpleMessage("Statut"),
        "patientDetail_validated":
            MessageLookupByLibrary.simpleMessage("Validée"),
        "patientDetail_validatedDescription":
            MessageLookupByLibrary.simpleMessage(
                "Identité contrôlée, INS à rechercher"),
        "patientDetail_weight": MessageLookupByLibrary.simpleMessage("Poids"),
        "patientDetail_years": MessageLookupByLibrary.simpleMessage("ans"),
        "patientDocuments_authorization": MessageLookupByLibrary.simpleMessage(
            "Le dossier doit être autorisé à nouveau. Sélectionnez le dossier commun défini dans les paramètres."),
        "patientDocuments_chooseRoot":
            MessageLookupByLibrary.simpleMessage("Choisir le dossier commun"),
        "patientDocuments_error": MessageLookupByLibrary.simpleMessage(
            "Impossible de préparer ou d’ouvrir le dossier. Vérifiez sa disponibilité et vos droits d’accès, puis réessayez.\""),
        "patientDocuments_open":
            MessageLookupByLibrary.simpleMessage("Ouvrir le dossier patient"),
        "patientDocuments_retry":
            MessageLookupByLibrary.simpleMessage("Réessayer"),
        "patientDocuments_settingsHelp": MessageLookupByLibrary.simpleMessage(
            "Un dossier par patient, contenant Bilan, Rapport et Autre. Création à l’ouverture de la fiche ; les fichiers existants ne sont pas déplacés."),
        "patientDocuments_structure":
            MessageLookupByLibrary.simpleMessage("Bilan / Rapport / Autre"),
        "patientDocuments_title":
            MessageLookupByLibrary.simpleMessage("Documents du patient"),
        "patientDocuments_unconfigured": MessageLookupByLibrary.simpleMessage(
            "Aucun dossier de stockage défini. Choisissez le dossier commun à tous les patients."),
        "patientForm_birthDate":
            MessageLookupByLibrary.simpleMessage("Date de naissance"),
        "patientForm_cancel": MessageLookupByLibrary.simpleMessage("Annuler"),
        "patientForm_create": MessageLookupByLibrary.simpleMessage("Créer"),
        "patientForm_editPatient":
            MessageLookupByLibrary.simpleMessage("Modifier le patient"),
        "patientForm_female": MessageLookupByLibrary.simpleMessage("Femme"),
        "patientForm_firstName": MessageLookupByLibrary.simpleMessage("Prénom"),
        "patientForm_firstNameRequired":
            MessageLookupByLibrary.simpleMessage("Le prénom est obligatoire"),
        "patientForm_help": MessageLookupByLibrary.simpleMessage(
            "Cette fenêtre permet de renseigner ou de corriger l’identité du patient.\n\nLe nom et le prénom sont obligatoires. Vous pouvez sélectionner la date de naissance dans le calendrier et renseigner le sexe, ou conserver la valeur « Non précisé ».\n\nCliquez sur « Enregistrer » pour valider les modifications. Si le formulaire est ouvert en mode création, le bouton « Créer » permet de créer la fiche.\n\n« Annuler » ferme la fenêtre sans appliquer les modifications. L’ouverture et la fermeture de cette aide conservent votre saisie dans le formulaire."),
        "patientForm_lastName": MessageLookupByLibrary.simpleMessage("Nom"),
        "patientForm_lastNameRequired":
            MessageLookupByLibrary.simpleMessage("Le nom est obligatoire"),
        "patientForm_male": MessageLookupByLibrary.simpleMessage("Homme"),
        "patientForm_newPatient":
            MessageLookupByLibrary.simpleMessage("Nouveau patient"),
        "patientForm_other": MessageLookupByLibrary.simpleMessage("Autre"),
        "patientForm_save": MessageLookupByLibrary.simpleMessage("Enregistrer"),
        "patientForm_sex": MessageLookupByLibrary.simpleMessage("Sexe"),
        "patientForm_unspecified":
            MessageLookupByLibrary.simpleMessage("Non précisé"),
        "patientList_active": MessageLookupByLibrary.simpleMessage("Actifs"),
        "patientList_archive": MessageLookupByLibrary.simpleMessage("Archiver"),
        "patientList_archiveConfirmation": m36,
        "patientList_archiveSuccess": m37,
        "patientList_archiveTitle":
            MessageLookupByLibrary.simpleMessage("Archiver le patient"),
        "patientList_archived":
            MessageLookupByLibrary.simpleMessage("Archivés"),
        "patientList_archivedOn":
            MessageLookupByLibrary.simpleMessage("Archivé le"),
        "patientList_archivedPatient":
            MessageLookupByLibrary.simpleMessage("Patient archivé"),
        "patientList_archivedPatientsEmpty":
            MessageLookupByLibrary.simpleMessage(
                "La corbeille des patients est vide pour le moment."),
        "patientList_bornOn": MessageLookupByLibrary.simpleMessage("Né(e) le"),
        "patientList_cancel": MessageLookupByLibrary.simpleMessage("Annuler"),
        "patientList_contextComment": MessageLookupByLibrary.simpleMessage(
            "Vous pouvez afficher la liste des patients actifs et ceux archivés"),
        "patientList_contextName":
            MessageLookupByLibrary.simpleMessage("Liste des patients"),
        "patientList_edit": MessageLookupByLibrary.simpleMessage("Modifier"),
        "patientList_error": m38,
        "patientList_help": MessageLookupByLibrary.simpleMessage(
            "Cet écran permet de retrouver vos patients et d’accéder à leur dossier.\n\nLes boutons « Actifs » et « Archivés » permettent de choisir la liste affichée. Le nombre indiqué correspond au total des patients de chaque catégorie.\n\nPour rechercher un patient dans la liste affichée, saisissez tout ou partie de son nom ou de son prénom dans le champ de recherche. Cliquez sur sa ligne pour ouvrir son dossier.\n\nLe bouton « Nouveau patient » ouvre l’écran de création d’un patient.\n\nPour un patient actif, l’icône crayon permet de modifier son identité. L’icône d’archivage permet de le retirer de la liste des patients actifs après confirmation.\n\nDans la liste des patients archivés, l’icône de restauration permet de remettre un patient dans la liste des actifs. Une aide spécifique, accessible près de la date d’archivage, précise les modalités de conservation."),
        "patientList_newPatient":
            MessageLookupByLibrary.simpleMessage("Nouveau patient"),
        "patientList_noArchivedPatients":
            MessageLookupByLibrary.simpleMessage("Aucun patient archivé"),
        "patientList_noPatientFound":
            MessageLookupByLibrary.simpleMessage("Aucun patient trouvé"),
        "patientList_noRegisteredPatients":
            MessageLookupByLibrary.simpleMessage("Aucun patient enregistré"),
        "patientList_patientFileEmpty": MessageLookupByLibrary.simpleMessage(
            "Le fichier patient local est vide pour le moment."),
        "patientList_restorableUntil":
            MessageLookupByLibrary.simpleMessage("Restaurable jusqu’au"),
        "patientList_restore":
            MessageLookupByLibrary.simpleMessage("Restaurer"),
        "patientList_restoreSuccess": m39,
        "patientList_searchPatient":
            MessageLookupByLibrary.simpleMessage("Rechercher un patient"),
        "patientList_sex": MessageLookupByLibrary.simpleMessage("Sexe"),
        "patientList_title":
            MessageLookupByLibrary.simpleMessage("Liste des patients"),
        "patientNew_archivedMatchToReview":
            MessageLookupByLibrary.simpleMessage(
                "Correspondance archivée à vérifier"),
        "patientNew_archivedMatchToReviewMessage":
            MessageLookupByLibrary.simpleMessage(
                "Un patient archivé ayant les mêmes nom, prénom et date de naissance existe déjà, mais ses informations administratives sont différentes.\n\nAucune restauration automatique ne sera effectuée. Vérifiez les dossiers avant de poursuivre."),
        "patientNew_archivedPatientFound": MessageLookupByLibrary.simpleMessage(
            "Patient trouvé dans les archives"),
        "patientNew_archivedPatientMatch": MessageLookupByLibrary.simpleMessage(
            "Cette Carte Vitale correspond au patient archivé :"),
        "patientNew_attach": MessageLookupByLibrary.simpleMessage("Rattacher"),
        "patientNew_attachVitaleError": MessageLookupByLibrary.simpleMessage(
            "Impossible de rattacher la Carte Vitale"),
        "patientNew_attachVitaleQuestion": MessageLookupByLibrary.simpleMessage(
            "Voulez-vous rattacher les informations de la Carte Vitale à ce patient ?"),
        "patientNew_attachVitaleSuccess": m40,
        "patientNew_backToList":
            MessageLookupByLibrary.simpleMessage("Retour à la liste"),
        "patientNew_birthDate":
            MessageLookupByLibrary.simpleMessage("Date de naissance"),
        "patientNew_cancel": MessageLookupByLibrary.simpleMessage("Annuler"),
        "patientNew_choosePatient":
            MessageLookupByLibrary.simpleMessage("Choisir le patient"),
        "patientNew_close": MessageLookupByLibrary.simpleMessage("Fermer"),
        "patientNew_contextComment": MessageLookupByLibrary.simpleMessage(
            "Cet écran permet la création d’un nouveau patient par saisie ou lecture de la Carte Vitale."),
        "patientNew_contextName":
            MessageLookupByLibrary.simpleMessage("Nouveau patient"),
        "patientNew_createError": MessageLookupByLibrary.simpleMessage(
            "Erreur lors de la création du patient"),
        "patientNew_createPatient":
            MessageLookupByLibrary.simpleMessage("Créer le patient"),
        "patientNew_creating":
            MessageLookupByLibrary.simpleMessage("Création..."),
        "patientNew_download":
            MessageLookupByLibrary.simpleMessage("Télécharger"),
        "patientNew_existingPatientTitle":
            MessageLookupByLibrary.simpleMessage("Patient déjà existant ?"),
        "patientNew_female": MessageLookupByLibrary.simpleMessage("Féminin"),
        "patientNew_firstName": MessageLookupByLibrary.simpleMessage("Prénom"),
        "patientNew_firstNameRequired":
            MessageLookupByLibrary.simpleMessage("Le prénom est obligatoire"),
        "patientNew_help": MessageLookupByLibrary.simpleMessage(
            "Cet écran permet de créer un patient dans ABAK Companion.\n\nSaisissez son nom et son prénom : ces deux informations sont obligatoires. Vous pouvez compléter sa date de naissance à l’aide du calendrier et renseigner son sexe.\n\nLe bouton de lecture de la carte Vitale permet de récupérer l’identité du patient lorsque le lecteur et le module de lecture sont disponibles. Si plusieurs bénéficiaires sont proposés, sélectionnez la personne concernée, puis vérifiez les informations affichées. La saisie manuelle reste possible.\n\nSi Companion détecte un patient déjà présent, vérifiez les informations proposées avant de poursuivre afin d’éviter un doublon. Un patient archivé peut être proposé à la restauration.\n\nCliquez sur « Créer le patient » pour enregistrer la fiche, ou sur « Annuler » pour quitter sans créer de patient."),
        "patientNew_identificationCountriesHelp":
            MessageLookupByLibrary.simpleMessage(
                "La lecture de la carte Vitale proposée dans Companion concerne actuellement la France. Elle permet de récupérer des informations d’identité pour faciliter la création de la fiche patient.\n\nABAK Companion souhaite étendre cette démarche aux moyens d’identification utilisés dans d’autres pays. Les cartes, identifiants et services de santé y fonctionnent différemment : leur prise en charge n’est pas encore intégrée à Companion. La saisie manuelle reste disponible.\n\nNous souhaitons explorer ces possibilités avec les kinésithérapeutes qui utilisent ABAK. Vous souhaitez nous accompagner dans votre pays ? Votre connaissance des pratiques locales et votre participation aux essais nous aideront à définir une solution utile et adaptée.\n\nLes évolutions seront construites progressivement avec les praticiens volontaires, selon les besoins exprimés, les possibilités techniques et les autorisations nécessaires."),
        "patientNew_identificationCountriesTitle":
            MessageLookupByLibrary.simpleMessage(
                "Identification des patients selon les pays"),
        "patientNew_lastName": MessageLookupByLibrary.simpleMessage("Nom"),
        "patientNew_lastNameRequired":
            MessageLookupByLibrary.simpleMessage("Le nom est obligatoire"),
        "patientNew_male": MessageLookupByLibrary.simpleMessage("Masculin"),
        "patientNew_matchToReview":
            MessageLookupByLibrary.simpleMessage("Correspondance à vérifier"),
        "patientNew_matchToReviewMessage": MessageLookupByLibrary.simpleMessage(
            "Un patient ayant les mêmes nom, prénom et date de naissance existe déjà.\n\nLes informations administratives ne correspondent pas complètement. Vérifiez le dossier avant de poursuivre."),
        "patientNew_matchingPatientFound": MessageLookupByLibrary.simpleMessage(
            "Un patient correspondant a été trouvé :"),
        "patientNew_nir": MessageLookupByLibrary.simpleMessage("NIR"),
        "patientNew_nirDetectedProtected":
            MessageLookupByLibrary.simpleMessage("détecté et protégé"),
        "patientNew_nirUnavailable":
            MessageLookupByLibrary.simpleMessage("non disponible"),
        "patientNew_no": MessageLookupByLibrary.simpleMessage("Non"),
        "patientNew_noNewPatientCreated": MessageLookupByLibrary.simpleMessage(
            "Aucun nouveau patient ne sera créé."),
        "patientNew_notProvided":
            MessageLookupByLibrary.simpleMessage("Non renseigné"),
        "patientNew_notProvidedFemale":
            MessageLookupByLibrary.simpleMessage("non renseignée"),
        "patientNew_other": MessageLookupByLibrary.simpleMessage("Autre"),
        "patientNew_patientAlreadyRegistered":
            MessageLookupByLibrary.simpleMessage("Patient déjà enregistré"),
        "patientNew_patientIdentity":
            MessageLookupByLibrary.simpleMessage("Identité du patient"),
        "patientNew_readOn":
            MessageLookupByLibrary.simpleMessage("Lecture effectuée le"),
        "patientNew_readVitale":
            MessageLookupByLibrary.simpleMessage("Lire Carte Vitale"),
        "patientNew_readerNotDetected": MessageLookupByLibrary.simpleMessage(
            "Lecteur de Carte Vitale non détecté"),
        "patientNew_readerNotDetectedMessage": MessageLookupByLibrary.simpleMessage(
            "ABAK Desktop Companion n’a détecté aucun lecteur de Carte Vitale.\n\nPour utiliser cette fonction, vous devez disposer :\n\n• d’un lecteur de Carte Vitale compatible PC/SC, généralement connecté en USB ;\n• du module ABAK Carte Vitale, fourni gratuitement. Voir le site abak.care.\n\nUne fois le lecteur connecté, cliquez de nouveau sur « Lire Carte Vitale »."),
        "patientNew_reading":
            MessageLookupByLibrary.simpleMessage("Lecture en cours..."),
        "patientNew_restore": MessageLookupByLibrary.simpleMessage("Restaurer"),
        "patientNew_restoreError": MessageLookupByLibrary.simpleMessage(
            "Impossible de restaurer le patient"),
        "patientNew_restoreInsteadOfCreate": MessageLookupByLibrary.simpleMessage(
            "Souhaitez-vous restaurer ce dossier plutôt que créer un nouveau patient ?"),
        "patientNew_restoreSuccess": m41,
        "patientNew_sex": MessageLookupByLibrary.simpleMessage("Sexe"),
        "patientNew_vitaleIdentityRead": MessageLookupByLibrary.simpleMessage(
            "Identité lue depuis la Carte Vitale"),
        "patientNew_vitaleMatchesPatient": MessageLookupByLibrary.simpleMessage(
            "Cette Carte Vitale correspond au patient :"),
        "patientNew_vitaleModuleConfigurationError":
            MessageLookupByLibrary.simpleMessage(
                "La configuration du module Carte Vitale est absente ou incorrecte. Réinstallez le module puis réessayez."),
        "patientNew_vitaleModuleNotInstalled":
            MessageLookupByLibrary.simpleMessage(
                "Module Carte Vitale non installé"),
        "patientNew_vitaleModuleNotInstalledMessage":
            MessageLookupByLibrary.simpleMessage(
                "Le module ABAK Carte Vitale n’est pas installé sur cet ordinateur.\n\nVous pouvez le télécharger gratuitement depuis le site ABAK."),
        "patientNew_vitalePrefilled": MessageLookupByLibrary.simpleMessage(
            "Informations patient préremplies depuis la Carte Vitale."),
        "patientNew_vitaleReadFailed": MessageLookupByLibrary.simpleMessage(
            "La lecture de la Carte Vitale a échoué."),
        "practitionerList_active":
            MessageLookupByLibrary.simpleMessage("Actifs"),
        "practitionerList_addPractitionersHint":
            MessageLookupByLibrary.simpleMessage(
                "Ajoutez les kinés du cabinet pour identifier les tests importés."),
        "practitionerList_archive":
            MessageLookupByLibrary.simpleMessage("Archiver"),
        "practitionerList_archiveConfirmation": m42,
        "practitionerList_archiveEmpty": MessageLookupByLibrary.simpleMessage(
            "La corbeille des kinés est vide pour le moment."),
        "practitionerList_archivePractitioner":
            MessageLookupByLibrary.simpleMessage("Archiver le kiné"),
        "practitionerList_archived":
            MessageLookupByLibrary.simpleMessage("Archivés"),
        "practitionerList_archivedOn": m43,
        "practitionerList_button_create":
            MessageLookupByLibrary.simpleMessage("Créer un praticien"),
        "practitionerList_cancel":
            MessageLookupByLibrary.simpleMessage("Annuler"),
        "practitionerList_contextComment": MessageLookupByLibrary.simpleMessage(
            "Cet écran affiche la liste des praticiens enregistrés."),
        "practitionerList_contextName":
            MessageLookupByLibrary.simpleMessage("Liste des praticiens"),
        "practitionerList_edit":
            MessageLookupByLibrary.simpleMessage("Modifier"),
        "practitionerList_error": m44,
        "practitionerList_noArchivedPractitioner":
            MessageLookupByLibrary.simpleMessage("Aucun kiné archivé"),
        "practitionerList_noPractitioner":
            MessageLookupByLibrary.simpleMessage("Aucun kiné enregistré"),
        "practitionerList_professionalId": m45,
        "practitionerList_restore":
            MessageLookupByLibrary.simpleMessage("Restaurer"),
        "practitionerList_showQrCode":
            MessageLookupByLibrary.simpleMessage("Afficher le QR Code"),
        "practitionerList_title":
            MessageLookupByLibrary.simpleMessage("Liste des praticiens"),
        "practitionerNew_cancel":
            MessageLookupByLibrary.simpleMessage("Annuler"),
        "practitionerNew_cet_ecran_permet":
            MessageLookupByLibrary.simpleMessage(
                "Cet écran permet de créer un praticien."),
        "practitionerNew_create": MessageLookupByLibrary.simpleMessage("Créer"),
        "practitionerNew_displayName":
            MessageLookupByLibrary.simpleMessage("Nom affiché"),
        "practitionerNew_displayNameRequired":
            MessageLookupByLibrary.simpleMessage(
                "Le nom affiché est obligatoire"),
        "practitionerNew_editPractitioner":
            MessageLookupByLibrary.simpleMessage("Modifier le praticien"),
        "practitionerNew_email": MessageLookupByLibrary.simpleMessage("Email"),
        "practitionerNew_firstName":
            MessageLookupByLibrary.simpleMessage("Prénom"),
        "practitionerNew_help": MessageLookupByLibrary.simpleMessage(
            "Cette fenêtre permet de créer ou de modifier la fiche d’un praticien.\n\nLe nom affiché est obligatoire : il permet d’identifier le praticien dans Companion. Vous pouvez également renseigner son prénom, son nom, son identifiant professionnel, son adresse électronique et son téléphone.\n\nCliquez sur « Créer » pour ajouter un praticien ou sur « Enregistrer » pour valider les modifications d’une fiche existante.\n\n« Annuler » ferme la fenêtre sans appliquer les modifications. L’ouverture et la fermeture de cette aide conservent votre saisie dans le formulaire."),
        "practitionerNew_lastName": MessageLookupByLibrary.simpleMessage("Nom"),
        "practitionerNew_newPractitioner":
            MessageLookupByLibrary.simpleMessage("Nouveau praticien"),
        "practitionerNew_phone":
            MessageLookupByLibrary.simpleMessage("Téléphone"),
        "practitionerNew_professionalId":
            MessageLookupByLibrary.simpleMessage("Identifiant professionnel"),
        "practitionerNew_professionalIdHint":
            MessageLookupByLibrary.simpleMessage("RPPS, ADELI…"),
        "practitionerNew_save":
            MessageLookupByLibrary.simpleMessage("Enregistrer"),
        "practitionerQr_close": MessageLookupByLibrary.simpleMessage("Fermer"),
        "practitionerQr_defaultOrganizationName":
            MessageLookupByLibrary.simpleMessage("Cabinet"),
        "practitionerQr_help": MessageLookupByLibrary.simpleMessage(
            "Cette fenêtre affiche le QR code du profil professionnel du praticien, accompagné de son nom et du nom du cabinet.\n\nScannez ce QR code depuis ABAK Mobile pour y identifier le praticien dans cet établissement. Vérifiez que le nom affiché correspond au professionnel concerné.\n\nCe QR code sert à transmettre les informations d’identification du profil professionnel ; son affichage ne déclenche pas de transfert de résultats.\n\nFermez cette fenêtre pour revenir à la liste des praticiens."),
        "practitionerQr_professionalProfile":
            MessageLookupByLibrary.simpleMessage("Profil professionnel ABAK"),
        "practitionerQr_scanQrCodeInstruction":
            MessageLookupByLibrary.simpleMessage(
                "Scannez ce QR Code depuis ABAK Mobile afin d\'ajouter automatiquement ce profil professionnel."),
        "practitionerSelector_archived":
            MessageLookupByLibrary.simpleMessage("archivé"),
        "practitionerSelector_error": m46,
        "practitionerSelector_noSelection":
            MessageLookupByLibrary.simpleMessage("Aucune sélection"),
        "preferences_archivedPatients":
            MessageLookupByLibrary.simpleMessage("Patients archivés"),
        "preferences_contextComment": MessageLookupByLibrary.simpleMessage(
            "Cet écran centralise les paramètres généraux de Companion."),
        "preferences_contextName":
            MessageLookupByLibrary.simpleMessage("Paramètres utilisateur"),
        "preferences_days": MessageLookupByLibrary.simpleMessage("jours"),
        "preferences_expertMode":
            MessageLookupByLibrary.simpleMessage("Mode Expert"),
        "preferences_expertModeDescription": MessageLookupByLibrary.simpleMessage(
            "Affiche des informations techniques destinées aux développeurs et aux contributeurs."),
        "preferences_expertModeSaved": MessageLookupByLibrary.simpleMessage(
            "Paramètre du mode Expert enregistré."),
        "preferences_languageSaved":
            MessageLookupByLibrary.simpleMessage("Langue enregistrée."),
        "preferences_organization":
            MessageLookupByLibrary.simpleMessage("Établissement"),
        "preferences_organizationDescription":
            MessageLookupByLibrary.simpleMessage(
                "Nom, logo et informations générales."),
        "preferences_retentionDuration":
            MessageLookupByLibrary.simpleMessage("Durée de conservation"),
        "preferences_retentionExplanation": MessageLookupByLibrary.simpleMessage(
            "Les patients archivés peuvent être restaurés pendant cette durée. Ils seront ensuite supprimés automatiquement."),
        "preferences_retentionSaved": MessageLookupByLibrary.simpleMessage(
            "Durée de conservation enregistrée."),
        "recentImportCard_conflict":
            MessageLookupByLibrary.simpleMessage("conflit"),
        "recentImportCard_error":
            MessageLookupByLibrary.simpleMessage("erreur"),
        "recentImportCard_fichier":
            MessageLookupByLibrary.simpleMessage("fichier"),
        "recentImportCard_file":
            MessageLookupByLibrary.simpleMessage("fichier"),
        "recentImportCard_ignored":
            MessageLookupByLibrary.simpleMessage("ignoré"),
        "recentImportCard_no_result_imported":
            MessageLookupByLibrary.simpleMessage("Aucun résultat importé"),
        "recentImportCard_result":
            MessageLookupByLibrary.simpleMessage("résultat"),
        "referringPractitionerHistoryDialog_archivedPractitioner": m47,
        "referringPractitionerHistoryDialog_close":
            MessageLookupByLibrary.simpleMessage("Fermer"),
        "referringPractitionerHistoryDialog_currentPractitioner":
            MessageLookupByLibrary.simpleMessage("Référent actuel"),
        "referringPractitionerHistoryDialog_fromTo": m48,
        "referringPractitionerHistoryDialog_loadHistoryError": m49,
        "referringPractitionerHistoryDialog_noHistory":
            MessageLookupByLibrary.simpleMessage(
                "Aucun kiné référent n’a encore été enregistré pour cet épisode."),
        "referringPractitionerHistoryDialog_since": m50,
        "referringPractitionerHistory_help": MessageLookupByLibrary.simpleMessage(
            "Cette fenêtre présente les praticiens qui ont été désignés comme référents pour cet épisode de soins.\n\nChaque ligne indique le nom du praticien et sa période d’affectation. La mention « Référent actuel » identifie le praticien actuellement associé à l’épisode.\n\nLa mention « archivé » signifie que la fiche du praticien est archivée ; son nom reste visible dans l’historique.\n\nCette fenêtre permet uniquement de consulter l’historique. Fermez-la pour revenir à l’épisode de soins."),
        "referringPractitionerHistory_title":
            MessageLookupByLibrary.simpleMessage(
                "Historique des kinés référents"),
        "refreshDashboard": MessageLookupByLibrary.simpleMessage(
            "Actualiser le tableau de bord"),
        "reportArchive_title":
            MessageLookupByLibrary.simpleMessage("Archives des rapports"),
        "reportDraft_help": MessageLookupByLibrary.simpleMessage(
            "Le texte affiché correspond à un travail en cours sauvegardé automatiquement. Vous pouvez le conserver, le modifier ou le supprimer avant d’enregistrer votre rapport."),
        "reportDraft_helpTitle": MessageLookupByLibrary.simpleMessage(
            "Comprendre le brouillon du rapport"),
        "reportHistory_help": MessageLookupByLibrary.simpleMessage(
            "Cette vue présente les rapports enregistrés pour la prise en charge, avec leur titre et leur date.\n\nLes actions de chaque ligne permettent de modifier un rapport, de le dupliquer ou de le déplacer vers les documents archivés.\n\nLorsqu’un rapport est ouvert en modification, utilisez l’action de mise à jour pour enregistrer vos changements. Les commandes disponibles permettent également d’annuler les modifications ou de revenir au brouillon.\n\nLe déplacement vers les documents archivés n’est pas une suppression définitive.\n\nCliquez sur la croix pour fermer la vue agrandie et revenir à l’espace Bilans/Rapports."),
        "reset": MessageLookupByLibrary.simpleMessage("Réinitialiser"),
        "resultDetail_addCommentHint":
            MessageLookupByLibrary.simpleMessage("Ajouter un commentaire..."),
        "resultDetail_archiveConfirmation":
            MessageLookupByLibrary.simpleMessage(
                "Voulez-vous vraiment archiver ce résultat ?"),
        "resultDetail_archiveTitle":
            MessageLookupByLibrary.simpleMessage("Archiver le résultat"),
        "resultDetail_birthDate":
            MessageLookupByLibrary.simpleMessage("Naissance"),
        "resultDetail_cancel": MessageLookupByLibrary.simpleMessage("Appareil"),
        "resultDetail_clinicalComment":
            MessageLookupByLibrary.simpleMessage("Commentaire clinique"),
        "resultDetail_commentSaved":
            MessageLookupByLibrary.simpleMessage("Commentaire enregistré"),
        "resultDetail_detailedResult":
            MessageLookupByLibrary.simpleMessage("Résultat détaillé"),
        "resultDetail_device":
            MessageLookupByLibrary.simpleMessage("Détail de l\'appareil"),
        "resultDetail_exerciseDate":
            MessageLookupByLibrary.simpleMessage("Date de l\'exercice"),
        "resultDetail_generalInformation":
            MessageLookupByLibrary.simpleMessage("Informations générales"),
        "resultDetail_help": MessageLookupByLibrary.simpleMessage(
            "Cet écran présente les informations d’un résultat importé depuis ABAK Mobile : patient, date de réalisation, score et, lorsqu’elles sont disponibles, aide utilisée, identité du praticien et appareil d’origine.\n\nVous pouvez consulter le compte rendu détaillé et les mesures complémentaires transmises par l’exercice.\n\nLa zone « Commentaire clinique » permet d’ajouter ou de modifier vos observations. Cliquez sur « Enregistrer » pour les conserver avant de quitter l’écran.\n\nLa rubrique consacrée à l’import indique l’état de synchronisation et la date de dernière modification du résultat.\n\nL’icône d’archivage permet d’archiver ce résultat après confirmation."),
        "resultDetail_identityUnverified":
            MessageLookupByLibrary.simpleMessage("Identité non vérifiée"),
        "resultDetail_identityVerified":
            MessageLookupByLibrary.simpleMessage("Identité vérifiée"),
        "resultDetail_import": MessageLookupByLibrary.simpleMessage("Import"),
        "resultDetail_lastModified":
            MessageLookupByLibrary.simpleMessage("Dernière modification"),
        "resultDetail_metrics":
            MessageLookupByLibrary.simpleMessage("Métriques"),
        "resultDetail_noMetrics": MessageLookupByLibrary.simpleMessage(
            "Aucune métrique enregistrée."),
        "resultDetail_patient": MessageLookupByLibrary.simpleMessage("Patient"),
        "resultDetail_performedBy":
            MessageLookupByLibrary.simpleMessage("Réalisé par"),
        "resultDetail_save":
            MessageLookupByLibrary.simpleMessage("Enregistrer"),
        "resultDetail_score": MessageLookupByLibrary.simpleMessage("Score"),
        "resultDetail_syncState":
            MessageLookupByLibrary.simpleMessage("État sync"),
        "settings_assistanceWarning": MessageLookupByLibrary.simpleMessage(
            "Ces fonctions sont destinées à l’installation, au diagnostic et aux opérations d’assistance technique.\n\nUtilisez-les uniquement lorsqu’un technicien ou la documentation ABAK vous le demande."),
        "settings_cancel": MessageLookupByLibrary.simpleMessage("Annuler"),
        "settings_configuration":
            MessageLookupByLibrary.simpleMessage("Configuration"),
        "settings_confirmationRequired":
            MessageLookupByLibrary.simpleMessage("Confirmation obligatoire"),
        "settings_contextComment": MessageLookupByLibrary.simpleMessage(
            "Cet écran regroupe les fonctions d’installation, de diagnostic et de maintenance de Companion."),
        "settings_contextName":
            MessageLookupByLibrary.simpleMessage("Assistance"),
        "settings_continue": MessageLookupByLibrary.simpleMessage("Continuer"),
        "settings_databaseResetError": m51,
        "settings_databaseResetSuccess": MessageLookupByLibrary.simpleMessage(
            "Base réinitialisée. Sauvegarde automatique créée."),
        "settings_diagnostic":
            MessageLookupByLibrary.simpleMessage("Diagnostic"),
        "settings_edit": MessageLookupByLibrary.simpleMessage("Modifier"),
        "settings_exchangeDirectory":
            MessageLookupByLibrary.simpleMessage("Dossier d’échange ABAK"),
        "settings_exchangeDirectoryReset": MessageLookupByLibrary.simpleMessage(
            "Dossier d’échange réinitialisé"),
        "settings_exchangeDirectoryUpdated":
            MessageLookupByLibrary.simpleMessage(
                "Dossier d’échange ABAK mis à jour"),
        "settings_exportAction":
            MessageLookupByLibrary.simpleMessage("Exporter"),
        "settings_exportCancel":
            MessageLookupByLibrary.simpleMessage("Annuler"),
        "settings_exportCancelled":
            MessageLookupByLibrary.simpleMessage("Export annulé"),
        "settings_exportChooseDestination":
            MessageLookupByLibrary.simpleMessage(
                "Choisir le dossier de destination"),
        "settings_exportCompleted": m52,
        "settings_exportCompletedWithErrors": m53,
        "settings_exportDataDescription": MessageLookupByLibrary.simpleMessage(
            "Une archive contenant les informations de vos patients ainsi que leurs bilans et rapports va être créée."),
        "settings_exportFailed": MessageLookupByLibrary.simpleMessage(
            "Impossible d’exporter les données"),
        "settings_exportIncludeArchivedPatients":
            MessageLookupByLibrary.simpleMessage(
                "Inclure les patients archivés"),
        "settings_exportMyData":
            MessageLookupByLibrary.simpleMessage("Exporter mes données"),
        "settings_exportPatientBirthDate":
            MessageLookupByLibrary.simpleMessage("Date de naissance"),
        "settings_exportPatientFemale":
            MessageLookupByLibrary.simpleMessage("Féminin"),
        "settings_exportPatientFirstName":
            MessageLookupByLibrary.simpleMessage("Prénom"),
        "settings_exportPatientLastName":
            MessageLookupByLibrary.simpleMessage("Nom"),
        "settings_exportPatientMale":
            MessageLookupByLibrary.simpleMessage("Masculin"),
        "settings_exportPatientSex":
            MessageLookupByLibrary.simpleMessage("Sexe"),
        "settings_exportPatientUnknown":
            MessageLookupByLibrary.simpleMessage("Non renseigné"),
        "settings_exportPatientUnknownFemale":
            MessageLookupByLibrary.simpleMessage("Non renseignée"),
        "settings_help": MessageLookupByLibrary.simpleMessage(
            "Cet écran regroupe les fonctions d’installation, de diagnostic et de maintenance de Companion. Utilisez-les selon les indications de la documentation ABAK ou d’un technicien.\n\nLa rubrique « Configuration » permet de consulter, ouvrir ou modifier le dossier utilisé pour les échanges de fichiers.\n\nLa rubrique « Diagnostic » donne accès aux vérifications du dispositif de lecture de la carte Vitale.\n\nLa rubrique « Maintenance » permet d’ouvrir l’assistant de résolution des imports, d’importer manuellement un fichier ABAK et d’accéder à la gestion des sauvegardes.\n\nLa réinitialisation de la base supprime les données locales. Cette opération est réservée aux situations d’assistance technique : lisez attentivement les messages de confirmation avant de poursuivre."),
        "settings_importAbakFile": MessageLookupByLibrary.simpleMessage(
            "Importer manuellement un fichier .abak"),
        "settings_invalidConfirmation":
            MessageLookupByLibrary.simpleMessage("Confirmation invalide."),
        "settings_loading":
            MessageLookupByLibrary.simpleMessage("Chargement..."),
        "settings_maintenance":
            MessageLookupByLibrary.simpleMessage("Maintenance"),
        "settings_manageBackups":
            MessageLookupByLibrary.simpleMessage("Gérer les sauvegardes"),
        "settings_noDirectoryDefined":
            MessageLookupByLibrary.simpleMessage("Aucun dossier défini"),
        "settings_open": MessageLookupByLibrary.simpleMessage("Ouvrir"),
        "settings_openingExchangeDirectory":
            MessageLookupByLibrary.simpleMessage(
                "Ouverture du dossier d’échange"),
        "settings_reset": MessageLookupByLibrary.simpleMessage("Réinitialiser"),
        "settings_resetDatabase":
            MessageLookupByLibrary.simpleMessage("Réinitialiser la base"),
        "settings_resetDatabaseTitle": MessageLookupByLibrary.simpleMessage(
            "Réinitialiser la base locale ?"),
        "settings_resetDatabaseWarning": MessageLookupByLibrary.simpleMessage(
            "Cette opération supprimera toutes les données locales (patients, résultats, imports et historiques).\n\nUne sauvegarde automatique sera créée avant la réinitialisation.\n\nUtilisez cette fonction uniquement lors d’une opération d’assistance technique."),
        "settings_resetKeyword": MessageLookupByLibrary.simpleMessage("RESET"),
        "settings_resetTooltip":
            MessageLookupByLibrary.simpleMessage("Réinitialiser"),
        "settings_resolveImportProblem": MessageLookupByLibrary.simpleMessage(
            "Résoudre un problème d’import"),
        "settings_title": MessageLookupByLibrary.simpleMessage("Assistance"),
        "settings_typeResetConfirmation": MessageLookupByLibrary.simpleMessage(
            "Tapez RESET pour confirmer définitivement."),
        "settings_vitaleDiagnostic":
            MessageLookupByLibrary.simpleMessage("Diagnostic Carte Vitale"),
        "smartCardDiagnostic":
            MessageLookupByLibrary.simpleMessage("Diagnostic Carte Vitale"),
        "speechDictationButton_audio": MessageLookupByLibrary.simpleMessage(
            "Aucun enregistrement audio disponible."),
        "speechDictationButton_close":
            MessageLookupByLibrary.simpleMessage("Fermer"),
        "speechDictationButton_dictate":
            MessageLookupByLibrary.simpleMessage("Dicter"),
        "speechDictationButton_download":
            MessageLookupByLibrary.simpleMessage("Télécharger le module"),
        "speechDictationButton_failure": m54,
        "speechDictationButton_information": MessageLookupByLibrary.simpleMessage(
            "La dictée vocale nécessite l’installation du module optionnel ABAK Dictée vocale.\n\nCe module est gratuit et fonctionne localement sur votre ordinateur, sans envoyer les enregistrements vocaux sur Internet.\n\nLe téléchargement représente environ 1,5 Go."),
        "speechDictationButton_stop":
            MessageLookupByLibrary.simpleMessage("Arrêter la dictée"),
        "speechDictationButton_title":
            MessageLookupByLibrary.simpleMessage("Dictée vocale"),
        "speechRecordingService_permission":
            MessageLookupByLibrary.simpleMessage(
                "L’accès au microphone n’est pas autorisé."),
        "systemOverviewBar_active_patients":
            MessageLookupByLibrary.simpleMessage("Patients actifs"),
        "systemOverviewBar_alert":
            MessageLookupByLibrary.simpleMessage("Alertes"),
        "systemOverviewBar_archived_patients":
            MessageLookupByLibrary.simpleMessage("Patients archivés"),
        "systemOverviewBar_loading_system_summary":
            MessageLookupByLibrary.simpleMessage(
                "Chargement du résumé système..."),
        "systemOverviewBar_supervision_error":
            MessageLookupByLibrary.simpleMessage("Erreur supervision"),
        "systemOverviewBar_supervision_unavailable":
            MessageLookupByLibrary.simpleMessage("Supervision indisponible"),
        "systemStatusCard_nome": MessageLookupByLibrary.simpleMessage("Aucune"),
        "userPreferences":
            MessageLookupByLibrary.simpleMessage("Paramètres utilisateur"),
        "user_settings":
            MessageLookupByLibrary.simpleMessage("Paramètres utilisateur"),
        "vitaleBeneficiarySelector_cancel":
            MessageLookupByLibrary.simpleMessage("Annuler"),
        "vitaleBeneficiarySelector_help": MessageLookupByLibrary.simpleMessage(
            "Cette fenêtre permet de choisir la personne concernée lorsque plusieurs bénéficiaires sont proposés après la lecture de la carte Vitale.\n\nVérifiez le nom, le prénom et la date de naissance lorsqu’elle est disponible, puis cliquez sur la ligne du bénéficiaire souhaité.\n\nLa sélection ferme cette fenêtre et transmet l’identité choisie à l’étape suivante.\n\n« Annuler » ferme la fenêtre sans sélectionner de bénéficiaire."),
        "vitaleBeneficiarySelector_selectBeneficiary":
            MessageLookupByLibrary.simpleMessage(
                "Sélectionnez un bénéficiaire"),
        "vitaleDiagnostic_help": MessageLookupByLibrary.simpleMessage(
            "Cet écran permet de vérifier le fonctionnement du dispositif de lecture de la carte Vitale.\n\nSous Windows, la rubrique consacrée au module indique son état et permet d’actualiser cette information.\n\nLancez une lecture avec le lecteur connecté et la carte insérée. Si plusieurs bénéficiaires sont proposés, sélectionnez la personne concernée pour consulter les informations lues.\n\nLes messages affichés permettent de comprendre un éventuel échec et peuvent être communiqués à l’assistance.\n\nLa rubrique « Diagnostic avancé » propose un test technique de communication avec la carte. Utilisez-la selon les indications de la documentation ABAK ou d’un technicien.\n\nCet écran sert au diagnostic : la lecture d’une identité ne crée pas de fiche patient."),
        "vitaleIdentity_birthDate":
            MessageLookupByLibrary.simpleMessage("Date de naissance"),
        "vitaleIdentity_dataMasked":
            MessageLookupByLibrary.simpleMessage("donnée masquée"),
        "vitaleIdentity_detected":
            MessageLookupByLibrary.simpleMessage("détecté"),
        "vitaleIdentity_female":
            MessageLookupByLibrary.simpleMessage("Féminin"),
        "vitaleIdentity_firstName":
            MessageLookupByLibrary.simpleMessage("Prénom"),
        "vitaleIdentity_help": MessageLookupByLibrary.simpleMessage(
            "Cet écran permet de lire l’identité d’un bénéficiaire depuis une carte Vitale, lorsque le lecteur et le module de lecture sont disponibles.\n\nLa lecture démarre à l’ouverture de l’écran. Vous pouvez la relancer avec le bouton de lecture. Si plusieurs bénéficiaires sont présents sur la carte, sélectionnez la personne concernée.\n\nVérifiez le nom, le prénom, la date de naissance et les autres informations affichées. Le numéro d’identification est signalé comme détecté ou indisponible, sans être affiché intégralement.\n\nLorsque l’identité est utilisable, le bouton de création du patient permet de transmettre ces informations au formulaire de création.\n\nSi aucune identité n’est disponible, consultez le message affiché et vérifiez le dispositif de lecture avant de réessayer. Vous pouvez revenir à l’écran précédent pour effectuer une saisie manuelle."),
        "vitaleIdentity_identityRead":
            MessageLookupByLibrary.simpleMessage("Identité lue"),
        "vitaleIdentity_identityReceivedMasked":
            MessageLookupByLibrary.simpleMessage(
                "identité reçue (données personnelles masquées)"),
        "vitaleIdentity_identityUnavailable":
            MessageLookupByLibrary.simpleMessage("identité non disponible"),
        "vitaleIdentity_lastName": MessageLookupByLibrary.simpleMessage("Nom"),
        "vitaleIdentity_male": MessageLookupByLibrary.simpleMessage("Masculin"),
        "vitaleIdentity_nir": MessageLookupByLibrary.simpleMessage("NIR"),
        "vitaleIdentity_noIdentityAvailable":
            MessageLookupByLibrary.simpleMessage(
                "Aucune identité Carte Vitale disponible"),
        "vitaleIdentity_notProvided":
            MessageLookupByLibrary.simpleMessage("Non renseigné"),
        "vitaleIdentity_other": MessageLookupByLibrary.simpleMessage("Autre"),
        "vitaleIdentity_reading":
            MessageLookupByLibrary.simpleMessage("Lecture en cours..."),
        "vitaleIdentity_sex": MessageLookupByLibrary.simpleMessage("Sexe"),
        "vitaleIdentity_source": MessageLookupByLibrary.simpleMessage("Source"),
        "vitaleIdentity_title":
            MessageLookupByLibrary.simpleMessage("Lire identité Carte Vitale"),
        "vitaleIdentity_unavailable":
            MessageLookupByLibrary.simpleMessage("Non disponible"),
        "vitaleIdentity_useForPatientCreation":
            MessageLookupByLibrary.simpleMessage(
                "Utiliser pour créer un patient"),
        "walkingAid_cane": MessageLookupByLibrary.simpleMessage("Canne"),
        "walkingAid_label":
            MessageLookupByLibrary.simpleMessage("Aide utilisée"),
        "walkingAid_none": MessageLookupByLibrary.simpleMessage("Aucune"),
        "walkingAid_other": MessageLookupByLibrary.simpleMessage("Autre"),
        "walkingAid_rollatorFourWheels":
            MessageLookupByLibrary.simpleMessage("Rollator 4 roues"),
        "walkingAid_walkerTwoWheels":
            MessageLookupByLibrary.simpleMessage("Déambulateur 2 roues")
      };
}
