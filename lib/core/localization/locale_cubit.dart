import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_localizations.dart';

/// App-level cubit holding the active [Locale], persisted across launches.
/// `MaterialApp.router` rebuilds from its state, and the Dio
/// `accept-language` header reads `state.languageCode`.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._prefs) : super(_initial(_prefs));

  final SharedPreferences _prefs;
  static const _key = 'locale_code';

  /// Locales the app ships translations for (sourced from the generated
  /// AppLocalizations).
  static List<Locale> get supported => AppLocalizations.supportedLocales;

  static Locale _initial(SharedPreferences prefs) {
    final code = prefs.getString(_key);
    final match = supported
        .where((l) => l.languageCode == code)
        .cast<Locale?>()
        .firstWhere((_) => true, orElse: () => null);
    return match ?? const Locale('en');
  }

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode == state.languageCode) return;
    await _prefs.setString(_key, locale.languageCode);
    emit(locale);
  }

  /// Convenience toggle between English and Arabic.
  Future<void> toggle() => setLocale(
        state.languageCode == 'ar' ? const Locale('en') : const Locale('ar'),
      );
}
