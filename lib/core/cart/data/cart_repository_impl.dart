import '../../network/api_result.dart';
import '../domain/cart_merge_strategy.dart';
import '../domain/cart_repository.dart';
import 'cart_remote_data_source.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this._remote);

  final CartRemoteDataSource _remote;

  @override
  Future<ApiResult<int?>> mergeGuestCart({
    required String guestToken,
    required CartMergeStrategy strategy,
  }) =>
      _remote.mergeGuestCart(guestToken: guestToken, strategy: strategy);

  @override
  Future<ApiResult<int>> fetchCartCount() => _remote.fetchCartCount();
}
