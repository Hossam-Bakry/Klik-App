import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../constants/app_links.dart';
import '../extensions/context_extensions.dart';
import '../localization/locale_keys.dart';

/// Opens the platform share sheet with an invitation to the app.
///
/// [context] should belong to the widget that was tapped — iPad anchors the
/// sheet to it, and throws without a position to point at.
Future<void> shareApp(BuildContext context) async {
  final box = context.findRenderObject() as RenderBox?;

  await SharePlus.instance.share(
    ShareParams(
      text: '${context.tr(LocaleKeys.shareAppMessage)}\n${AppLinks.website}',
      // Used as the mail subject when the customer picks an email app.
      subject: context.tr(LocaleKeys.appName),
      sharePositionOrigin: box == null
          ? null
          : box.localToGlobal(Offset.zero) & box.size,
    ),
  );
}
