import '../../../../core/network/api_result.dart';
import '../../domain/repositories/support_repository.dart';
import '../datasources/support_remote_data_source.dart';

class SupportRepositoryImpl implements SupportRepository {
  SupportRepositoryImpl(this._remote);

  final SupportRemoteDataSource _remote;

  @override
  Future<ApiResult<Unit>> submit({
    required String name,
    required String phone,
    required String subject,
    required String message,
  }) => _remote.submit(
    name: name,
    phone: phone,
    subject: subject,
    message: message,
  );
}
