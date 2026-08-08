import 'package:get_it/get_it.dart';

import '../../../core/network/api_interface.dart';
import '../data/datasources/notifications_remote_data_source.dart';
import '../data/repositories/notifications_repository_impl.dart';
import '../domain/repositories/notifications_repository.dart';
import '../presentation/cubit/notifications_cubit.dart';

/// Registers the notifications module. Relies on core deps (ApiInterface)
/// already being registered on [sl].
void registerNotificationsModule(GetIt sl) {
  sl
    ..registerLazySingleton<NotificationsRemoteDataSource>(
      () => NotificationsRemoteDataSourceImpl(sl<ApiInterface>()),
    )
    ..registerLazySingleton<NotificationsRepository>(
      () => NotificationsRepositoryImpl(sl<NotificationsRemoteDataSource>()),
    )
    // App-wide: the bell's dot and the list read the same instance, and the
    // session listener in main.dart loads/clears it.
    ..registerLazySingleton<NotificationsCubit>(
      () => NotificationsCubit(sl<NotificationsRepository>()),
    );
}
