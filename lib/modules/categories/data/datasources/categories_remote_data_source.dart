import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_interface.dart';
import '../../../../core/network/api_result.dart';
import '../../../home/domain/entities/home_product.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/sub_category.dart';
import '../models/category_dto.dart';

/// Talks to the network via [ApiInterface] and decodes straight into domain
/// entities (same style as `HomeRemoteDataSource`). No try/catch here —
/// envelope unwrapping and error mapping live in the API client.
abstract class CategoriesRemoteDataSource {
  Future<ApiResult<List<Category>>> fetchCategories();

  Future<ApiResult<List<SubCategory>>> fetchSubCategories(int categoryId);

  Future<ApiResult<List<HomeProduct>>> fetchCategoryProducts(int categoryId);
}

class CategoriesRemoteDataSourceImpl implements CategoriesRemoteDataSource {
  CategoriesRemoteDataSourceImpl(this._api);

  final ApiInterface _api;

  @override
  Future<ApiResult<List<Category>>> fetchCategories() => _api.get(
        ApiEndpoints.categories,
        decoder: (data) => CategoryDto.listFromJson(data),
      );

  @override
  Future<ApiResult<List<SubCategory>>> fetchSubCategories(int categoryId) =>
      _api.get(
        ApiEndpoints.subCategories,
        query: {'category_id': categoryId},
        decoder: (data) => SubCategoryDto.listFromJson(data, categoryId),
      );

  @override
  Future<ApiResult<List<HomeProduct>>> fetchCategoryProducts(int categoryId) =>
      _api.get(
        ApiEndpoints.categoryProducts,
        query: {'category_id': categoryId},
        decoder: (data) => CategoryProductDto.listFromJson(data),
      );
}
