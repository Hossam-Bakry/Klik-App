import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../../../core/constants/countries.dart';
import '../../../../core/constants/validators.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_toast.dart';
import '../cubit/support_cubit.dart';

/// "Contact us" form (`POST /api/support`) — public, reached from the Profile
/// tab's support (headset) button. No subject field in the design; the cubit
/// sends a fixed subject.
class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _message = TextEditingController();
  Country _country = Countries.defaultCountry;

  static const _messageMaxLength = 500;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _message.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<SupportCubit>().submit(
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      message: _message.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SupportCubit, SupportState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == SupportStatus.success) {
          AppToast.success(context, context.tr(LocaleKeys.supportRequestSent));
          context.pop();
        } else if (state.status == SupportStatus.failure &&
            state.errorMessage != null) {
          AppToast.error(context, state.errorMessage!);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          centerTitle: true,
          leading: const BackButton(color: AppColors.textPrimary),
          title: Text(
            context.tr(LocaleKeys.support),
            style: context.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: context.edgeAll(20),
              children: [
                Assets.images.supportImg.image(
                  width: context.r(170),
                  height: context.r(150),
                ),
                context.gapH(12),
                Text(
                  context.tr(LocaleKeys.supportHeading),
                  textAlign: TextAlign.center,
                  style: context.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                context.gapH(8),
                Text(
                  context.tr(LocaleKeys.supportSubtitle),
                  textAlign: TextAlign.center,
                  style: context.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                context.gapH(24),
                AppTextField.name(
                  controller: _name,
                  hint: context.tr(LocaleKeys.fullName),
                  validator: Validators.name(context),
                ),
                context.gapH(14),
                AppTextField.phone(
                  controller: _phone,
                  hint: context.tr(LocaleKeys.phoneNumber),
                  country: _country,
                  onCountryChanged: (c) => setState(() => _country = c),
                ),
                context.gapH(14),
                AppTextField.multiline(
                  controller: _message,
                  hint: context.tr(LocaleKeys.supportMessageHint),
                  maxLength: _messageMaxLength,
                  validator: Validators.required(context),
                ),
                context.gapH(24),
                BlocBuilder<SupportCubit, SupportState>(
                  buildWhen: (p, c) => p.status != c.status,
                  builder: (context, state) => AppButton.filled(
                    label: context.tr(LocaleKeys.sendMessage),
                    leading: const Icon(Icons.send_rounded),
                    isLoading: state.isSubmitting,
                    onPressed: state.isSubmitting ? null : () => _submit(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
