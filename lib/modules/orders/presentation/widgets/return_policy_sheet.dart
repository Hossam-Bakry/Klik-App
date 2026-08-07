import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';

/// "Which items can be returned?" — the help sheet behind the order's Get Help
/// action and the cancel dialog's Return Policy link.
///
/// The rules are static copy: no endpoint serves return policy, so they live in
/// the language files. Resolves to true when the customer asked to read more.
Future<bool> showReturnPolicySheet(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _ReturnPolicySheet(),
  );
  return result ?? false;
}

class _ReturnPolicySheet extends StatelessWidget {
  const _ReturnPolicySheet();

  /// Each rule and whether it qualifies for a return.
  static const _rules = <(String, bool)>[
    (LocaleKeys.returnRuleUnopened, true),
    (LocaleKeys.returnRuleDamaged, true),
    (LocaleKeys.returnRuleWithin14Days, true),
    (LocaleKeys.returnRuleUsed, false),
    (LocaleKeys.returnRuleDigital, false),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: context.edge(left: 20, right: 20, top: 12, bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: context.r(44),
              height: context.r(4),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(context.r(4)),
              ),
            ),
          ),
          context.gapH(16),
          Text(
            context.tr(LocaleKeys.whichItemsCanBeReturned),
            style: context.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          context.gapH(16),
          for (final (key, allowed) in _rules) ...[
            _Rule(label: context.tr(key), allowed: allowed),
            context.gapH(14),
          ],
          context.gapH(6),
          AppButton.outline(
            label: context.tr(LocaleKeys.learnMoreReturnPolicy),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
}

/// One rule: a green tick when it qualifies, a red cross when it doesn't.
class _Rule extends StatelessWidget {
  const _Rule({required this.label, required this.allowed});

  final String label;
  final bool allowed;

  @override
  Widget build(BuildContext context) {
    final color = allowed ? AppColors.success : AppColors.error;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          allowed ? Icons.check_circle_rounded : Icons.cancel_rounded,
          size: context.r(20),
          color: color,
        ),
        context.gapW(10),
        Expanded(
          child: Text(
            label,
            style: context.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
