import '../../../../core/network/api_result.dart';
import '../entities/address.dart';

/// Customer address CRUD, backed by the `/api/address*` endpoints. Every call
/// returns an [ApiResult] — failures are surfaced, never thrown.
abstract interface class AddressRepository {
  Future<ApiResult<List<Address>>> getAddresses();

  /// Returns the saved address (with its server-assigned id).
  Future<ApiResult<Address>> createAddress(Address address);

  Future<ApiResult<Address>> updateAddress(Address address);

  Future<ApiResult<Unit>> deleteAddress(int id);
}
