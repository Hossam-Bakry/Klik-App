import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_interface.dart';
import '../../../../core/network/api_result.dart';

abstract interface class SecurityRemoteDataSource {
  Future<ApiResult<Unit>> deleteAccount();
}

class SecurityRemoteDataSourceImpl implements SecurityRemoteDataSource {
  SecurityRemoteDataSourceImpl(this._api);

  final ApiInterface _api;

  @override
  Future<ApiResult<Unit>> deleteAccount() => _api.delete(
    ApiEndpoints.deleteAccount,
    decoder: (_) => unit,
  );
}
