import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../../../core/constants/countries.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../cubit/password_reset_cubit.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_illustration.dart';
import '../widgets/auth_scaffold.dart';

/// Pure consumer — its [PasswordResetCubit] is provided at the route (see
/// AppRouter) and passed on to the OTP route via `extra`.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  Country _country = Countries.defaultCountry;

  @override
  void initState() {
    super.initState();
    // Rebuild as the user types so Send OTP enables/disables live.
    _phone.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _phone.removeListener(_onInputChanged);
    _phone.dispose();
    super.dispose();
  }

  void _onInputChanged() => setState(() {});

  /// Disabled until a valid phone for the selected country is entered.
  bool get _canSubmit =>
      _country.isValidPhone(_phone.text.trim()) &&
      !_phone.text.trim().startsWith('0');

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final cubit = context.read<PasswordResetCubit>();
    // sendOtp either sends (new/expired number) or reuses the live code (same
    // number still in cooldown); both resolve to `otpSent`. Navigate
    // imperatively on the result so re-tapping the same number still opens the
    // OTP screen even though the status didn't change.
    await cubit.sendOtp(
      phone: _phone.text,
      countryIso: _country.isoCode,
      countryCode: _country.dialCode,
    );
    if (!mounted) return;
    if (cubit.state.status == ResetStatus.otpSent) {
      context.push(AppRoutes.otp, extra: cubit);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PasswordResetCubit, PasswordResetState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == ResetStatus.failure && state.error != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      builder: (context, state) {
        final loading = state.status == ResetStatus.loading;
        return AuthScaffold(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                context.gapH(40),
                Center(child: AuthIllustration(child: Assets.images.forgetPasswordImg.image())),
                context.gapH(32),
                AuthHeader(
                  title: context.tr(LocaleKeys.forgetPasswordTitle),
                  subtitle: context.tr(LocaleKeys.forgetPasswordSubtitle),
                ),
                context.gapH(32),
                AppTextField.phone(
                  controller: _phone,
                  hint: context.tr(LocaleKeys.phoneNumber),
                  country: _country,
                  onCountryChanged: (c) => setState(() => _country = c),
                ),
                context.gapH(24),
                AppButton.filled(
                  label: context.tr(LocaleKeys.sendOtp),
                  isLoading: loading,
                  // Dimmed/disabled until a valid phone is entered.
                  onPressed: _canSubmit ? _submit : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
