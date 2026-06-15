import '../../../../core/network/api_result.dart';
import '../entities/auth_session.dart';
import '../entities/social_account.dart';
import '../repositories/auth_repository.dart';

/// Runs the social sign-in flow for [SocialAuthType]. Returns `null` when the
/// user cancels the native dialog (nothing to surface).
class SocialSignInUseCase {
  const SocialSignInUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<AuthSession>?> call(SocialAuthType type) =>
      _repository.socialSignIn(type);
}
