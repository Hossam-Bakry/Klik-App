import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/validators.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_toast.dart';
import '../cubit/password_reset_cubit.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_scaffold.dart';

/// Final step of the forgot-password flow. Receives the in-flight
/// [PasswordResetCubit] (carrying the reset token from verify-otp) via `extra`
/// so the new password can be submitted against that token.
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key, required this.cubit});

  final PasswordResetCubit cubit;

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.cubit.resetPassword(password: _password.text, passwordConfirmation: _confirm.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.cubit,
      child: BlocConsumer<PasswordResetCubit, PasswordResetState>(
        listenWhen: (p, c) => p.status != c.status,
        listener: (context, state) {
          if (state.status == ResetStatus.passwordReset) {
            AppToast.success(context, context.tr(LocaleKeys.passwordChanged));
            context.go(AppRoutes.login);
          } else if (state.status == ResetStatus.failure && state.error != null) {
            AppToast.error(context, state.error!);
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
                  const Center(child: _LockBadge()),
                  context.gapH(32),
                  AuthHeader(
                    title: context.tr(LocaleKeys.changePasswordTitle),
                    subtitle: context.tr(LocaleKeys.changePasswordSubtitle),
                  ),
                  context.gapH(32),
                  AppTextField.password(
                    controller: _password,
                    hint: context.tr(LocaleKeys.newPassword),
                    validator: Validators.strongPassword(context),
                  ),
                  context.gapH(16),
                  AppTextField.password(
                    controller: _confirm,
                    hint: context.tr(LocaleKeys.confirmPassword),
                    validator: Validators.confirmPassword(context, _password),
                  ),
                  context.gapH(24),
                  AppButton.filled(
                    label: context.tr(LocaleKeys.changePassword),
                    isLoading: loading,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Centered bronze-tinted disc with a lock icon — the screen's hero.
class _LockBadge extends StatelessWidget {
  const _LockBadge();

  @override
  Widget build(BuildContext context) {
    final size = context.r(120);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: Icon(Icons.lock_reset_rounded, size: context.r(60), color: AppColors.primary),
    );
  }
}
