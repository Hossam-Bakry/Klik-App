import '../../../../core/error/failure.dart';
import '../../../../core/network/api_result.dart';
import '../repositories/auth_repository.dart';

/// Sends a password-reset OTP to the given phone (POST /api/send-otp).
class RequestPasswordResetUseCase {
  const RequestPasswordResetUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<Unit>> call({
    required String phone,
    required String countryCode,
    required String countryIso,
  }) {
    if (phone.trim().isEmpty) {
      return Future.value(
        const ApiFailure<Unit>(ValidationFailure('Phone is required.')),
      );
    }
    return _repository.sendOtp(
      phone: phone.trim(),
      countryCode: countryCode,
      countryIso: countryIso,
    );
  }
}
