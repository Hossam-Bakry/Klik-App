import '../../../../core/error/failure.dart';
import '../../../../core/network/api_result.dart';
import '../repositories/auth_repository.dart';

/// Verifies the OTP (POST /api/verify-otp) and returns the password-reset
/// token used by [ResetPasswordUseCase].
class VerifyOtpUseCase {
  const VerifyOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<String>> call({
    required String phone,
    required String otp,
    required String countryIso,
    required String countryCode,
  }) {
    if (otp.trim().length < 4) {
      return Future.value(
        const ApiFailure<String>(
          ValidationFailure('Enter the full verification code.'),
        ),
      );
    }
    return _repository.verifyOtp(
      phone: phone.trim(),
      otp: otp.trim(),
      countryIso: countryIso,
      countryCode: countryCode,
    );
  }
}
