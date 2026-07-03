import '../../../../core/network/api_result.dart';

abstract interface class SecurityRepository {
  /// Permanently deletes the signed-in user's account (`POST
  /// /api/delete-account`). The caller is responsible for clearing the local
  /// session afterwards (see `AuthBloc`'s `AuthLogoutRequested`).
  Future<ApiResult<Unit>> deleteAccount();
}
