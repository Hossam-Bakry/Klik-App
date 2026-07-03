import 'package:get_it/get_it.dart';

import '../../auth/domain/usecases/change_password_usecase.dart';
import '../presentation/cubit/update_password_cubit.dart';

/// Registers the update-password module's dependencies. Relies on the auth
/// module's [ChangePasswordUseCase] already being registered on [sl].
void registerUpdatePasswordModule(GetIt sl) {
  // Page-scoped: a fresh UpdatePasswordCubit per navigation (factory). The
  // route's BlocProvider owns its lifecycle and closes it when popped.
  sl.registerFactory(
    () => UpdatePasswordCubit(sl<ChangePasswordUseCase>()),
  );
}
