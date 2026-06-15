import '../../../../core/network/api_result.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_remote_data_source.dart';

/// Maps the data layer's DTO result to a domain-entity result. Failures pass
/// straight through via [ApiResultX.mapData].
class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this._remote);

  final CatalogRemoteDataSource _remote;

  @override
  Future<ApiResult<List<Product>>> getProducts() async {
    final result = await _remote.fetchProducts();
    return result.mapData((dtos) => dtos.map((d) => d.toEntity()).toList());
  }
}
