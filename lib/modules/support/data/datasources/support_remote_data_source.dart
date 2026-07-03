import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_interface.dart';
import '../../../../core/network/api_result.dart';

abstract interface class SupportRemoteDataSource {
  Future<ApiResult<Unit>> submit({
    required String name,
    required String phone,
    required String subject,
    required String message,
  });
}

class SupportRemoteDataSourceImpl implements SupportRemoteDataSource {
  SupportRemoteDataSourceImpl(this._api);

  final ApiInterface _api;

  @override
  Future<ApiResult<Unit>> submit({
    required String name,
    required String phone,
    required String subject,
    required String message,
  }) => _api.post(
    ApiEndpoints.support,
    body: {
      'name': name,
      'phone': phone,
      'subject': subject,
      'message': message,
    },
    decoder: (_) => unit,
  );
}
