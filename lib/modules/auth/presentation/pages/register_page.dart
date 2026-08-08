import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/countries.dart';
import '../../../../core/constants/validators.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/constants/app_links.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/services/link_launcher.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_toast.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_scaffold.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  Country _country = Countries.defaultCountry;
  bool _agreed = false;

  @override
  void initState() {
    super.initState();
    // Rebuild as the user types so the Sign Up button enables/disables live.
    for (final c in [_name, _email, _phone, _password]) {
      c.addListener(_onInputChanged);
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _password]) {
      c.removeListener(_onInputChanged);
      c.dispose();
    }
    super.dispose();
  }

  void _onInputChanged() => setState(() {});

  /// The button stays disabled until every field passes its validator and the
  /// terms are accepted. Reuses the same [Validators] the fields enforce.
  bool _canSubmit(BuildContext context) =>
      _agreed &&
      Validators.name(context)(_name.text) == null &&
      Validators.email(context)(_email.text) == null &&
      Validators.phone(context, _country)(_phone.text) == null &&
      Validators.strongPassword(context)(_password.text) == null;

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_agreed) {
      AppToast.warning(context, context.tr(LocaleKeys.mustAgreeTerms));
      return;
    }
    sl<AuthBloc>().add(
      AuthRegisterRequested(
        name: _name.text,
        email: _email.text,
        password: _password.text,
        phone: _phone.text,
        country: _country.nameEn,
        countryIso: _country.isoCode,
        countryCode: _country.dialCode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      bloc: sl<AuthBloc>(),
      // React when a submit settles (isSubmitting falls) or auth changes, so a
      // repeated registration with the SAME number still re-opens verify even
      // though pendingVerification is unchanged.
      listenWhen: (p, c) =>
          p.status != c.status ||
          (p.isSubmitting && !c.isSubmitting) ||
          p.errorMessage != c.errorMessage,
      listener: (context, state) {
        if (state.isSubmitting) return;
        if (state.errorMessage != null) {
          AppToast.error(context, state.errorMessage!);
        } else if (state.isAuthenticated) {
          context.go(AppRoutes.home);
        } else if (state.pendingVerification != null) {
          // Account created — go verify the phone to activate it.
          context.push(AppRoutes.verifyPhone);
        }
      },
      child: AuthScaffold(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              context.gapH(48),
              AuthHeader(
                title: context.tr(LocaleKeys.createAccount),
                subtitle: context.tr(LocaleKeys.registerSubtitle),
              ),
              context.gapH(32),
              AppTextField.name(
                controller: _name,
                hint: context.tr(LocaleKeys.fullName),
                validator: Validators.name(context),
              ),
              context.gapH(16),
              AppTextField.email(
                controller: _email,
                hint: context.tr(LocaleKeys.emailAddress),
                validator: Validators.email(context),
              ),
              context.gapH(16),
              AppTextField.phone(
                controller: _phone,
                hint: context.tr(LocaleKeys.phoneNumber),
                country: _country,
                onCountryChanged: (c) => setState(() => _country = c),
              ),
              context.gapH(16),
              AppTextField.password(
                controller: _password,
                hint: context.tr(LocaleKeys.password),
                validator: Validators.strongPassword(context),
              ),
              context.gapH(12),
              _AgreeTerms(
                value: _agreed,
                onChanged: (v) => setState(() => _agreed = v),
              ),
              context.gapH(16),
              BlocBuilder<AuthBloc, AuthState>(
                bloc: sl<AuthBloc>(),
                buildWhen: (p, c) => p.isSubmitting != c.isSubmitting,
                builder: (context, state) => AppButton.filled(
                  label: context.tr(LocaleKeys.signUp),
                  isLoading: state.isSubmitting,
                  // Disabled (null) until all fields are valid and terms agreed.
                  onPressed: _canSubmit(context) ? _submit : null,
                ),
              ),
              context.gapH(16),
              Row(
                spacing: context.w(8),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(context.tr(LocaleKeys.haveAccount),
                      style: const TextStyle(color: AppColors.textSecondary)),
                  AppButton.text(
                    label: context.tr(LocaleKeys.logIn),
                    foregroundColor: AppColors.primary,
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AgreeTerms extends StatelessWidget {
  const _AgreeTerms({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: context.r(24),
          height: context.r(24),
          child: Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            activeColor: AppColors.primary,
            visualDensity: VisualDensity.compact,
          ),
        ),
        context.gapW(8),
        Expanded(
          child: Padding(
            padding: context.edge(top: 2),
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: context.sp(13),
                ),
                children: [
                  TextSpan(text: '${context.tr(LocaleKeys.agreePrefix)} '),
                  // Two documents, two links — each opens the published page.
                  _legalLink(
                    context,
                    label: context.tr(LocaleKeys.termsConditions),
                    url: AppLinks.termsAndConditions,
                  ),
                  TextSpan(text: ' ${context.tr(LocaleKeys.andConjunction)} '),
                  _legalLink(
                    context,
                    label: context.tr(LocaleKeys.privacyPolicy),
                    url: AppLinks.privacyPolicy,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// A bronze, tappable span for one of the legal documents.
  TextSpan _legalLink(
    BuildContext context, {
    required String label,
    required String url,
  }) {
    return TextSpan(
      text: label,
      style: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () => openLink(context, url),
    );
  }
}
