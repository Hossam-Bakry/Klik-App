import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../../core/network/api_interface.dart';
import '../../../core/network/token_provider.dart';
import '../../../core/services/otp_cooldown_store.dart';
import '../data/datasources/auth_local_data_source.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/services/social_auth_service_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/services/social_auth_service.dart';
import '../domain/usecases/change_password_usecase.dart';
import '../domain/usecases/get_current_session_usecase.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/logout_usecase.dart';
import '../domain/usecases/register_usecase.dart';
import '../domain/usecases/request_password_reset_usecase.dart';
import '../domain/usecases/reset_password_usecase.dart';
import '../domain/usecases/send_phone_otp_usecase.dart';
import '../domain/usecases/social_sign_in_usecase.dart';
import '../domain/usecases/verify_otp_usecase.dart';
import '../domain/usecases/verify_phone_otp_usecase.dart';
import '../presentation/bloc/auth_bloc.dart';
import '../presentation/cubit/password_reset_cubit.dart';

/// Registers the auth module's dependencies. Relies on core deps (DioClient,
/// FlutterSecureStorage) already being registered on [sl].
void registerAuthModule(GetIt sl) {
  sl
    // Data sources
    ..registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl<ApiInterface>()))
    ..registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(sl<FlutterSecureStorage>()))
    // Native Google/Apple sign-in.
    ..registerLazySingleton<SocialAuthService>(() => SocialAuthServiceImpl())
    // Supplies the bearer token to the network layer (AuthInterceptor).
    ..registerLazySingleton<TokenProvider>(
      () =>
          () => sl<AuthLocalDataSource>().readToken(),
    )
    // Repository
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remote: sl<AuthRemoteDataSource>(),
        local: sl<AuthLocalDataSource>(),
        social: sl<SocialAuthService>(),
      ),
    )
    // Use cases (auth is logic-heavy, so it keeps a use-case layer)
    ..registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => GetCurrentSessionUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => RequestPasswordResetUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => VerifyOtpUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => ResetPasswordUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => ChangePasswordUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => SocialSignInUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => VerifyPhoneOtpUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => SendPhoneOtpUseCase(sl<AuthRepository>()))
    // AuthBloc is app-scoped (the router guard depends on it), so unlike
    // page-scoped BLoCs it lives in the locator as a singleton.
    ..registerLazySingleton(
      () => AuthBloc(
        login: sl<LoginUseCase>(),
        register: sl<RegisterUseCase>(),
        logout: sl<LogoutUseCase>(),
        getCurrentSession: sl<GetCurrentSessionUseCase>(),
        socialSignIn: sl<SocialSignInUseCase>(),
        verifyPhoneOtp: sl<VerifyPhoneOtpUseCase>(),
        sendPhoneOtp: sl<SendPhoneOtpUseCase>(),
        otpCooldown: sl<OtpCooldownStore>(),
      ),
    )
    // Page-scoped: a fresh PasswordResetCubit per forgot-password flow
    // (factory). Provided at the forgot-password route and handed to the OTP
    // route via `extra` so the same instance carries the flow's state.
    ..registerFactory(
      () => PasswordResetCubit(
        requestReset: sl<RequestPasswordResetUseCase>(),
        verifyOtp: sl<VerifyOtpUseCase>(),
        resetPassword: sl<ResetPasswordUseCase>(),
        otpCooldown: sl<OtpCooldownStore>(),
      ),
    );
}
