import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

import '../constants/countries.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_colors.dart';

/// Phone country-code selector showing the country's flag (as an image, via
/// `country_flags`) + dial code, opening a popup of the Arab countries.
class CountryCodePicker extends StatelessWidget {
  const CountryCodePicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final Country selected;
  final ValueChanged<Country> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Country>(
      onSelected: onChanged,
      initialValue: selected,
      color: Color(0xFFFDF9F1),
      offset: Offset(0, context.r(44)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.r(12)),
      ),
      itemBuilder: (context) => [
        for (final c in Countries.all)
          PopupMenuItem<Country>(
            value: c,
            child: Row(
              children: [
                _Flag(isoCode: c.isoCode),
                context.gapW(10),
                Text(
                  '+${c.dialCode}',
                  style: TextStyle(
                    fontSize: context.sp(14),
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textSecondary,
            size: context.r(20),
          ),
          context.gapW(6),
          _Flag(isoCode: selected.isoCode),
          context.gapW(6),
          Text(
            '+ ${selected.dialCode}',
            style: TextStyle(
              fontSize: context.sp(14),
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Flag extends StatelessWidget {
  const _Flag({required this.isoCode});

  final String isoCode;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(context.r(3)),
      child: CountryFlag.fromCountryCode(
        isoCode,
        theme: ImageTheme(width: context.r(26), height: context.r(18)),
      ),
    );
  }
}
