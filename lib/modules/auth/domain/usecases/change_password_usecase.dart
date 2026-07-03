import '../../../../core/error/failure.dart';
import '../../../../core/network/api_result.dart';
import '../repositories/auth_repository.dart';

/// Changes the signed-in user's password (POST /api/change-password) —
/// requires the current password, unlike [ResetPasswordUseCase]'s
/// forgot-password (token-based) flow.
class ChangePasswordUseCase {
  const ChangePasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<Unit>> call({
    required String currentPassword,
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
    return _repository.changePassword(
      currentPassword: currentPassword,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
}
