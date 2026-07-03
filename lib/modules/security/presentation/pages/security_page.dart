import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../cubit/security_cubit.dart';
import '../widgets/delete_account_dialog.dart';

/// Security settings — currently just account deletion. Reached from the
/// Profile tab's Security row (auth-required).
///
/// On success, dispatches `AuthLogoutRequested` to clear the local session;
/// the router's redirect guard then bounces off this (auth-required) route
/// automatically once `AuthBloc` flips to unauthenticated.
class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key});

  Future<void> _confirmAndDelete(BuildContext context) async {
    final confirmed = await showDeleteAccountDialog(context);
    if (!confirmed) return;
    if (context.mounted) context.read<SecurityCubit>().deleteAccount();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SecurityCubit, SecurityState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == SecurityStatus.deleted) {
          AppToast.success(
            context,
            context.tr(LocaleKeys.accountDeletedSuccessfully),
          );
          sl<AuthBloc>().add(const AuthLogoutRequested());
        } else if (state.status == SecurityStatus.failure &&
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
            context.tr(LocaleKeys.security),
            style: context.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: context.edgeAll(20),
            children: [
              Text(
                context.tr(LocaleKeys.deleteAccountTitle),
                textAlign: TextAlign.center,
                style: context.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              context.gapH(8),
              Text(
                context.tr(LocaleKeys.deleteAccountSubtitle),
                textAlign: TextAlign.center,
                style: context.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              context.gapH(20),
              _NoteCard(
                children: [
                  _NoteRow(
                    icon: Icons.description_outlined,
                    text: context.tr(LocaleKeys.deleteAccountNoteData),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _NoteRow(
                    icon: Icons.person_outline_rounded,
                    text: context.tr(LocaleKeys.deleteAccountNoteAccess),
                  ),
                ],
              ),
              context.gapH(20),
              BlocBuilder<SecurityCubit, SecurityState>(
                buildWhen: (p, c) => p.status != c.status,
                builder: (context, state) => AppButton.filled(
                  label: context.tr(LocaleKeys.deleteAccount),
                  isLoading: state.isDeleting,
                  onPressed: state.isDeleting
                      ? null
                      : () => _confirmAndDelete(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: context.edgeSymmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.r(14)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: context.edgeSymmetric(vertical: 10),
            child: Text(
              context.tr(LocaleKeys.pleaseNote),
              style: context.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _NoteRow extends StatelessWidget {
  const _NoteRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.edgeSymmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: context.r(20), color: AppColors.primary),
          context.gapW(12),
          Expanded(
            child: Text(
              text,
              style: context.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
