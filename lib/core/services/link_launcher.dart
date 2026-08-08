import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../extensions/context_extensions.dart';
import '../localization/locale_keys.dart';
import '../widgets/app_toast.dart';

/// Opens a web link in an in-app browser view — Custom Tabs on Android,
/// SFSafariViewController on iOS — so the customer keeps the app's back stack
/// instead of being handed to another app.
///
/// Falls back to whatever browser the device has if the in-app view isn't
/// available, and toasts rather than throwing when nothing can open it.
Future<void> openLink(BuildContext context, String url) async {
  final uri = Uri.tryParse(url);

  if (uri != null) {
    for (final mode in const [
      LaunchMode.inAppBrowserView,
      LaunchMode.externalApplication,
    ]) {
      try {
        if (await launchUrl(uri, mode: mode)) return;
      } on PlatformException {
        // Try the next mode: a device with no Custom Tabs provider throws
        // rather than answering false.
        continue;
      }
    }
  }

  if (context.mounted) {
    AppToast.error(context, context.tr(LocaleKeys.couldNotOpenLink));
  }
}
