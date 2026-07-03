import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_result.dart';
import '../../../auth/domain/usecases/change_password_usecase.dart';

part 'update_password_state.dart';

/// Page-scoped Cubit for the account-settings "Change Password" screen — a
/// single "submit" action. Distinct from the auth module's forgot-password
/// flow (`ChangePasswordPage`/`PasswordResetCubit`), which resets a password
/// via an OTP-issued token rather than the current password.
class UpdatePasswordCubit extends Cubit<UpdatePasswordState> {
  UpdatePasswordCubit(this._changePassword) : super(const UpdatePasswordState());

  final ChangePasswordUseCase _changePassword;

  Future<void> submit({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    emit(state.copyWith(
      status: UpdatePasswordStatus.submitting,
      clearError: true,
    ));
    final result = await _changePassword(
      currentPassword: currentPassword,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    switch (result) {
      case ApiSuccess():
        emit(state.copyWith(status: UpdatePasswordStatus.success));
      case ApiFailure(:final failure):
        emit(state.copyWith(
          status: UpdatePasswordStatus.failure,
          errorMessage: failure.message,
        ));
    }
  }
}
