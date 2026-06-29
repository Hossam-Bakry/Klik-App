import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:klik_app/gen/assets.gen.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../cubit/password_reset_cubit.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_illustration.dart';
import '../widgets/auth_scaffold.dart';

const int _otpLength = 6;
const int _resendSeconds = 40;

/// Receives the in-flight [PasswordResetCubit] from the forgot-password screen
/// (via `extra`) so the captured phone + step state carry over.
class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key, required this.cubit});

  final PasswordResetCubit cubit;

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otpController = TextEditingController();
  final _otpFocusNode = FocusNode();
  Timer? _timer;
  int _remaining = _resendSeconds;

  String get _code => _otpController.text;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() => _remaining = _resendSeconds);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining <= 1) {
        t.cancel();
        setState(() => _remaining = 0);
      } else {
        setState(() => _remaining--);
      }
    });
  }

  void _resend() {
    final s = widget.cubit.state;
    widget.cubit.sendOtp(phone: s.phone, countryIso: s.countryIso, countryCode: s.countryCode);
    _startCountdown();
  }

  String get _timerLabel {
    final m = (_remaining ~/ 60).toString().padLeft(2, '0');
    final s = (_remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.cubit,
      child: BlocConsumer<PasswordResetCubit, PasswordResetState>(
        listenWhen: (p, c) => p.status != c.status,
        listener: (context, state) {
          if (state.status == ResetStatus.verified) {
            // Hand the same cubit (now holding the reset token) to the
            // change-password screen via `extra`.
            context.pushReplacement(AppRoutes.changePassword, extra: widget.cubit);
          } else if (state.status == ResetStatus.failure && state.error != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          final loading = state.status == ResetStatus.loading;
          return AuthScaffold(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                context.gapH(32),
                Center(child: AuthIllustration(child: Assets.images.otpImg.image())),
                context.gapH(28),
                AuthHeader(
                  title: context.tr(LocaleKeys.enterOtp),
                  subtitle: '${context.tr(LocaleKeys.otpSentTo)}\n+${state.countryCode}${state.phone}',
                ),
                context.gapH(32),
                _OtpInput(
                  controller: _otpController,
                  focusNode: _otpFocusNode,
                  onChanged: (_) => setState(() {}),
                  onCompleted: widget.cubit.verify,
                ),
                context.gapH(20),
                _ResendRow(remaining: _remaining, label: _timerLabel, onResend: _resend),
                context.gapH(24),
                AppButton.filled(
                  label: context.tr(LocaleKeys.verifyOtp),
                  isLoading: loading,
                  onPressed: _code.length < _otpLength ? null : () => widget.cubit.verify(_code),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OtpInput extends StatelessWidget {
  const _OtpInput({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onCompleted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onCompleted;

  @override
  Widget build(BuildContext context) {
    final defaultTheme = PinTheme(
      width: context.r(50),
      height: context.r(70),
      textStyle: TextStyle(fontSize: context.sp(24), fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(color: const Color(0xFFE6E0D4)),
      ),
    );

    return Pinput(
      length: _otpLength,
      controller: controller,
      focusNode: focusNode,
      autofocus: true,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      defaultPinTheme: defaultTheme,
      focusedPinTheme: defaultTheme.copyDecorationWith(
        border: Border.all(color: AppColors.primary, width: 1.4),
      ),
      submittedPinTheme: defaultTheme.copyDecorationWith(
        border: Border.all(color: AppColors.primary),
      ),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      onChanged: onChanged,
      onCompleted: onCompleted,
    );
  }
}

class _ResendRow extends StatelessWidget {
  const _ResendRow({required this.remaining, required this.label, required this.onResend});

  final int remaining;
  final String label;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    if (remaining > 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.access_time, size: context.r(16), color: AppColors.primary),
          context.gapW(6),
          Text(
            '${context.tr(LocaleKeys.resendOtpIn)} $label',
            style: TextStyle(color: AppColors.textSecondary, fontSize: context.sp(13)),
          ),
        ],
      );
    }
    return Center(
      child: AppButton.text(
        label: context.tr(LocaleKeys.sendOtp),
        foregroundColor: AppColors.primary,
        onPressed: onResend,
      ),
    );
  }
}
