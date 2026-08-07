import 'package:get_it/get_it.dart';

import '../../../core/network/api_interface.dart';
import '../data/datasources/orders_remote_data_source.dart';
import '../data/repositories/orders_repository_impl.dart';
import '../domain/repositories/orders_repository.dart';
import '../presentation/bloc/orders_bloc.dart';
import '../presentation/cubit/order_details_cubit.dart';
import '../presentation/cubit/write_review_cubit.dart';

/// Registers the orders module's dependencies. Relies on core deps
/// (ApiInterface) already being registered on [sl].
void registerOrdersModule(GetIt sl) {
  sl
    ..registerLazySingleton<OrdersRemoteDataSource>(
      () => OrdersRemoteDataSourceImpl(sl<ApiInterface>()),
    )
    ..registerLazySingleton<OrdersRepository>(
      () => OrdersRepositoryImpl(sl<OrdersRemoteDataSource>()),
    )
    // Page-scoped: a fresh bloc per navigation, owned by the route's
    // BlocProvider.
    ..registerFactory(() => OrdersBloc(sl<OrdersRepository>()))
    // Takes the order id the details route was opened with.
    ..registerFactoryParam<OrderDetailsCubit, int, void>(
      (orderId, _) => OrderDetailsCubit(sl<OrdersRepository>(), orderId),
    )
    ..registerFactory(() => WriteReviewCubit(sl<OrdersRepository>()));
}
