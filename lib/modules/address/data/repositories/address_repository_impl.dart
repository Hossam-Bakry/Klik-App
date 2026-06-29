import '../../../../core/network/api_result.dart';
import '../../domain/entities/address.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasources/address_remote_data_source.dart';

/// Thin pass-through to the remote source — DTOs already map to domain
/// entities. Kept as a seam for caching/merging later.
class AddressRepositoryImpl implements AddressRepository {
  AddressRepositoryImpl(this._remote);

  final AddressRemoteDataSource _remote;

  @override
  Future<ApiResult<List<Address>>> getAddresses() => _remote.fetchAddresses();

  @override
  Future<ApiResult<Address>> createAddress(Address address) =>
      _remote.storeAddress(address);

  @override
  Future<ApiResult<Address>> updateAddress(Address address) =>
      _remote.updateAddress(address);

  @override
  Future<ApiResult<Unit>> deleteAddress(int id) => _remote.deleteAddress(id);
}
