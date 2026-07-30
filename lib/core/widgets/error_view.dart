import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../localization/locale_keys.dart';
import 'empty_view.dart';

/// Centered failure state: a cloud-off icon, the error [message], and a retry
/// button. A thin [EmptyView] specialization shared app-wide by any page that
/// loads data (products, wishlist, ...).
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyView(
      icon: Icons.cloud_off_rounded,
      message: message,
      actionLabel: context.tr(LocaleKeys.retry),
      onAction: onRetry,
    );
  }
}
