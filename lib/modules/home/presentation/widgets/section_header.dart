import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';

/// Title on the leading side with an optional "See all" link — shared by every
/// home section so their headers stay visually consistent.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: context.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (onSeeAll != null)
          AppButton.text(
            label: context.tr(LocaleKeys.seeAll),
            foregroundColor: AppColors.textSecondary,
            onPressed: onSeeAll!,
          ),
      ],
    );
  }
}
