import '../../../../core/network/api_result.dart';
import '../../domain/repositories/security_repository.dart';
import '../datasources/security_remote_data_source.dart';

class SecurityRepositoryImpl implements SecurityRepository {
  SecurityRepositoryImpl(this._remote);

  final SecurityRemoteDataSource _remote;

  @override
  Future<ApiResult<Unit>> deleteAccount() => _remote.deleteAccount();
}
