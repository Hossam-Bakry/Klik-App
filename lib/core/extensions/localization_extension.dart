import 'package:flutter/widgets.dart';

import '../localization/app_localizations.dart';

/// Localized text from context: `context.tr(LocaleKeys.skip)`.
extension LocalizationExtension on BuildContext {
  String tr(String key) => AppLocalizations.of(this).translate(key);
}
