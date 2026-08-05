import '../../../../core/network/api_result.dart';
import '../entities/negotiation_board.dart';

abstract interface class NegotiationsRepository {
  /// The signed-in customer's offers, bucketed by status
  /// (`GET /api/bids`).
  Future<ApiResult<NegotiationBoard>> fetchNegotiations();
}
