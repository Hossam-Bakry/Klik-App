import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';

/// Rounded search input that sits under the greeting. Presentational for now —
/// wire [onChanged]/[onSubmitted] when product search lands.
class HomeSearchField extends StatelessWidget {
  const HomeSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.r(14));
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: color, width: width));

    return TextField(
      style: TextStyle(fontSize: context.sp(15), color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: context.tr(LocaleKeys.searchHint),
        hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: context.sp(15)),
        filled: true,
        fillColor: AppColors.surface,
        prefixIcon: Icon(Icons.search, color: AppColors.textSecondary, size: context.r(22)),
        contentPadding: context.edgeSymmetric(vertical: 14, horizontal: 16),
        enabledBorder: border(const Color(0xFFE6E0D4)),
        focusedBorder: border(AppColors.primary, 1.4),
      ),
    );
  }
}
