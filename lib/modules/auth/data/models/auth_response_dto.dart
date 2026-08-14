import '../../domain/entities/auth_session.dart';

/// Parses the auth responses (`login`, `verify-phone-otp`, `social-auth`) into
/// an [AuthSession].
///
/// Both halves are optional, because the endpoints differ:
///
/// - `login` / `social-auth` return the token at `data.access.token`, plus the
///   account under `data.user` — chiefly `phone_verified`, which decides
///   whether the session may start or the user is sent to the OTP screen first.
/// - `verify-phone-otp` returns **no token at all**: it only reports the
///   now-verified account (`{ user: {...}, phone_verified: true,
///   country_code, email_or_phone }`). The caller signs in afterwards to get a
///   session — see `AuthBloc._onPhoneOtpSubmitted`.
///
/// So a missing token yields an empty [AuthSession.token] ([AuthSession.hasToken]
/// is false) rather than a parsing failure, and a missing `user` yields a
/// session with no account, which is treated as verified.
class AuthResponseDto {
  const AuthResponseDto._();

  static AuthSession fromJson(dynamic data) {
    final json = data is Map<String, dynamic> ? data : const <String, dynamic>{};
    return AuthSession(
      token: _token(json) ?? '',
      account: _account(json[_K.user]),
    );
  }

  /// `data.access.token`, falling back to a token at the root.
  static String? _token(Map<String, dynamic> json) {
    final access = json[_K.access];
    if (access is Map<String, dynamic>) return access[_K.token] as String?;
    return json[_K.token] as String?;
  }

  static AuthAccount? _account(Object? user) {
    if (user is! Map<String, dynamic>) return null;
    return AuthAccount(
      phone: _str(user[_K.phone]),
      countryIso: _orDefault(_str(user[_K.countryIso]), 'KW'),
      // Both `country_code` and `phone_code` are sent, and either may be null.
      countryCode: _orDefault(
        _orDefault(_str(user[_K.countryCode]), _str(user[_K.phoneCode])),
        '965',
      ),
      phoneVerified: _toBool(user[_K.phoneVerified]),
    );
  }

  static String _str(Object? v) => v?.toString().trim() ?? '';

  static String _orDefault(String value, String fallback) =>
      value.isEmpty ? fallback : value;

  static bool _toBool(Object? v) =>
      v == true || v == 1 || v == '1' || v.toString().toLowerCase() == 'true';
}

/// Backend JSON keys, isolated so a schema change is a one-place edit.
class _K {
  static const access = 'access';
  static const token = 'token';
  static const user = 'user';
  static const phone = 'phone';
  static const phoneVerified = 'phone_verified';
  static const countryIso = 'country_iso';
  static const countryCode = 'country_code';
  static const phoneCode = 'phone_code';
}
