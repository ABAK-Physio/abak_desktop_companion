// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that looks up messages for specific locales by
// delegating to the appropriate library.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:implementation_imports, file_names, unnecessary_new
// ignore_for_file:unnecessary_brace_in_string_interps, directives_ordering
// ignore_for_file:argument_type_not_assignable, invalid_assignment
// ignore_for_file:prefer_single_quotes, prefer_generic_function_type_aliases
// ignore_for_file:comment_references

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';
import 'package:intl/src/intl_helpers.dart';

import 'messages_de_DE.dart' as messages_de_de;
import 'messages_en_GB.dart' as messages_en_gb;
import 'messages_es_ES.dart' as messages_es_es;
import 'messages_fr_FR.dart' as messages_fr_fr;
import 'messages_it_IT.dart' as messages_it_it;
import 'messages_nl_NL.dart' as messages_nl_nl;
import 'messages_pt_PT.dart' as messages_pt_pt;

typedef Future<dynamic> LibraryLoader();
Map<String, LibraryLoader> _deferredLibraries = {
  'de_DE': () => new SynchronousFuture(null),
  'en_GB': () => new SynchronousFuture(null),
  'es_ES': () => new SynchronousFuture(null),
  'fr_FR': () => new SynchronousFuture(null),
  'it_IT': () => new SynchronousFuture(null),
  'nl_NL': () => new SynchronousFuture(null),
  'pt_PT': () => new SynchronousFuture(null),
};

MessageLookupByLibrary? _findExact(String localeName) {
  switch (localeName) {
    case 'de_DE':
      return messages_de_de.messages;
    case 'en_GB':
      return messages_en_gb.messages;
    case 'es_ES':
      return messages_es_es.messages;
    case 'fr_FR':
      return messages_fr_fr.messages;
    case 'it_IT':
      return messages_it_it.messages;
    case 'nl_NL':
      return messages_nl_nl.messages;
    case 'pt_PT':
      return messages_pt_pt.messages;
    default:
      return null;
  }
}

/// User programs should call this before using [localeName] for messages.
Future<bool> initializeMessages(String localeName) {
  var availableLocale = Intl.verifiedLocale(
      localeName, (locale) => _deferredLibraries[locale] != null,
      onFailure: (_) => null);
  if (availableLocale == null) {
    return new SynchronousFuture(false);
  }
  var lib = _deferredLibraries[availableLocale];
  lib == null ? new SynchronousFuture(false) : lib();
  initializeInternalMessageLookup(() => new CompositeMessageLookup());
  messageLookup.addLocale(availableLocale, _findGeneratedMessagesFor);
  return new SynchronousFuture(true);
}

bool _messagesExistFor(String locale) {
  try {
    return _findExact(locale) != null;
  } catch (e) {
    return false;
  }
}

MessageLookupByLibrary? _findGeneratedMessagesFor(String locale) {
  var actualLocale =
      Intl.verifiedLocale(locale, _messagesExistFor, onFailure: (_) => null);
  if (actualLocale == null) return null;
  return _findExact(actualLocale);
}
