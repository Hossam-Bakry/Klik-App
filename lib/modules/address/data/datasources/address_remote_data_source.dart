import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_interface.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/address.dart';
import '../models/address_dto.dart';

/// Talks to the `/api/address*` endpoints via [ApiInterface]. Envelope
/// unwrapping and error mapping live in the API client — no try/catch here.
abstract interface class AddressRemoteDataSource {
  Future<ApiResult<List<Address>>> fetchAddresses();
  Future<ApiResult<Address>> storeAddress(Address address);
  Future<ApiResult<Address>> updateAddress(Address address);
  Future<ApiResult<Unit>> deleteAddress(int id);
}

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  AddressRemoteDataSourceImpl(this._api);

  final ApiInterface _api;

  @override
  Future<ApiResult<List<Address>>> fetchAddresses() => _api.get(
        ApiEndpoints.addresses,
        decoder: AddressDto.listFromJson,
      );

  @override
  Future<ApiResult<Address>> storeAddress(Address address) => _api.post(
        ApiEndpoints.addressStore,
        body: AddressDto.toJson(address),
        // Some backends echo the saved address, others return only a message;
        // fall back to the submitted address so the call never fails on shape.
        decoder: (data) => data is Map<String, dynamic>
            ? AddressDto.fromJson(data)
            : address,
      );

  @override
  Future<ApiResult<Address>> updateAddress(Address address) => _api.post(
        ApiEndpoints.addressUpdate(address.id!),
        body: AddressDto.toJson(address),
        decoder: (data) => data is Map<String, dynamic>
            ? AddressDto.fromJson(data)
            : address,
      );

  @override
  Future<ApiResult<Unit>> deleteAddress(int id) => _api.delete(
        ApiEndpoints.addressDelete(id),
        decoder: (_) => unit,
      );
}
