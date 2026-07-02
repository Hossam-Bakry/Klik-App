import '../../../../core/network/api_result.dart';
import '../../../home/domain/entities/shop_item.dart';
import '../../domain/repositories/shops_repository.dart';
import '../datasources/shops_remote_data_source.dart';

class ShopsRepositoryImpl implements ShopsRepository {
  ShopsRepositoryImpl(this._remote);

  final ShopsRemoteDataSource _remote;

  @override
  Future<ApiResult<List<ShopItem>>> fetchShops({double? lat, double? lng}) =>
      _remote.fetchShops(lat: lat, lng: lng);
}
