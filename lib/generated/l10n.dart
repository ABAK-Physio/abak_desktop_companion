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
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
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
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `ABAK Desktop Companion`
  String get appTitle {
    return Intl.message(
      'ABAK Desktop Companion',
      name: 'appTitle',
      desc: '',
      args: [],
    );
  }

  /// `Accueil`
  String get home {
    return Intl.message('Accueil', name: 'home', desc: '', args: []);
  }

  /// `Patients`
  String get patients {
    return Intl.message('Patients', name: 'patients', desc: '', args: []);
  }

  /// `Kinés`
  String get practitioners {
    return Intl.message('Kinés', name: 'practitioners', desc: '', args: []);
  }

  /// `Appareils`
  String get devices {
    return Intl.message('Appareils', name: 'devices', desc: '', args: []);
  }

  /// `Archives`
  String get archives {
    return Intl.message('Archives', name: 'archives', desc: '', args: []);
  }

  /// `Réglages`
  String get settings {
    return Intl.message('Réglages', name: 'settings', desc: '', args: []);
  }

  /// `Informations`
  String get information {
    return Intl.message(
      'Informations',
      name: 'information',
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

  /// `Associer un téléphone`
  String get pairPhone {
    return Intl.message(
      'Associer un téléphone',
      name: 'pairPhone',
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

  /// `Associer un téléphone`
  String get pairPhoneDialogTitle {
    return Intl.message(
      'Associer un téléphone',
      name: 'pairPhoneDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Adresse IP introuvable`
  String get ipAddressNotFound {
    return Intl.message(
      'Adresse IP introuvable',
      name: 'ipAddressNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Impossible de déterminer l'adresse IP locale du Desktop.\n\nVérifiez que l'ordinateur est connecté au réseau local.`
  String get ipAddressNotFoundMessage {
    return Intl.message(
      'Impossible de déterminer l\'adresse IP locale du Desktop.\n\nVérifiez que l\'ordinateur est connecté au réseau local.',
      name: 'ipAddressNotFoundMessage',
      desc: '',
      args: [],
    );
  }

  /// `Fermer`
  String get close {
    return Intl.message('Fermer', name: 'close', desc: '', args: []);
  }

  /// `OK`
  String get ok {
    return Intl.message('OK', name: 'ok', desc: '', args: []);
  }

  /// `Adresse`
  String get desktopAddress {
    return Intl.message('Adresse', name: 'desktopAddress', desc: '', args: []);
  }

  /// `Port`
  String get desktopPort {
    return Intl.message('Port', name: 'desktopPort', desc: '', args: []);
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

  /// `Paramètres utilisateur`
  String get userPreferences {
    return Intl.message(
      'Paramètres utilisateur',
      name: 'userPreferences',
      desc: '',
      args: [],
    );
  }

  /// `Langue de l'application`
  String get applicationLanguage {
    return Intl.message(
      'Langue de l\'application',
      name: 'applicationLanguage',
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

  /// `Dossier d'échange ABAK`
  String get exchangeDirectory {
    return Intl.message(
      'Dossier d\'échange ABAK',
      name: 'exchangeDirectory',
      desc: '',
      args: [],
    );
  }

  /// `Chargement...`
  String get loading {
    return Intl.message('Chargement...', name: 'loading', desc: '', args: []);
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

  /// `Ouvrir`
  String get open {
    return Intl.message('Ouvrir', name: 'open', desc: '', args: []);
  }

  /// `Modifier`
  String get modify {
    return Intl.message('Modifier', name: 'modify', desc: '', args: []);
  }

  /// `Réinitialiser`
  String get reset {
    return Intl.message('Réinitialiser', name: 'reset', desc: '', args: []);
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

  /// `Dossier d'échange réinitialisé`
  String get exchangeDirectoryReset {
    return Intl.message(
      'Dossier d\'échange réinitialisé',
      name: 'exchangeDirectoryReset',
      desc: '',
      args: [],
    );
  }

  /// `Ouverture du dossier d'échange`
  String get openingExchangeDirectory {
    return Intl.message(
      'Ouverture du dossier d\'échange',
      name: 'openingExchangeDirectory',
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
