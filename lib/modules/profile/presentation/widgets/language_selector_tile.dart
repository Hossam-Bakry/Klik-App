import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../gen/assets.gen.dart';
import 'profile_menu_tile.dart';

/// English display names for the locales the app ships translations for. New
/// languages appear automatically once added to [AppLocalizations.supportedLocales]
/// and given an entry here.
const Map<String, String> _languageNames = {'en': 'English', 'ar': 'Arabic'};

/// "Language" row that expands into the list of supported languages. Picking
/// one switches the app locale via [LocaleCubit] (persisted across launches).
class LanguageSelectorTile extends StatefulWidget {
  const LanguageSelectorTile({super.key});

  @override
  State<LanguageSelectorTile> createState() => _LanguageSelectorTileState();
}

class _LanguageSelectorTileState extends State<LanguageSelectorTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileMenuTile(
          icon: Assets.icons.languageIcn,
          title: context.tr(LocaleKeys.language),
          trailing: AnimatedRotation(
            turns: _expanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: context.r(24),
              color: AppColors.primary,
            ),
          ),
          onTap: () => setState(() => _expanded = !_expanded),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: _LanguageOptions(
            onSelected: () => setState(() => _expanded = false),
          ),
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
        ),
      ],
    );
  }
}

class _LanguageOptions extends StatelessWidget {
  const _LanguageOptions({required this.onSelected});

  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return Container(
          margin: context.edge(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(context.r(12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (final supported in AppLocalizations.supportedLocales)
                _LanguageOption(
                  label: _languageNames[supported.languageCode] ??
                      supported.languageCode,
                  selected: supported.languageCode == locale.languageCode,
                  onTap: () {
                    context.read<LocaleCubit>().setLocale(supported);
                    onSelected();
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        color: selected
            ? AppColors.secondary.withValues(alpha: 0.25)
            : Colors.transparent,
        padding: context.edgeSymmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: context.bodyLarge?.copyWith(
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            if (selected)
              Icon(
                Icons.check_rounded,
                size: context.r(20),
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}
