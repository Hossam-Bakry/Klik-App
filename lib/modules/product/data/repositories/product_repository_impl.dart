import '../../../../core/network/api_result.dart';
import '../../domain/entities/product_details.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

/// The detail payload is already mapped to a domain entity by
/// [ProductDetailsDto], so this is a thin pass-through. Kept as a seam for
/// caching / merging later.
class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._remote);

  final ProductRemoteDataSource _remote;

  @override
  Future<ApiResult<ProductDetails>> getProductDetails(int productId) =>
      _remote.fetchProductDetails(productId);

  @override
  Future<ApiResult<Unit>> placeBid({
    required int productId,
    required double price,
    int? sizeId,
    int? colorId,
  }) => _remote.createBid(
    productId: productId,
    price: price,
    sizeId: sizeId,
    colorId: colorId,
  );
}
