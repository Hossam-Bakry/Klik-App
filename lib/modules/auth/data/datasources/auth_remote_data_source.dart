import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_interface.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/social_account.dart';

/// Talks to the Klik auth endpoints via [ApiInterface]. Returns raw values
/// (access/reset tokens) wrapped in [ApiResult]; the access token lives at
/// `data.access.token`.
abstract class AuthRemoteDataSource {
  /// POST /api/login → access token.
  Future<ApiResult<String>> login({
    required String phone,
    required String password,
    required String countryIso,
    required String countryCode,
  });

  /// POST /api/registration → access token (auto-login).
  Future<ApiResult<String>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String country,
    required String countryIso,
    required String countryCode,
    String? gender,
  });

  /// POST /api/send-otp — sends an OTP to the phone.
  Future<ApiResult<Unit>> sendOtp({
    required String phone,
    required String countryCode,
    required String countryIso,
  });

  /// POST /api/verify-otp → password-reset token used by [resetPassword].
  Future<ApiResult<String>> verifyOtp({
    required String phone,
    required String otp,
    required String countryIso,
    required String countryCode,
  });

  /// POST /api/reset-password — sets a new password using the reset token.
  Future<ApiResult<Unit>> resetPassword({
    required String token,
    required String password,
    required String passwordConfirmation,
  });

  /// POST /api/social-auth → access token (Google / Apple sign-in).
  Future<ApiResult<String>> socialAuth(SocialAccount account);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._api);

  final ApiInterface _api;

  @override
  Future<ApiResult<String>> login({
    required String phone,
    required String password,
    required String countryIso,
    required String countryCode,
  }) =>
      _api.post(
        ApiEndpoints.login,
        body: {
          'phone': phone,
          'password': password,
          'country_iso': countryIso,
          'country_code': countryCode,
        },
        decoder: _accessToken,
      );

  @override
  Future<ApiResult<String>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String country,
    required String countryIso,
    required String countryCode,
    String? gender,
  }) =>
      _api.post(
        ApiEndpoints.registration,
        body: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'country': country,
          'country_code': countryCode,
          'country_iso': countryIso,
          'gender': ?gender,
        },
        // TODO: if registration needs phone verification before issuing a
        // token, switch to the verify-otp flow instead of expecting a token.
        decoder: _accessToken,
      );

  @override
  Future<ApiResult<Unit>> sendOtp({
    required String phone,
    required String countryCode,
    required String countryIso,
  }) =>
      _api.post(
        ApiEndpoints.sendOtp,
        body: {
          'phone': phone,
          'country_code': countryCode,
          'country_iso': countryIso,
        },
        decoder: (_) => unit,
      );

  @override
  Future<ApiResult<String>> verifyOtp({
    required String phone,
    required String otp,
    required String countryIso,
    required String countryCode,
  }) =>
      _api.post(
        ApiEndpoints.verifyOtp,
        body: {
          'phone': phone,
          'otp': otp,
          'country_iso': countryIso,
          'country_code': countryCode,
        },
        // TODO: confirm the reset-token field name against the live API.
        decoder: (data) => (data['token'] ?? data['reset_token']) as String,
      );

  @override
  Future<ApiResult<Unit>> resetPassword({
    required String token,
    required String password,
    required String passwordConfirmation,
  }) =>
      _api.post(
        ApiEndpoints.resetPassword,
        body: {
          'token': token,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
        decoder: (_) => unit,
      );

  @override
  Future<ApiResult<String>> socialAuth(SocialAccount account) => _api.post(
        ApiEndpoints.socialAuth,
        body: account.toJson(),
        decoder: _accessToken,
      );

  /// Extracts `data.access.token`. Throws if missing — DioApiClient turns that
  /// into a ParsingFailure.
  static String _accessToken(dynamic data) =>
      (data as Map<String, dynamic>)['access']['token'] as String;
}
