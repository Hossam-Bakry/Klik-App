import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/checkout_cubit.dart';

/// The Address → Payment → Review header: a circled icon per step joined by a
/// rail, the current one ringed in bronze.
class CheckoutStepper extends StatelessWidget {
  const CheckoutStepper({super.key, required this.current, this.onStepTapped});

  final CheckoutStep current;

  /// Lets the customer jump back to a step they've already been through.
  final ValueChanged<CheckoutStep>? onStepTapped;

  @override
  Widget build(BuildContext context) {
    const steps = CheckoutStep.values;

    return Padding(
      padding: context.edgeSymmetric(horizontal: 24, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            if (i > 0)
              Expanded(
                child: Padding(
                  // Sit the rail on the circles' centre line.
                  padding: context.edge(top: 21),
                  child: Container(
                    height: context.r(1.5),
                    color: i <= current.index
                        ? AppColors.primaryBronze
                        : AppColors.border,
                  ),
                ),
              ),
            _Step(
              step: steps[i],
              state: switch (i.compareTo(current.index)) {
                < 0 => _StepState.done,
                0 => _StepState.current,
                _ => _StepState.upcoming,
              },
              // Only steps already visited are reachable from here.
              onTap: i < current.index && onStepTapped != null
                  ? () => onStepTapped!(steps[i])
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}

enum _StepState { done, current, upcoming }

class _Step extends StatelessWidget {
  const _Step({required this.step, required this.state, this.onTap});

  final CheckoutStep step;
  final _StepState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final active = state != _StepState.upcoming;
    final tint = active ? AppColors.primaryBronze : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: context.r(42),
            height: context.r(42),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: state == _StepState.current
                  ? AppColors.surface
                  : AppColors.dark.withValues(alpha: 0.04),
              border: Border.all(
                color: state == _StepState.current
                    ? AppColors.primaryBronze
                    : Colors.transparent,
                width: context.r(1.5),
              ),
            ),
            child: Icon(_icon, size: context.r(20), color: tint),
          ),
          context.gapH(6),
          Text(
            context.tr(_labelKey),
            style: context.labelSmall?.copyWith(
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  IconData get _icon => switch (step) {
    CheckoutStep.address => Icons.location_on_outlined,
    CheckoutStep.payment => Icons.credit_card_rounded,
    CheckoutStep.review => Icons.receipt_long_outlined,
  };

  String get _labelKey => switch (step) {
    CheckoutStep.address => LocaleKeys.stepAddress,
    CheckoutStep.payment => LocaleKeys.stepPayment,
    CheckoutStep.review => LocaleKeys.stepReview,
  };
}
