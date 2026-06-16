import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/countries.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/social_account.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/social_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  // Saudi Arabia matches the pre-filled Postman sample account (9-digit number).
  Country _country = Countries.kuwait;

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      sl<AuthBloc>().add(
        AuthLoginRequested(
          phone: _phone.text,
          password: _password.text,
          countryIso: _country.isoCode,
          countryCode: _country.dialCode,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      bloc: sl<AuthBloc>(),
      listenWhen: (p, c) => p.errorMessage != c.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      child: AuthScaffold(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              context.gapH(56),
              AuthHeader(title: context.tr(LocaleKeys.welcomeBack), subtitle: context.tr(LocaleKeys.loginSubtitle)),
              context.gapH(40),
              AppTextField.phone(
                controller: _phone,
                hint: context.tr(LocaleKeys.phoneNumber),
                country: _country,
                onCountryChanged: (c) => setState(() => _country = c),
                validator: (v) => (v == null || v.trim().isEmpty) ? context.tr(LocaleKeys.fieldRequired) : null,
              ),
              context.gapH(16),
              AppTextField.password(
                controller: _password,
                hint: context.tr(LocaleKeys.password),
                validator: (v) => (v == null || v.isEmpty) ? context.tr(LocaleKeys.fieldRequired) : null,
              ),
              context.gapH(8),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: AppButton.text(
                  label: context.tr(LocaleKeys.forgetPasswordQ),
                  foregroundColor: AppColors.primary,
                  onPressed: () => context.push(AppRoutes.forgotPassword),
                ),
              ),
              context.gapH(16),
              BlocBuilder<AuthBloc, AuthState>(
                bloc: sl<AuthBloc>(),
                buildWhen: (p, c) => p.isSubmitting != c.isSubmitting,
                builder: (context, state) => AppButton.filled(
                  label: context.tr(LocaleKeys.logIn),
                  isLoading: state.isSubmitting,
                  onPressed: _submit,
                ),
              ),
              context.gapH(20),
              _AccountSwitch(
                question: context.tr(LocaleKeys.noAccount),
                action: context.tr(LocaleKeys.signUp),
                onTap: () => context.push(AppRoutes.register),
              ),
              context.gapH(16),
              _OrDivider(label: context.tr(LocaleKeys.or)),
              context.gapH(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SocialButton.google(
                    onPressed: () => sl<AuthBloc>().add(
                      const AuthSocialSignInRequested(SocialAuthType.google),
                    ),
                  ),
                  context.gapW(24),
                  SocialButton.apple(
                    onPressed: () => sl<AuthBloc>().add(
                      const AuthSocialSignInRequested(SocialAuthType.apple),
                    ),
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

class _AccountSwitch extends StatelessWidget {
  const _AccountSwitch({required this.question, required this.action, required this.onTap});

  final String question;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: context.w(8),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(question, style: const TextStyle(color: AppColors.textSecondary)),
        AppButton.text(label: action, foregroundColor: AppColors.primary, onPressed: onTap),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final line = Expanded(child: Divider(color: AppColors.textSecondary.withValues(alpha: 0.3)));
    return Row(
      children: [
        line,
        Padding(
          padding: context.edgeHorizontal(12),
          child: Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        ),
        line,
      ],
    );
  }
}
