import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:klik_app/gen/assets.gen.dart';

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
  final _controllers = List.generate(_otpLength, (_) => TextEditingController());
  final _focusNodes = List.generate(_otpLength, (_) => FocusNode());
  Timer? _timer;
  int _remaining = _resendSeconds;

  String get _code => _controllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _focusNodes) {
      n.dispose();
    }
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

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
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
                _OtpBoxes(controllers: _controllers, focusNodes: _focusNodes, onChanged: _onDigitChanged),
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

class _OtpBoxes extends StatelessWidget {
  const _OtpBoxes({required this.controllers, required this.focusNodes, required this.onChanged});

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final void Function(int index, String value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < _otpLength; i++)
          SizedBox(
            width: context.r(50),
            height: context.r(70),
            child: TextField(
              controller: controllers[i],
              focusNode: focusNodes[i],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              style: TextStyle(fontSize: context.sp(24), fontWeight: FontWeight.w600),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: EdgeInsets.zero,
                enabledBorder: _border(context, const Color(0xFFE6E0D4)),
                focusedBorder: _border(context, AppColors.primary, 1.4),
              ),
              onChanged: (v) => onChanged(i, v),
            ),
          ),
      ],
    );
  }

  OutlineInputBorder _border(BuildContext context, Color color, [double width = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(context.r(12)),
    borderSide: BorderSide(color: color, width: width),
  );
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
