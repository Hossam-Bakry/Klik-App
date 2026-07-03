import '../../../../core/network/api_result.dart';
import '../entities/auth_session.dart';
import '../entities/social_account.dart';

/// Contract for authentication + session persistence. Network calls return an
/// [ApiResult]; `currentSession`/`logout` are local-only.
abstract class AuthRepository {
  /// Authenticates with phone + password and persists the resulting session.
  Future<ApiResult<AuthSession>> login({
    required String phone,
    required String password,
    required String countryIso,
    required String countryCode,
  });

  /// Creates an account. No session is issued — the account is inactive until
  /// the phone is verified via [verifyPhoneOtp]. The server sends the OTP.
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

  /// Verifies the phone OTP after registration (POST /api/verify-phone-otp),
  /// activates the account, and persists the resulting session.
  Future<ApiResult<AuthSession>> verifyPhoneOtp({
    required String phone,
    required String otp,
    required String countryIso,
    required String countryCode,
  });

  /// Requests a password-reset OTP be sent to the phone.
  Future<ApiResult<Unit>> sendOtp({
    required String phone,
    required String countryCode,
    required String countryIso,
  });

  /// Verifies the OTP and returns the password-reset token.
  Future<ApiResult<String>> verifyOtp({
    required String phone,
    required String otp,
    required String countryIso,
    required String countryCode,
  });

  /// Sets a new password using the reset token from [verifyOtp].
  Future<ApiResult<Unit>> resetPassword({
    required String token,
    required String password,
    required String passwordConfirmation,
  });

  /// Changes the signed-in user's password (requires [currentPassword]) — the
  /// account settings flow, distinct from [resetPassword]'s forgot-password
  /// (token-based) flow.
  Future<ApiResult<Unit>> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  });

  /// Runs the native social sign-in for [type], exchanges it via
  /// `/api/social-auth`, and persists the session. Returns `null` if the user
  /// cancelled the native flow (no error to show).
  Future<ApiResult<AuthSession>?> socialSignIn(SocialAuthType type);

  /// Clears the persisted session.
  Future<void> logout();

  /// Returns the stored session, or `null` if the user is not logged in.
  Future<AuthSession?> currentSession();
}
