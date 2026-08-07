import 'package:get_it/get_it.dart';

import '../../../core/cart/presentation/cart_cubit.dart';
import '../../../core/network/api_interface.dart';
import '../data/datasources/checkout_remote_data_source.dart';
import '../data/repositories/checkout_repository_impl.dart';
import '../domain/repositories/checkout_repository.dart';
import '../presentation/cubit/checkout_cubit.dart';

/// Registers the checkout module. Relies on core deps (ApiInterface, the
/// app-wide CartCubit) already being registered on [sl].
void registerCheckoutModule(GetIt sl) {
  sl
    ..registerLazySingleton<CheckoutRemoteDataSource>(
      () => CheckoutRemoteDataSourceImpl(sl<ApiInterface>()),
    )
    ..registerLazySingleton<CheckoutRepository>(
      () => CheckoutRepositoryImpl(sl<CheckoutRemoteDataSource>()),
    )
    // Page-scoped: a fresh cubit per checkout run.
    ..registerFactory(
      () => CheckoutCubit(sl<CheckoutRepository>(), sl<CartCubit>()),
    );
}
