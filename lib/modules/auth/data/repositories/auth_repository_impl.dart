import '../../../../core/error/failure.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/social_account.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/services/social_auth_service.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
    required SocialAuthService social,
  })  : _remote = remote,
        _local = local,
        _social = social;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final SocialAuthService _social;

  @override
  Future<ApiResult<AuthSession>> login({
    required String phone,
    required String password,
    required String countryIso,
    required String countryCode,
  }) =>
      _persistSession(_remote.login(
        phone: phone,
        password: password,
        countryIso: countryIso,
        countryCode: countryCode,
      ));

  @override
  Future<ApiResult<Unit>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String country,
    required String countryIso,
    required String countryCode,
    String? gender,
  }) =>
      // No session persisted: the account is activated by verifyPhoneOtp.
      _remote.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        country: country,
        countryIso: countryIso,
        countryCode: countryCode,
        gender: gender,
      );

  @override
  Future<ApiResult<AuthSession>> verifyPhoneOtp({
    required String phone,
    required String otp,
    required String countryIso,
    required String countryCode,
  }) =>
      _persistSession(_remote.verifyPhoneOtp(
        phone: phone,
        otp: otp,
        countryIso: countryIso,
        countryCode: countryCode,
      ));

  @override
  Future<ApiResult<Unit>> sendOtp({
    required String phone,
    required String countryCode,
    required String countryIso,
  }) =>
      _remote.sendOtp(
        phone: phone,
        countryCode: countryCode,
        countryIso: countryIso,
      );

  @override
  Future<ApiResult<String>> verifyOtp({
    required String phone,
    required String otp,
    required String countryIso,
    required String countryCode,
  }) =>
      _remote.verifyOtp(
        phone: phone,
        otp: otp,
        countryIso: countryIso,
        countryCode: countryCode,
      );

  @override
  Future<ApiResult<Unit>> resetPassword({
    required String token,
    required String password,
    required String passwordConfirmation,
  }) =>
      _remote.resetPassword(
        token: token,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

  @override
  Future<ApiResult<Unit>> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) =>
      _remote.changePassword(
        currentPassword: currentPassword,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

  @override
  Future<ApiResult<AuthSession>?> socialSignIn(SocialAuthType type) async {
    final SocialAccount? account;
    try {
      account = await _social.signIn(type);
    } catch (_) {
      return const ApiFailure(
        UnknownFailure('Could not sign in with that provider.'),
      );
    }
    if (account == null) return null; // user cancelled
    return _persistSession(_remote.socialAuth(account));
  }

  @override
  Future<void> logout() async {
    // Best-effort server-side invalidation (token attached by the interceptor).
    // The local session is always cleared afterwards — even if the call fails
    // (offline / expired token) the user must still be signed out locally.
    try {
      await _remote.logout();
    } catch (_) {
      // Swallow: a failed network logout must not block the local sign-out.
    }
    await _local.clear();
  }

  @override
  Future<AuthSession?> currentSession() async {
    final token = await _local.readToken();
    if (token == null || token.isEmpty) return null;
    return AuthSession(token: token);
  }

  /// On a successful token response, persist it and surface an [AuthSession];
  /// failures pass through.
  Future<ApiResult<AuthSession>> _persistSession(
    Future<ApiResult<String>> request,
  ) async {
    final result = await request;
    switch (result) {
      case ApiSuccess<String>(:final data):
        await _local.saveToken(data);
        return ApiSuccess(AuthSession(token: data));
      case ApiFailure<String>(:final failure):
        return ApiFailure(failure);
    }
  }
}
