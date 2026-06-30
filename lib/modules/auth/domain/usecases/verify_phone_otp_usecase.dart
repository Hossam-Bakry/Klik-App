import '../../../../core/error/failure.dart';
import '../../../../core/network/api_result.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

/// Verifies the registration OTP (POST /api/verify-phone-otp), activating the
/// account and returning the authenticated session.
class VerifyPhoneOtpUseCase {
  const VerifyPhoneOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<AuthSession>> call({
    required String phone,
    required String otp,
    required String countryIso,
    required String countryCode,
  }) {
    if (otp.trim().isEmpty) {
      return Future.value(
        const ApiFailure<AuthSession>(
          ValidationFailure('Enter the verification code.'),
        ),
      );
    }
    return _repository.verifyPhoneOtp(
      phone: phone.trim(),
      otp: otp.trim(),
      countryIso: countryIso,
      countryCode: countryCode,
    );
  }
}
