import '../../../../core/error/failure.dart';
import '../../../../core/network/api_result.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

/// Encapsulates the login action. Validates input up front (returning a
/// [ValidationFailure] without a request), then delegates to the repository.
class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<AuthSession>> call({
    required String phone,
    required String password,
    required String countryIso,
    required String countryCode,
  }) {
    if (phone.trim().isEmpty || password.isEmpty) {
      return Future.value(
        const ApiFailure<AuthSession>(
          ValidationFailure('Phone and password are required.'),
        ),
      );
    }
    return _repository.login(
      phone: phone.trim(),
      password: password,
      countryIso: countryIso,
      countryCode: countryCode,
    );
  }
}
