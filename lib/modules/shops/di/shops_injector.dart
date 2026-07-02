import 'package:get_it/get_it.dart';

import '../../../core/network/api_interface.dart';
import '../../../core/services/location_service.dart';
import '../../address/presentation/bloc/address_bloc.dart';
import '../data/datasources/shops_remote_data_source.dart';
import '../data/repositories/shops_repository_impl.dart';
import '../domain/repositories/shops_repository.dart';
import '../presentation/bloc/shops_bloc.dart';

/// Registers the shops module's dependencies. Relies on core deps
/// (ApiInterface, LocationService) and the address module (AddressBloc)
/// already being registered on [sl].
void registerShopsModule(GetIt sl) {
  sl
    ..registerLazySingleton<ShopsRemoteDataSource>(
      () => ShopsRemoteDataSourceImpl(sl<ApiInterface>()),
    )
    ..registerLazySingleton<ShopsRepository>(
      () => ShopsRepositoryImpl(sl<ShopsRemoteDataSource>()),
    )
    // Page-scoped: a fresh ShopsBloc per navigation (factory). The route's
    // BlocProvider owns its lifecycle and closes it when the page is popped.
    ..registerFactory(
      () => ShopsBloc(sl<ShopsRepository>(), sl<AddressBloc>(), sl<LocationService>()),
    );
}
