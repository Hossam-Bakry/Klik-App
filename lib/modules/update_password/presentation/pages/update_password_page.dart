import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../../../core/constants/validators.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_toast.dart';
import '../cubit/update_password_cubit.dart';

/// Account-settings "Change Password" screen (`POST /api/change-password`),
/// reached from Profile → Change Password. Distinct from the auth module's
/// forgot-password flow, which resets a password via an OTP token instead of
/// the current one.
class UpdatePasswordPage extends StatefulWidget {
  const UpdatePasswordPage({super.key});

  @override
  State<UpdatePasswordPage> createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends State<UpdatePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _newPassword.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<UpdatePasswordCubit>().submit(
      currentPassword: _current.text,
      password: _newPassword.text,
      passwordConfirmation: _confirm.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdatePasswordCubit, UpdatePasswordState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == UpdatePasswordStatus.success) {
          AppToast.success(context, context.tr(LocaleKeys.passwordChanged));
          context.pop();
        } else if (state.status == UpdatePasswordStatus.failure &&
            state.errorMessage != null) {
          AppToast.error(context, state.errorMessage!);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: Assets.images.authBackgroundImag.provider(), fit: BoxFit.cover),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const BackButton(color: AppColors.textPrimary),
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: context.edgeAll(20),
                children: [
                  context.gapH(20),
                  Text(
                    context.tr(LocaleKeys.changePassword),
                    textAlign: TextAlign.center,
                    style: context.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  context.gapH(8),
                  Text(
                    context.tr(LocaleKeys.changePasswordSubtitle),
                    textAlign: TextAlign.center,
                    style: context.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  context.gapH(28),
                  AppTextField.password(
                    controller: _current,
                    hint: context.tr(LocaleKeys.currentPassword),
                    validator: Validators.required(context),
                  ),
                  context.gapH(14),
                  AppTextField.password(
                    controller: _newPassword,
                    hint: context.tr(LocaleKeys.newPassword),
                    validator: Validators.strongPassword(context),
                  ),
                  context.gapH(14),
                  AppTextField.password(
                    controller: _confirm,
                    hint: context.tr(LocaleKeys.confirmNewPassword),
                    validator: Validators.confirmPassword(
                      context,
                      _newPassword,
                    ),
                  ),
                  context.gapH(24),
                  BlocBuilder<UpdatePasswordCubit, UpdatePasswordState>(
                    buildWhen: (p, c) => p.status != c.status,
                    builder: (context, state) => AppButton.filled(
                      label: context.tr(LocaleKeys.changePassword),
                      isLoading: state.isSubmitting,
                      onPressed: state.isSubmitting
                          ? null
                          : () => _submit(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Faint bronze dots scattered near [corner], fading with distance — a
/// decorative flourish built with a painter rather than a new image asset.
class _DotScatterBackground extends StatelessWidget {
  const _DotScatterBackground({required this.corner});

  final Alignment corner;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _DotScatterPainter(corner: corner),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _DotScatterPainter extends CustomPainter {
  const _DotScatterPainter({required this.corner});

  final Alignment corner;

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(corner == Alignment.topRight ? 7 : 13);
    final origin = corner.alongSize(size);
    final spread = size.shortestSide * 0.55;
    final paint = Paint();

    for (var i = 0; i < 110; i++) {
      final dx = (random.nextDouble() - 0.5) * 2 * spread;
      final dy = (random.nextDouble() - 0.5) * 2 * spread;
      final point = origin.translate(dx, dy);
      if (point.dx < 0 ||
          point.dy < 0 ||
          point.dx > size.width ||
          point.dy > size.height) {
        continue;
      }
      final distance = (point - origin).distance / spread;
      final opacity = (1 - distance).clamp(0.0, 1.0) * 0.45;
      if (opacity < 0.03) continue;
      paint.color = AppColors.primaryBronze.withValues(alpha: opacity);
      canvas.drawCircle(point, 1.2 + random.nextDouble() * 2.2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DotScatterPainter oldDelegate) =>
      oldDelegate.corner != corner;
}
