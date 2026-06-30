import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/services/otp_cooldown_store.dart';
import '../../domain/usecases/request_password_reset_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';

part 'password_reset_state.dart';

/// Page-scoped Cubit for the forgot-password flow:
/// send OTP → verify OTP (gets a reset token) → reset password.
/// It does NOT touch [AuthBloc]/the session. Create it via BlocProvider on the
/// forgot-password screen and hand it forward to the OTP screen.
class PasswordResetCubit extends Cubit<PasswordResetState> {
  PasswordResetCubit({
    required RequestPasswordResetUseCase requestReset,
    required VerifyOtpUseCase verifyOtp,
    required ResetPasswordUseCase resetPassword,
    required OtpCooldownStore otpCooldown,
  })  : _requestReset = requestReset,
        _verifyOtp = verifyOtp,
        _resetPassword = resetPassword,
        _otpCooldown = otpCooldown,
        super(const PasswordResetState());

  final RequestPasswordResetUseCase _requestReset;
  final VerifyOtpUseCase _verifyOtp;
  final ResetPasswordUseCase _resetPassword;
  final OtpCooldownStore _otpCooldown;

  /// Step 1 — send the OTP to [phone].
  Future<void> sendOtp({
    required String phone,
    required String countryIso,
    required String countryCode,
  }) async {
    // Same number still within its cooldown → reuse the live OTP: skip the
    // request and just advance to the OTP screen (which shows the remaining
    // time). A changed number has no active window, so it sends below.
    if (!_otpCooldown.canRequest(phone)) {
      emit(state.copyWith(
        status: ResetStatus.otpSent,
        phone: phone,
        countryIso: countryIso,
        countryCode: countryCode,
        clearError: true,
      ));
      return;
    }
    emit(state.copyWith(status: ResetStatus.loading, clearError: true));
    final result = await _requestReset(
      phone: phone,
      countryCode: countryCode,
      countryIso: countryIso,
    );
    switch (result) {
      case ApiSuccess():
        await _otpCooldown.markSent(phone);
        emit(state.copyWith(
          status: ResetStatus.otpSent,
          phone: phone,
          countryIso: countryIso,
          countryCode: countryCode,
        ));
      case ApiFailure(:final failure):
        _emitFailure(failure);
    }
  }

  /// Step 2 — verify [otp] for the phone captured in step 1, storing the token.
  Future<void> verify(String otp) async {
    emit(state.copyWith(status: ResetStatus.loading, clearError: true));
    final result = await _verifyOtp(
      phone: state.phone,
      otp: otp,
      countryIso: state.countryIso,
      countryCode: state.countryCode,
    );
    switch (result) {
      case ApiSuccess(:final data):
        emit(state.copyWith(status: ResetStatus.verified, resetToken: data));
      case ApiFailure(:final failure):
        _emitFailure(failure);
    }
  }

  /// Step 3 — set the new password using the stored reset token.
  Future<void> resetPassword({
    required String password,
    required String passwordConfirmation,
  }) async {
    emit(state.copyWith(status: ResetStatus.loading, clearError: true));
    final result = await _resetPassword(
      token: state.resetToken,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    switch (result) {
      case ApiSuccess():
        emit(state.copyWith(status: ResetStatus.passwordReset));
      case ApiFailure(:final failure):
        _emitFailure(failure);
    }
  }

  void _emitFailure(Failure failure) =>
      emit(state.copyWith(status: ResetStatus.failure, error: failure.message));
}
