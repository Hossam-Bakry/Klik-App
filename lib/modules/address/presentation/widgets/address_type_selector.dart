import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/address.dart';

/// Home / Work / Other chips that pick the [AddressType]. The selected chip is
/// filled with the brand bronze; the rest are outlined.
class AddressTypeSelector extends StatelessWidget {
  const AddressTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final AddressType selected;
  final ValueChanged<AddressType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _chip(context, AddressType.home, Icons.home_outlined, LocaleKeys.typeHome),
        context.gapW(12),
        _chip(context, AddressType.work, Icons.work_outline, LocaleKeys.typeWork),
        context.gapW(12),
        _chip(context, AddressType.other, Icons.location_city_outlined, LocaleKeys.typeOther),
      ],
    );
  }

  Widget _chip(BuildContext context, AddressType type, IconData icon, String key) {
    final isSelected = type == selected;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(context.r(12)),
        onTap: () => onChanged(type),
        child: Container(
          padding: context.edgeSymmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(context.r(12)),
            border: Border.all(color: AppColors.primary, width: 1.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: context.r(18),
                color: isSelected ? Colors.white : AppColors.primary,
              ),
              context.gapW(6),
              Text(
                context.tr(key),
                style: TextStyle(
                  fontSize: context.sp(14),
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
