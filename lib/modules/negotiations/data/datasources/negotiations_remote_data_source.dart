import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_interface.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/negotiation_board.dart';
import '../models/negotiations_dto.dart';

abstract interface class NegotiationsRemoteDataSource {
  Future<ApiResult<NegotiationBoard>> fetchNegotiations();
}

class NegotiationsRemoteDataSourceImpl implements NegotiationsRemoteDataSource {
  NegotiationsRemoteDataSourceImpl(this._api);

  final ApiInterface _api;

  @override
  Future<ApiResult<NegotiationBoard>> fetchNegotiations() => _api.get(
    ApiEndpoints.bids,
    decoder: (data) => NegotiationsDto.fromJson(data as Map<String, dynamic>),
  );
}
