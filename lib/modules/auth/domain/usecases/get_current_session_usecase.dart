import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

/// Reads the persisted session on app start to decide the initial route.
class GetCurrentSessionUseCase {
  const GetCurrentSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthSession?> call() => _repository.currentSession();
}
