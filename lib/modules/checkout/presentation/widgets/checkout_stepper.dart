import 'package:flutter/material.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/checkout_cubit.dart';

/// The Address → Payment → Review header: a circled icon per step joined by a
/// rail, the current one ringed in bronze.
class CheckoutStepper extends StatelessWidget {
  const CheckoutStepper({super.key, required this.current, this.onStepTapped});

  /// The rail's gradient, per the design: bronze into the light track colour.
  /// [_railStart] is [AppColors.primaryBronze]; [_railEnd] is a shade lighter
  /// than [AppColors.border] and lives here as the design gave it.
  static const Color _railStart = AppColors.primaryBronze;
  static const Color _railEnd = Color(0xFFF2F2F2);

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
                    height: context.r(3),
                    decoration: BoxDecoration(
                      gradient: _railGradient(segment: i - 1),
                    ),
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

  /// The gradient rides the one rail touching the current step, bronze at that
  /// step and fading away from it: step 1 colours the rail ahead of it (it has
  /// none behind), every later step colours the rail behind. All other rails
  /// are flat track.
  ///
  /// [segment] is the rail between step `segment` and `segment + 1`.
  /// Directional stops so the bronze end stays against the step in Arabic.
  LinearGradient _railGradient({required int segment}) {
    final at = current.index;

    // Step 1 leans on the rail in front of it; the rest on the one behind.
    if (segment != (at == 0 ? 0 : at - 1)) {
      return const LinearGradient(colors: [_railEnd, _railEnd]);
    }

    return LinearGradient(
      begin: AlignmentDirectional.centerStart,
      end: AlignmentDirectional.centerEnd,
      // The current step sits at the rail's leading edge only when it's the
      // first one; otherwise it's the trailing edge, so the bronze flips.
      colors: at == 0
          ? const [_railStart, _railEnd]
          : const [_railEnd, _railStart],
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
    // Only the step being filled in is picked out — a step already behind you
    // drops back to the muted treatment, as the design draws it. The rail is
    // what shows how far along the checkout is.
    final active = state == _StepState.current;
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
              color: active
                  ? AppColors.surface
                  : AppColors.dark.withValues(alpha: 0.04),
              border: Border.all(
                color: active ? AppColors.primaryBronze : Colors.transparent,
                width: context.r(3),
              ),
            ),
            child: _icon.svg(
              colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
            ),
          ),
          context.gapH(6),
          Text(
            context.tr(_labelKey),
            style: context.bodySmall?.copyWith(
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  SvgGenImage get _icon => switch (step) {
    CheckoutStep.address => Assets.icons.checkoutLocationIcn,
    CheckoutStep.payment => Assets.icons.checkoutPaymentIcn,
    CheckoutStep.review => Assets.icons.checkoutPreviewIcn,
  };

  String get _labelKey => switch (step) {
    CheckoutStep.address => LocaleKeys.stepAddress,
    CheckoutStep.payment => LocaleKeys.stepPayment,
    CheckoutStep.review => LocaleKeys.stepReview,
  };
}
