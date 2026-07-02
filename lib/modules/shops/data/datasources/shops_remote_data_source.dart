import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_interface.dart';
import '../../../../core/network/api_result.dart';
import '../../../home/domain/entities/shop_item.dart';
import '../models/shop_dto.dart';

abstract interface class ShopsRemoteDataSource {
  Future<ApiResult<List<ShopItem>>> fetchShops({double? lat, double? lng});
}

class ShopsRemoteDataSourceImpl implements ShopsRemoteDataSource {
  ShopsRemoteDataSourceImpl(this._api);

  final ApiInterface _api;

  @override
  Future<ApiResult<List<ShopItem>>> fetchShops({double? lat, double? lng}) =>
      _api.get(
        ApiEndpoints.shops,
        query: {
          // Only ask the API to rank by proximity when we actually have a
          // point to rank against (a saved address or the device's current
          // location) — otherwise fetch the plain list.
          if (lat != null && lng != null) ...{
            'near_to_my_location': 1,
            'latitude': lat,
            'longitude': lng,
          },
        },
        decoder: (data) => ShopDto.listFromJson(data),
      );
}
