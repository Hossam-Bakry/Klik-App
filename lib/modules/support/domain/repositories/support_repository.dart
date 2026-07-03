import '../../../../core/network/api_result.dart';

abstract interface class SupportRepository {
  /// Submits a support request (`POST /api/support`). Public — no session
  /// required.
  Future<ApiResult<Unit>> submit({
    required String name,
    required String phone,
    required String subject,
    required String message,
  });
}
