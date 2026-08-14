import 'package:equatable/equatable.dart';

/// Represents a session issued by the API: the access token plus, when the
/// endpoint returns one, the [account] it belongs to.
///
/// A session is only *usable* once the account's phone is verified — see
/// [needsPhoneVerification]. Extend with refresh token / expiry as the API grows.
class AuthSession extends Equatable {
  const AuthSession({required this.token, this.account});

  /// Empty when the response carried no token — `verify-phone-otp` reports the
  /// verified account without issuing one.
  final String token;

  /// The account behind the token, when the response carried one. Null for
  /// endpoints that return a bare token, and for a session restored from
  /// storage — the full profile comes from `GET /api/profile`.
  final AuthAccount? account;

  /// Whether this session can actually be used to call the API.
  bool get hasToken => token.isNotEmpty;

  /// The API hands out a token even for an account that never passed the
  /// activation OTP. Such a session must not start: the user has to verify the
  /// phone first.
  ///
  /// Requires a phone to verify — an account without one (some social sign-ins)
  /// has nowhere to send an OTP, so it's let through rather than dead-ended.
  bool get needsPhoneVerification {
    final account = this.account;
    return account != null && !account.phoneVerified && account.phone.isNotEmpty;
  }

  @override
  List<Object?> get props => [token, account];
}

/// The slice of the signed-in account the auth flow needs. Deliberately narrow:
/// anything else about the user belongs to the profile module.
class AuthAccount extends Equatable {
  const AuthAccount({
    required this.phone,
    required this.countryIso,
    required this.countryCode,
    required this.phoneVerified,
  });

  final String phone;
  final String countryIso;
  final String countryCode;

  /// `phone_verified` — false until the activation OTP is confirmed.
  final bool phoneVerified;

  @override
  List<Object?> get props => [phone, countryIso, countryCode, phoneVerified];
}
