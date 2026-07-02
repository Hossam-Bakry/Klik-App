import '../../../../core/network/api_result.dart';
import '../../../home/domain/entities/shop_item.dart';

abstract interface class ShopsRepository {
  /// [lat]/[lng], when both provided, ask the API to rank/filter shops near
  /// that point. Omit both to fetch the plain (unfiltered) list.
  Future<ApiResult<List<ShopItem>>> fetchShops({double? lat, double? lng});
}
