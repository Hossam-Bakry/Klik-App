import 'package:flutter/material.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';

/// Rounded search input that sits under the greeting. Presentational for now —
/// wire [onChanged]/[onSubmitted] when product search lands.
class HomeSearchField extends StatelessWidget {
  const HomeSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.r(50));
    OutlineInputBorder border(Color color, [double width = 0]) =>
        OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none);

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        style: TextStyle(fontSize: context.sp(15), color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: context.tr(LocaleKeys.searchHint),
          hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: context.sp(14)),
          filled: true,
          fillColor: AppColors.surface,
          suffixIcon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Assets.icons.searchIcn.svg(width: context.w(20)),
          ),
          contentPadding: context.edgeSymmetric(vertical: 14, horizontal: 16),

          enabledBorder: border(const Color(0xFFE6E0D4)),
          focusedBorder: border(AppColors.primary, 1.4),
        ),
      ),
    );
  }
}
