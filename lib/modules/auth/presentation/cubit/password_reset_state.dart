part of 'password_reset_cubit.dart';

enum ResetStatus { initial, loading, otpSent, verified, passwordReset, failure }

class PasswordResetState extends Equatable {
  const PasswordResetState({
    this.status = ResetStatus.initial,
    this.phone = '',
    this.countryIso = '',
    this.countryCode = '',
    this.resetToken = '',
    this.error,
  });

  final ResetStatus status;
  final String phone;
  final String countryIso;
  final String countryCode;

  /// Reset token returned by verify-otp, consumed by reset-password.
  final String resetToken;
  final String? error;

  PasswordResetState copyWith({
    ResetStatus? status,
    String? phone,
    String? countryIso,
    String? countryCode,
    String? resetToken,
    String? error,
    bool clearError = false,
  }) {
    return PasswordResetState(
      status: status ?? this.status,
      phone: phone ?? this.phone,
      countryIso: countryIso ?? this.countryIso,
      countryCode: countryCode ?? this.countryCode,
      resetToken: resetToken ?? this.resetToken,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props =>
      [status, phone, countryIso, countryCode, resetToken, error];
}
