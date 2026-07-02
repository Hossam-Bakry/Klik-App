import '../../../../core/network/api_result.dart';
import '../../domain/entities/brand.dart';
import '../../domain/entities/products_filter.dart';
import '../../domain/entities/products_page.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_remote_data_source.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  ProductsRepositoryImpl(this._remote);

  final ProductsRemoteDataSource _remote;

  @override
  Future<ApiResult<ProductsPage>> fetchProducts(
    ProductsFilter filter, {
    required int page,
    required int perPage,
  }) => _remote.fetchProducts(filter, page: page, perPage: perPage);

  @override
  Future<ApiResult<List<Brand>>> fetchBrands() => _remote.fetchBrands();
}
