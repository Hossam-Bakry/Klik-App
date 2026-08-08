import '../../../../core/cart/domain/cart_item.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/checkout_summary.dart';
import '../../domain/entities/placed_order.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../datasources/checkout_remote_data_source.dart';

/// Thin pass-through — the payloads are already mapped by `CheckoutDto`.
class CheckoutRepositoryImpl implements CheckoutRepository {
  CheckoutRepositoryImpl(this._remote);

  final CheckoutRemoteDataSource _remote;

  @override
  Future<ApiResult<CheckoutSummary>> fetchSummary() => _remote.fetchSummary();

  @override
  Future<ApiResult<double>> applyCoupon({
    required String code,
    required List<CartItem> lines,
  }) => _remote.applyCoupon(code: code, lines: lines);

  @override
  Future<ApiResult<PlacedOrder>> placeOrder({
    required List<int> shopIds,
    required int addressId,
  }) => _remote.placeOrder(shopIds: shopIds, addressId: addressId);

  @override
  Future<ApiResult<PlacedOrder>> fetchLatestOrder() => _remote.fetchLatestOrder();
}
