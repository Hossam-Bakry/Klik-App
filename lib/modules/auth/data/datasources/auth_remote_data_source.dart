import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_interface.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/social_account.dart';
import '../models/auth_response_dto.dart';

/// Talks to the Klik auth endpoints via [ApiInterface]. Token-issuing calls
/// decode to an [AuthSession] (see [AuthResponseDto]); the rest return raw
/// values wrapped in [ApiResult].
abstract class AuthRemoteDataSource {
  /// POST /api/login → session. Note the API issues a token even when the
  /// account's phone was never verified — [AuthSession.needsPhoneVerification]
  /// flags that case so the caller can route to the OTP screen instead.
  Future<ApiResult<AuthSession>> login({
    required String phone,
    required String password,
    required String countryIso,
    required String countryCode,
  });

  /// POST /api/registration — creates the account. No session is issued here:
  /// the account must be activated by verifying the phone via [verifyPhoneOtp].
  /// The server sends the activation OTP as part of this call.
  Future<ApiResult<Unit>> register({
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

  /// POST /api/verify-phone-otp → session. Confirms the phone after
  /// registration and activates the account.
  Future<ApiResult<AuthSession>> verifyPhoneOtp({
    required String phone,
    required String otp,
    required String countryIso,
    required String countryCode,
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

  /// 🔒 POST /api/change-password — changes the signed-in user's password.
  Future<ApiResult<Unit>> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  });

  /// POST /api/social-auth → session (Google / Apple sign-in).
  Future<ApiResult<AuthSession>> socialAuth(SocialAccount account);

  /// POST /api/logout — invalidates the current session server-side. The auth
  /// token is attached by the common-headers interceptor.
  Future<ApiResult<Unit>> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._api);

  final ApiInterface _api;

  @override
  Future<ApiResult<AuthSession>> login({
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
        decoder: AuthResponseDto.fromJson,
      );

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
        // No token here — the account is activated by [verifyPhoneOtp].
        decoder: (_) => unit,
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
  Future<ApiResult<AuthSession>> verifyPhoneOtp({
    required String phone,
    required String otp,
    required String countryIso,
    required String countryCode,
  }) =>
      _api.post(
        ApiEndpoints.verifyPhoneOtp,
        body: {
          'otp': otp,
          'phone': phone,
          'country_iso': countryIso,
          'country_code': countryCode,
        },
        decoder: AuthResponseDto.fromJson,
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
  Future<ApiResult<Unit>> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) =>
      _api.post(
        ApiEndpoints.changePassword,
        body: {
          'current_password': currentPassword,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
        decoder: (_) => unit,
      );

  @override
  Future<ApiResult<AuthSession>> socialAuth(SocialAccount account) => _api.post(
        ApiEndpoints.socialAuth,
        body: account.toJson(),
        decoder: AuthResponseDto.fromJson,
      );

  @override
  Future<ApiResult<Unit>> logout() => _api.post(
        ApiEndpoints.logout,
        decoder: (_) => unit,
      );
}
