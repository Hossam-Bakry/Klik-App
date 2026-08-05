import '../../../../core/network/api_result.dart';
import '../../domain/entities/negotiation_board.dart';
import '../../domain/repositories/negotiations_repository.dart';
import '../datasources/negotiations_remote_data_source.dart';

/// The payload is already mapped to a domain entity by [NegotiationsDto], so
/// this is a thin pass-through — kept as a seam for caching later.
class NegotiationsRepositoryImpl implements NegotiationsRepository {
  NegotiationsRepositoryImpl(this._remote);

  final NegotiationsRemoteDataSource _remote;

  @override
  Future<ApiResult<NegotiationBoard>> fetchNegotiations() =>
      _remote.fetchNegotiations();
}
