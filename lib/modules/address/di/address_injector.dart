import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_interface.dart';
import '../../../core/services/location_service.dart';
import '../data/datasources/address_remote_data_source.dart';
import '../data/repositories/address_repository_impl.dart';
import '../domain/repositories/address_repository.dart';
import '../presentation/bloc/address_bloc.dart';

/// Registers the address module. Relies on core deps (ApiInterface,
/// SharedPreferences) already being registered on [sl].
void registerAddressModule(GetIt sl) {
  sl
    ..registerLazySingleton<AddressRemoteDataSource>(
      () => AddressRemoteDataSourceImpl(sl<ApiInterface>()),
    )
    ..registerLazySingleton<AddressRepository>(
      () => AddressRepositoryImpl(sl<AddressRemoteDataSource>()),
    )
    // Singleton: the selected delivery address must persist across tabs and the
    // add/edit routes, which all share this one instance.
    ..registerLazySingleton(
      () => AddressBloc(
        sl<AddressRepository>(),
        sl<LocationService>(),
        sl<SharedPreferences>(),
      ),
    );
}
