import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';

/// JSON/map-based localization. Each supported locale has a flat
/// `assets/lang/<code>.json` of `key → text`; [translate] looks a key up in
/// the loaded map (falling back to the key itself so missing strings are
/// visible rather than blank).
///
/// Keys must be unique per file — they are the map lookup. Reference them via
/// [LocaleKeys] (or `context.tr(...)`) instead of raw strings.
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const List<Locale> supportedLocales = [Locale('en'), Locale('ar')];

  static AppLocalizations of(BuildContext context) => Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  Map<String, String> _localizedStrings = {};

  /// Loads (or reloads) the JSON map for [locale] from assets.
  Future<bool> load() async {
    final jsonString = await rootBundle.loadString('assets/lang/${locale.languageCode}.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
    return true;
  }

  /// This method will be called from every page which needs a localized text;
  /// that means we can not have two items with the same key — we access the
  /// map using that key. In debug, a miss triggers a reload so newly-added
  /// keys show up without a hot restart.
  String translate(String key) {
    if (kDebugMode) {
      if (_localizedStrings[key] == null) {
        unawaited(load());
      }
    }
    return _localizedStrings[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
