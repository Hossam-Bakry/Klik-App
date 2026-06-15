import '../../../../core/error/failure.dart';
import '../../../../core/network/api_result.dart';
import '../repositories/auth_repository.dart';

/// Sets a new password using the reset token from [VerifyOtpUseCase]
/// (POST /api/reset-password).
class ResetPasswordUseCase {
  const ResetPasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<Unit>> call({
    required String token,
    required String password,
    required String passwordConfirmation,
  }) {
    if (password.length < 6) {
      return Future.value(
        const ApiFailure<Unit>(
          ValidationFailure('Password must be at least 6 characters.'),
        ),
      );
    }
    if (password != passwordConfirmation) {
      return Future.value(
        const ApiFailure<Unit>(ValidationFailure('Passwords do not match.')),
      );
    }
    return _repository.resetPassword(
      token: token,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
}
