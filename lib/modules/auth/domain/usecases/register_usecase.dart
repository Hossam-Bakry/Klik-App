import '../../../../core/error/failure.dart';
import '../../../../core/network/api_result.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<Unit>> call({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String country,
    required String countryIso,
    required String countryCode,
    String? gender,
  }) {
    if (name.trim().isEmpty ||
        email.trim().isEmpty ||
        password.isEmpty ||
        phone.trim().isEmpty) {
      return Future.value(
        const ApiFailure<Unit>(
          ValidationFailure('Name, email, phone and password are required.'),
        ),
      );
    }
    return _repository.register(
      name: name.trim(),
      email: email.trim(),
      password: password,
      phone: phone.trim(),
      country: country,
      countryIso: countryIso,
      countryCode: countryCode,
      gender: gender,
    );
  }
}
